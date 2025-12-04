from models import User, Meeting, Attendance, Beacon, MeetingReport, GeneralReport
from schemas import UserCreate, MeetingCreate, BeaconCreate, BeaconUpdate
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from fastapi import HTTPException
from datetime import datetime, timezone, timedelta
from zoneinfo import ZoneInfo


CHILE_TZ = ZoneInfo("America/Santiago")
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# User CRUD operations

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def create_user(db: Session, user: UserCreate):
    hashed_pw = pwd_context.hash(user.password)
    db_user = User(name=user.name, email=user.email, hashed_password=hashed_pw, is_admin=user.is_admin if hasattr(user, "is_admin") else False)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)






def get_users(db: Session):
    return db.query(User).all()

def get_user(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()

def delete_user(db: Session, user_id: int):
    user_instance = db.query(User).filter(User.id == user_id).first()
    if user_instance:
        db.delete(user_instance)
        db.commit()
    return user_instance

def update_user(db: Session, user_id: int, new_email: str = None, new_password: str = None):
    user_instance = db.query(User).filter(User.id == user_id).first()
    if user_instance:
        if new_email:
            user_instance.email = new_email
        if new_password:
            user_instance.hashed_password = pwd_context.hash(new_password)
        db.commit()
        db.refresh(user_instance)
    return user_instance








# ================= Meetings =================
def _convert_meeting_to_chile(meeting: Meeting):
    """Convert meeting datetime fields to America/Santiago for responses (non-persistent).
    Assumes stored times are UTC (or naive treated as UTC).
    """
    if not meeting:
        return meeting
    for attr in ("start_time", "end_time", "created_at"):
        dt = getattr(meeting, attr, None)
        if dt is None:
            continue
        # treat naive as UTC
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        try:
            setattr(meeting, attr, dt.astimezone(CHILE_TZ))
        except Exception:
            # fallback: leave as-is
            setattr(meeting, attr, dt)
    return meeting


def create_meeting(db: Session, meeting: MeetingCreate, coordinator_id: int | None = None) -> Meeting:
    # Compute end_time from start_time + duration_minutes
    start_utc = None
    end_utc = None
    if meeting.start_time is not None and meeting.duration_minutes is not None:
        start = meeting.start_time
        # Normalize to timezone-aware Chile if naive
        if start.tzinfo is None:
            start = start.replace(tzinfo=CHILE_TZ)
        # convert to UTC for saving (tz-aware UTC)
        start_utc = start.astimezone(timezone.utc)
        end_utc = start_utc + timedelta(minutes=meeting.duration_minutes)
    # If we don't have times, skip overlap validation and let it be created as-is

    # ===== Overlap validation (only if we have a time window) =====
    if start_utc and end_utc:
        # If a beacon_id is provided, optionally validate it exists
        beacon_obj = None
        if meeting.beacon_id:
            beacon_obj = db.query(Beacon).filter(Beacon.id == meeting.beacon_id).first()
            if not beacon_obj:
                raise HTTPException(status_code=404, detail="Beacon not found")

        # 1) Same beacon overlap check
        if meeting.beacon_id:
            conflict_beacon = (
                db.query(Meeting)
                .filter(
                    Meeting.beacon_id == meeting.beacon_id,
                    Meeting.start_time != None,
                    Meeting.end_time != None,
                    Meeting.start_time < end_utc,
                    Meeting.end_time > start_utc,
                )
                .first()
            )
            if conflict_beacon:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        "Overlap detected: another meeting is scheduled on the same beacon "
                        "within the selected time window"
                    ),
                )

        # 2) Same location (room) overlap check
        # Determine the location to compare: payload location, otherwise beacon's location
        location_key = meeting.location or (beacon_obj.location if beacon_obj else None)
        if location_key:
            conflict_location = (
                db.query(Meeting)
                .join(Beacon, Meeting.beacon_id == Beacon.id)
                .filter(
                    Beacon.location == location_key,
                    Meeting.start_time != None,
                    Meeting.end_time != None,
                    Meeting.start_time < end_utc,
                    Meeting.end_time > start_utc,
                )
                .first()
            )
            if conflict_location:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        "Overlap detected: another meeting is scheduled in the same location "
                        "within the selected time window"
                    ),
                )

    db_meeting = Meeting(
        title=meeting.title,
        description=meeting.description,
        start_time=start_utc,
        end_time=end_utc,
        topics=meeting.topics,
        repeat_weekly=bool(meeting.repeat_weekly) if meeting.repeat_weekly is not None else False,
        note=meeting.note,
        coordinator_id=coordinator_id,
        beacon_id=meeting.beacon_id,
    )
    db.add(db_meeting)
    db.commit()
    db.refresh(db_meeting)
    # Si el creador/coordinador fue pasado, asegúrese de que exista una fila de Attendance
    # con status 'absent' para indicar que está invitado pero aún no confirmó.
    if coordinator_id is not None:
        try:
            existing_att = (
                db.query(Attendance)
                .filter(Attendance.user_id == coordinator_id, Attendance.meeting_id == db_meeting.id)
                .first()
            )
            if not existing_att:
                # Verificar que el usuario existe antes de crear la asistencia
                user_obj = db.query(User).filter(User.id == coordinator_id).first()
                if user_obj:
                    att = Attendance(user_id=coordinator_id, meeting_id=db_meeting.id, status='absent')
                    db.add(att)
                    db.commit()
                    db.refresh(att)
        except Exception:
            # No queremos que la creación de la asistencia bloquee la creación de la reunión.
            db.rollback()
    # convert for response
    _convert_meeting_to_chile(db_meeting)
    return db_meeting


def list_meetings(db: Session):
    meetings = db.query(Meeting).order_by(Meeting.start_time.desc().nullslast()).all()
    for m in meetings:
        _convert_meeting_to_chile(m)
    return meetings


def get_meeting(db: Session, meeting_id: int):
    meeting = db.query(Meeting).filter(Meeting.id == meeting_id).first()
    if meeting:
        print(meeting.start_time)
        _convert_meeting_to_chile(meeting)
        print(meeting.start_time)
    return meeting


def list_meetings_for_user(db: Session, user_id: int):
    # Reuniones donde es coordinador
    coordinator_meetings = (
        db.query(Meeting)
        .filter(Meeting.coordinator_id == user_id)
    )

    # Reuniones donde fue agregado como asistente
    attendee_meetings = (
        db.query(Meeting)
        .join(Attendance, Attendance.meeting_id == Meeting.id)
        .filter(Attendance.user_id == user_id)
    )

    # Unir ambas sin duplicados
    meetings = coordinator_meetings.union(attendee_meetings) \
        .order_by(Meeting.start_time.desc().nullslast()) \
        .all()

    # Convertir a horario de Chile
    for m in meetings:
        _convert_meeting_to_chile(m)

    return meetings



# ================= Attendance =================
def mark_attendance(db: Session, user_id: int, meeting_id: int, status: str = "absent") -> Attendance:
    # Get raw meeting from DB (UTC) for time comparison
    meeting = db.query(Meeting).filter(Meeting.id == meeting_id).first()
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")

    if meeting.start_time is None or meeting.end_time is None:
        raise HTTPException(status_code=400, detail="Meeting time window not configured")

    now_utc = datetime.now(timezone.utc)
    start_utc = meeting.start_time
    end_utc = meeting.end_time
    # treat naive DB datetimes as UTC
    if start_utc.tzinfo is None:
        start_utc = start_utc.replace(tzinfo=timezone.utc)
    if end_utc.tzinfo is None:
        end_utc = end_utc.replace(tzinfo=timezone.utc)

    if now_utc < start_utc:
        raise HTTPException(status_code=400, detail="Meeting has not started yet")
    if now_utc > end_utc:
        raise HTTPException(status_code=400, detail="Meeting has already ended")

    # Regla de estado automático: present si marca entre inicio y mitad, late entre mitad y fin
    duration_seconds = (end_utc - start_utc).total_seconds()
    half_time = start_utc + timedelta(seconds=duration_seconds / 2)
    if now_utc <= half_time:
        auto_status = "present"
    else:
        auto_status = "late"

    # Find existing attendance
    existing = (
        db.query(Attendance)
        .filter(Attendance.user_id == user_id, Attendance.meeting_id == meeting_id)
        .first()
    )
    if existing:
        existing.status = auto_status
        db.commit()
        db.refresh(existing)
        return existing

    att = Attendance(user_id=user_id, meeting_id=meeting_id, status=auto_status)
    db.add(att)
    db.commit()
    db.refresh(att)
    return att


def list_attendance_for_user(db: Session, user_id: int):
    return db.query(Attendance).filter(Attendance.user_id == user_id).all()


def add_attendance(db: Session, user_id: int, meeting_id: int, status: str = "absent") -> Attendance:
    # Validate user and meeting exist
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    meeting = db.query(Meeting).filter(Meeting.id == meeting_id).first()
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")

    # Upsert attendance without time window restrictions
    existing = (
        db.query(Attendance)
        .filter(Attendance.user_id == user_id, Attendance.meeting_id == meeting_id)
        .first()
    )
    if existing:
        existing.status = status
        db.commit()
        db.refresh(existing)
        return existing

    att = Attendance(user_id=user_id, meeting_id=meeting_id, status=status)
    db.add(att)
    db.commit()
    db.refresh(att)
    return att


def list_attendance_for_meeting(db: Session, meeting_id: int):
    """Return all attendance rows for a given meeting id."""
    return db.query(Attendance).filter(Attendance.meeting_id == meeting_id).all()



def list_attendance_for_meeting_with_name_user(db: Session, meeting_id: int):
    """Return all attendance rows for a given meeting id and the users names."""
    # Query returns tuples (Attendance, user_name). Convert to list of dicts
    rows = (
        db.query(Attendance, User.name.label("user_name"))
        .join(User, Attendance.user_id == User.id)
        .filter(Attendance.meeting_id == meeting_id)
        .all()
    )

    result = []
    for att, user_name in rows:
        result.append({
            "id": att.id,
            "user_id": att.user_id,
            "meeting_id": att.meeting_id,
            "status": att.status,
            "marked_at": att.marked_at,
            "user_name": user_name,
        })

    return result



def get_attendance_for_user(db: Session, user_id: int, meeting_id: int):
    """Get attendance record for a specific user and meeting."""
    attendance = (
        db.query(Attendance)
        .filter(Attendance.user_id == user_id, Attendance.meeting_id == meeting_id)
        .first()
    )
    if not attendance:
        raise HTTPException(status_code=404, detail="Attendance record not found")
    return attendance



# ================= Beacon =================
def create_beacon(db: Session, beacon: BeaconCreate):
    db_beacon = Beacon(
        id=beacon.id,
        major=beacon.major,
        minor=beacon.minor,
        location=beacon.location
    )
    db.add(db_beacon)
    db.commit()
    db.refresh(db_beacon)
    return db_beacon

def get_beacons(db: Session):
    return db.query(Beacon).all()

def get_beacon(db: Session, beacon_id: str):
    return db.query(Beacon).filter(Beacon.id == beacon_id).first()

def get_beacon_by_location(db: Session, location: str):
    return db.query(Beacon).filter(Beacon.location == location).first()
def delete_beacon(db: Session, beacon_id: str):
    beacon = db.query(Beacon).filter(Beacon.id == beacon_id).first()
    if beacon:
        db.delete(beacon)
        db.commit()
    return beacon

def update_beacon(db: Session, beacon_id: str, beacon_data: BeaconUpdate):
    beacon = db.query(Beacon).filter(Beacon.id == beacon_id).first()
    if not beacon:
        return None

    if beacon_data.major is not None:
        beacon.major = beacon_data.major

    if beacon_data.minor is not None:
        beacon.minor = beacon_data.minor

    if beacon_data.location is not None:
        beacon.location = beacon_data.location

    beacon.last_used = datetime.now(timezone.utc)

    db.commit()
    db.refresh(beacon)
    return beacon

def update_beacon_last_used(db: Session, beacon_id: str):
    beacon = db.query(Beacon).filter(Beacon.id == beacon_id).first()
    if beacon:
        beacon.last_used = datetime.now(timezone.utc)
        db.commit()
        db.refresh(beacon)
    return beacon


# ================= Meeting Report =================
def generate_meeting_report(db: Session, meeting_id: int) -> MeetingReport:
    """Genera (o devuelve si ya existe) el reporte de una reunión específica.

    - fecha: se toma de start_time (en formato YYYY-MM-DD) o created_at si no hay start_time.
    - nombre_reunion: título de la reunión.
    - asistencias_totales: total de registros de asistencia (present/late/absent).
    - porcentaje_asistencias: porcentaje de present + late sobre total.
    - porcentaje_ausencias: porcentaje de absent sobre total.

    Los campos cantidad_asistencias y cantidad_reuniones quedan definidos pero sin lógica aún.
    """
    meeting = db.query(Meeting).filter(Meeting.id == meeting_id).first()
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")

    # Si ya existe un reporte para esta reunión, lo devolvemos
    existing = db.query(MeetingReport).filter(MeetingReport.meeting_id == meeting_id).first()
    if existing:
        return existing

    # Calcular datos de asistencia
    attendance_qs = db.query(Attendance).filter(Attendance.meeting_id == meeting_id)

    # Invitados totales: cantidad de registros de attendance (todos los que fueron agregados)
    invitados_totales = attendance_qs.count()

    # Clasificación por estado
    present_count = attendance_qs.filter(Attendance.status == "present").count()
    late_count = attendance_qs.filter(Attendance.status == "late").count()
    absent_count = attendance_qs.filter(Attendance.status == "absent").count()

    asistentes_totales = present_count #+ late_count # considerar solo present como asistentes, no late

    if invitados_totales > 0:
        porcentaje_asistencias = (asistentes_totales / invitados_totales) * 100.0
        porcentaje_ausencias = (absent_count / invitados_totales) * 100.0
        porcentaje_tarde = (late_count / invitados_totales) * 100.0
    else:
        porcentaje_asistencias = 0.0
        porcentaje_ausencias = 0.0

    # Fecha como string (usar start_time si existe, si no created_at)
    base_dt = meeting.start_time or meeting.created_at
    if base_dt is None:
        fecha_str = ""
    else:
        # Normalizar a tz Chile y luego formatear solo fecha
        if base_dt.tzinfo is None:
            base_dt = base_dt.replace(tzinfo=timezone.utc)
        fecha_str = base_dt.astimezone(CHILE_TZ).strftime("%Y-%m-%d")

    report = MeetingReport(
        meeting_id=meeting.id,
        fecha=fecha_str,
        nombre_reunion=meeting.title,
        invitados_totales=invitados_totales,
        asistentes_totales=asistentes_totales,
        llegadas_tarde=late_count,
        ausentes=absent_count,
        porcentaje_asistencias=porcentaje_asistencias,
        porcentaje_ausencias=porcentaje_ausencias,
        porcentaje_tarde=porcentaje_tarde,
        # Campos * quedan sin lógica aún
        cantidad_asistencias=None,
        cantidad_reuniones=None,
    )

    db.add(report)
    db.commit()
    db.refresh(report)
    return report


def get_meeting_report(db: Session, meeting_id: int) -> MeetingReport | None:
    """Obtiene el reporte de una reunión si existe, sin generarlo."""
    return db.query(MeetingReport).filter(MeetingReport.meeting_id == meeting_id).first()


def generate_general_report(db: Session, user_id: int):

    attendance_qs = db.query(Attendance).filter(Attendance.user_id == user_id)

    total_reuniones = attendance_qs.count()
    if total_reuniones == 0:
        return {
            "cantidad_asistencias": 0,
            "cantidad_reuniones": 0,
            "cantidad_atrasados": 0,
            "porcentaje_asistencias": 0.0,
            "porcentaje_ausencias": 0.0,
            "porcentaje_atrasados": 0.0,
        }

    asistencias = attendance_qs.filter(Attendance.status == "present").count()
    ausencias = attendance_qs.filter(Attendance.status == "absent").count()
    atrasados = attendance_qs.filter(Attendance.status == "late").count()

    return {
        "cantidad_asistencias": asistencias,
        "cantidad_reuniones": total_reuniones,
        "cantidad_atrasados": atrasados,
        "porcentaje_asistencias": (asistencias / total_reuniones) * 100,
        "porcentaje_ausencias": (ausencias / total_reuniones) * 100,
        "porcentaje_atrasados": (atrasados / total_reuniones) * 100,
    }




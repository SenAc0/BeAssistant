"""Operaciones de base de datos sobre reuniones."""
from datetime import timedelta, timezone

from fastapi import HTTPException
from sqlalchemy.orm import Session

from models import Attendance, Beacon, Meeting, User
from schemas import MeetingCreate
from utils.timezone import CHILE_TZ


def _validate_no_overlap(db: Session, meeting: MeetingCreate, start_utc, end_utc):
    """Valida que no exista otra reunión solapada en el mismo beacon o ubicación."""
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
                Meeting.start_time != None,  # noqa: E711 - SQLAlchemy requiere `!= None`
                Meeting.end_time != None,  # noqa: E711
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
                Meeting.start_time != None,  # noqa: E711
                Meeting.end_time != None,  # noqa: E711
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


def _ensure_coordinator_attendance(db: Session, meeting_id: int, coordinator_id: int):
    """Crea la fila de Attendance del coordinador ('absent' = invitado sin confirmar)."""
    try:
        existing_att = (
            db.query(Attendance)
            .filter(Attendance.user_id == coordinator_id, Attendance.meeting_id == meeting_id)
            .first()
        )
        if not existing_att:
            # Verificar que el usuario existe antes de crear la asistencia
            user_obj = db.query(User).filter(User.id == coordinator_id).first()
            if user_obj:
                att = Attendance(user_id=coordinator_id, meeting_id=meeting_id, status="absent")
                db.add(att)
                db.commit()
                db.refresh(att)
    except Exception:
        # No queremos que la creación de la asistencia bloquee la creación de la reunión.
        db.rollback()


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

    if start_utc and end_utc:
        _validate_no_overlap(db, meeting, start_utc, end_utc)

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

    if coordinator_id is not None:
        _ensure_coordinator_attendance(db, db_meeting.id, coordinator_id)

    return db_meeting


def list_meetings(db: Session):
    return db.query(Meeting).order_by(Meeting.start_time.desc().nullslast()).all()


def get_meeting(db: Session, meeting_id: int):
    return db.query(Meeting).filter(Meeting.id == meeting_id).first()


def list_meetings_for_user(db: Session, user_id: int):
    # Reuniones donde es coordinador
    coordinator_meetings = db.query(Meeting).filter(Meeting.coordinator_id == user_id)

    # Reuniones donde fue agregado como asistente
    attendee_meetings = (
        db.query(Meeting)
        .join(Attendance, Attendance.meeting_id == Meeting.id)
        .filter(Attendance.user_id == user_id)
    )

    # Unir ambas sin duplicados
    return (
        coordinator_meetings.union(attendee_meetings)
        .order_by(Meeting.start_time.desc().nullslast())
        .all()
    )

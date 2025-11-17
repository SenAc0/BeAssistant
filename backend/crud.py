from models import User, Meeting, Attendance, Beacon
from schemas import UserCreate, MeetingCreate, BeaconCreate
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
    db_user = User(name=user.name, email=user.email, hashed_password=hashed_pw)
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
    meetings = db.query(Meeting).filter(Meeting.coordinator_id == user_id).order_by(Meeting.start_time.desc().nullslast()).all()
    for m in meetings:
        print("antes", m.start_time)
        _convert_meeting_to_chile(m)
        print("despues", m.start_time)
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

    # Find existing attendance
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

def delete_beacon(db: Session, beacon_id: str):
    beacon = db.query(Beacon).filter(Beacon.id == beacon_id).first()
    if beacon:
        db.delete(beacon)
        db.commit()
    return beacon

def update_beacon(db: Session, beacon_id: str, beacon_data: BeaconCreate):
    beacon = db.query(Beacon).filter(Beacon.id == beacon_id).first()
    if not beacon:
        return None
    beacon.major = beacon_data.major
    beacon.minor = beacon_data.minor
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




from models import User, Meeting, Attendance

from schemas import UserCreate, MeetingCreate
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from fastapi import HTTPException
from datetime import datetime, timezone

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# User CRUD operations

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def create_user(db: Session, user: UserCreate):
    hashed_pw = pwd_context.hash(user.password)
    db_user = User(email=user.email, hashed_password=hashed_pw)
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
def create_meeting(db: Session, meeting: MeetingCreate) -> Meeting:
    db_meeting = Meeting(
        title=meeting.title,
        description=meeting.description,
        start_time=meeting.start_time,
        end_time=meeting.end_time,
        beacon_uuid=meeting.beacon_uuid,
        beacon_major=meeting.beacon_major,
        beacon_minor=meeting.beacon_minor,
    )
    db.add(db_meeting)
    db.commit()
    db.refresh(db_meeting)
    return db_meeting


def list_meetings(db: Session):
    return db.query(Meeting).order_by(Meeting.start_time.desc().nullslast()).all()


def get_meeting(db: Session, meeting_id: int):
    return db.query(Meeting).filter(Meeting.id == meeting_id).first()

"""
#Resolve a meeting by beacon identifiers.
#    Preference order:
#    1) Active meeting (now between start_time and end_time)
#    2) Latest meeting matching the beacon (by start_time desc, nulls last)
def resolve_meeting_by_beacon(db: Session, uuid: str, major: int, minor: int):
    now = datetime.now(timezone.utc)

    base_q = (
        db.query(Meeting)
        .filter(
            Meeting.beacon_uuid == uuid,
            Meeting.beacon_major == major,
            Meeting.beacon_minor == minor,
        )
    )

    active = (
        base_q.filter(
            Meeting.start_time != None,
            Meeting.end_time != None,
            Meeting.start_time <= now,
            Meeting.end_time >= now,
        )
        .order_by(Meeting.start_time.desc())
        .first()
    )
    if active:
        return active

    return base_q.order_by(Meeting.start_time.desc().nullslast()).first()

"""

# ================= Attendance =================
def mark_attendance(db: Session, user_id: int, meeting_id: int, status: str = "present") -> Attendance:
    # Check meeting exists
    meeting = get_meeting(db, meeting_id)
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")

    # Validate time window: only allow marking between start_time and end_time
    if meeting.start_time is None or meeting.end_time is None:
        raise HTTPException(status_code=400, detail="Meeting time window not configured")

    now_utc = datetime.now(timezone.utc)
    # Ensure meeting times are timezone-aware for comparison
    start = meeting.start_time
    end = meeting.end_time
    if start.tzinfo is None:
        start = start.replace(tzinfo=timezone.utc)
    if end.tzinfo is None:
        end = end.replace(tzinfo=timezone.utc)

    if now_utc < start:
        raise HTTPException(status_code=400, detail="Meeting has not started yet")
    if now_utc > end:
        raise HTTPException(status_code=400, detail="Meeting has already ended")

    # Find existing attendance
    existing = (
        db.query(Attendance)
        .filter(Attendance.user_id == user_id, Attendance.meeting_id == meeting_id)
        .first()
    )
    if existing:
        return existing

    att = Attendance(user_id=user_id, meeting_id=meeting_id, status=status)
    db.add(att)
    db.commit()
    db.refresh(att)
    return att


def list_attendance_for_user(db: Session, user_id: int):
    return db.query(Attendance).filter(Attendance.user_id == user_id).all()









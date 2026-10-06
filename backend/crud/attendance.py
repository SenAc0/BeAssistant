"""Operaciones de base de datos sobre asistencias."""
from datetime import datetime, timedelta, timezone

from fastapi import HTTPException
from sqlalchemy.orm import Session

from models import Attendance, Meeting, User


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
    auto_status = "present" if now_utc <= half_time else "late"

    return _upsert_attendance(db, user_id=user_id, meeting_id=meeting_id, status=auto_status)


def add_attendance(db: Session, user_id: int, meeting_id: int, status: str = "absent") -> Attendance:
    """Asigna/actualiza la asistencia sin restricciones de ventana de tiempo."""
    # Validate user and meeting exist
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    meeting = db.query(Meeting).filter(Meeting.id == meeting_id).first()
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")

    return _upsert_attendance(db, user_id=user_id, meeting_id=meeting_id, status=status)


def _upsert_attendance(db: Session, user_id: int, meeting_id: int, status: str) -> Attendance:
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


def remove_attendance(db: Session, user_id: int, meeting_id: int):
    """Elimina la asistencia de un usuario a una reunión (desinvitarlo)."""
    att = (
        db.query(Attendance)
        .filter(Attendance.user_id == user_id, Attendance.meeting_id == meeting_id)
        .first()
    )

    if not att:
        raise HTTPException(status_code=404, detail="Attendance not found")

    db.delete(att)
    db.commit()
    return att


def list_attendance_for_user(db: Session, user_id: int):
    return db.query(Attendance).filter(Attendance.user_id == user_id).all()


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

    return [
        {
            "id": att.id,
            "user_id": att.user_id,
            "meeting_id": att.meeting_id,
            "status": att.status,
            "marked_at": att.marked_at,
            "user_name": user_name,
        }
        for att, user_name in rows
    ]


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

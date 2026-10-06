"""Operaciones de base de datos sobre asistencias."""
from datetime import datetime, timedelta, timezone

from beanie import PydanticObjectId
from fastapi import HTTPException

from models import Attendance, Meeting, User


async def mark_attendance(
    user_id: PydanticObjectId, meeting_id: PydanticObjectId, status: str = "absent"
) -> Attendance:
    meeting = await Meeting.get(meeting_id)
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")

    if meeting.start_time is None or meeting.end_time is None:
        raise HTTPException(status_code=400, detail="Meeting time window not configured")

    now_utc = datetime.now(timezone.utc)
    start_utc = meeting.start_time
    end_utc = meeting.end_time
    # Mongo devuelve UTC; si viniera naive, se trata como UTC
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

    return await _upsert_attendance(user_id=user_id, meeting_id=meeting_id, status=auto_status)


async def add_attendance(
    user_id: PydanticObjectId, meeting_id: PydanticObjectId, status: str = "absent"
) -> Attendance:
    """Asigna/actualiza la asistencia sin restricciones de ventana de tiempo."""
    if not await User.get(user_id):
        raise HTTPException(status_code=404, detail="User not found")
    if not await Meeting.get(meeting_id):
        raise HTTPException(status_code=404, detail="Meeting not found")

    return await _upsert_attendance(user_id=user_id, meeting_id=meeting_id, status=status)


async def _upsert_attendance(
    user_id: PydanticObjectId, meeting_id: PydanticObjectId, status: str
) -> Attendance:
    existing = await Attendance.find_one(
        Attendance.user_id == user_id, Attendance.meeting_id == meeting_id
    )
    if existing:
        existing.status = status
        await existing.save()
        return existing

    return await Attendance(user_id=user_id, meeting_id=meeting_id, status=status).insert()


async def remove_attendance(user_id: PydanticObjectId, meeting_id: PydanticObjectId) -> Attendance:
    """Elimina la asistencia de un usuario a una reunión (desinvitarlo)."""
    att = await Attendance.find_one(
        Attendance.user_id == user_id, Attendance.meeting_id == meeting_id
    )

    if not att:
        raise HTTPException(status_code=404, detail="Attendance not found")

    await att.delete()
    return att


async def list_attendance_for_user(user_id: PydanticObjectId) -> list[Attendance]:
    return await Attendance.find(Attendance.user_id == user_id).to_list()


async def list_attendance_for_meeting(meeting_id: PydanticObjectId) -> list[Attendance]:
    """Devuelve todas las asistencias de una reunión."""
    return await Attendance.find(Attendance.meeting_id == meeting_id).to_list()


async def list_attendance_for_meeting_with_name_user(meeting_id: PydanticObjectId) -> list[dict]:
    """Asistencias de una reunión, cada una con el nombre del usuario.

    Sin JOIN: se traen las asistencias y después los usuarios en una sola consulta.
    """
    rows = await Attendance.find(Attendance.meeting_id == meeting_id).to_list()
    if not rows:
        return []

    users = await User.find({"_id": {"$in": [att.user_id for att in rows]}}).to_list()
    names = {user.id: user.name for user in users}

    return [
        {
            "id": att.id,
            "user_id": att.user_id,
            "meeting_id": att.meeting_id,
            "status": att.status,
            "marked_at": att.marked_at,
            "user_name": names.get(att.user_id, ""),
        }
        for att in rows
        # Igual que el INNER JOIN anterior: sin usuario, la fila no aparece
        if att.user_id in names
    ]


async def get_attendance_for_user(
    user_id: PydanticObjectId, meeting_id: PydanticObjectId
) -> Attendance:
    """Asistencia de un usuario en una reunión."""
    attendance = await Attendance.find_one(
        Attendance.user_id == user_id, Attendance.meeting_id == meeting_id
    )
    if not attendance:
        raise HTTPException(status_code=404, detail="Attendance record not found")
    return attendance

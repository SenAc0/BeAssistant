"""Endpoints de asistencia."""
from typing import List

from beanie import PydanticObjectId
from fastapi import APIRouter, Depends, HTTPException

import crud
import schemas
from api.deps import get_current_user

router = APIRouter(tags=["attendance"])

ONLY_COORDINATOR_ADD = "Only the coordinator can add assistants"
ONLY_COORDINATOR_REMOVE = "Only the coordinator can remove assistants"
MEETING_NOT_FOUND = "Meeting not found"


async def _get_meeting_as_coordinator(
    meeting_id: PydanticObjectId, current_user, forbidden_detail: str
):
    """Devuelve la reunión validando que `current_user` sea su coordinador."""
    meeting = await crud.get_meeting(meeting_id)
    if not meeting:
        raise HTTPException(status_code=404, detail=MEETING_NOT_FOUND)
    if meeting.coordinator_id != current_user.id:
        raise HTTPException(status_code=403, detail=forbidden_detail)
    return meeting


@router.post("/attendance/mark", response_model=schemas.Attendance)
async def mark_attendance(
    payload: schemas.AttendanceCreate,
    current_user=Depends(get_current_user),
):
    """Marca la asistencia del usuario autenticado a la reunión indicada.

    Valida que la reunión esté en curso (ventana de tiempo) y actualiza o crea el registro.
    """
    return await crud.mark_attendance(
        user_id=current_user.id,
        meeting_id=payload.meeting_id,
        status=payload.status or "present",
    )


@router.get("/attendance/my", response_model=List[schemas.Attendance])
async def my_attendance(current_user=Depends(get_current_user)):
    """Devuelve todas las asistencias del usuario autenticado."""
    return await crud.list_attendance_for_user(user_id=current_user.id)


@router.post("/attendance", response_model=schemas.Attendance)
async def add_attendance(
    payload: schemas.AttendanceAssign,
    current_user=Depends(get_current_user),
):
    """Asigna o actualiza la asistencia de un usuario a una reunión (upsert).

    Sin restricciones por ventana de tiempo. Solo el coordinador puede agregar asistentes.
    """
    await _get_meeting_as_coordinator(payload.meeting_id, current_user, ONLY_COORDINATOR_ADD)

    return await crud.add_attendance(
        user_id=payload.user_id,
        meeting_id=payload.meeting_id,
        status=payload.status or "absent",
    )


@router.delete("/attendance")
async def remove_attendance(
    user_id: PydanticObjectId,
    meeting_id: PydanticObjectId,
    current_user=Depends(get_current_user),
):
    """Elimina la asistencia de un usuario a una reunión. Solo el coordinador."""
    await _get_meeting_as_coordinator(meeting_id, current_user, ONLY_COORDINATOR_REMOVE)

    await crud.remove_attendance(user_id=user_id, meeting_id=meeting_id)
    return {"message": "Attendance removed"}


@router.get("/attendance/meeting/{meeting_id}", response_model=List[schemas.Attendance])
async def list_attendance_for_meeting(
    meeting_id: PydanticObjectId, current_user=Depends(get_current_user)
):
    """Lista todas las asistencias registradas para la reunión indicada."""
    return await crud.list_attendance_for_meeting(meeting_id=meeting_id)


@router.get("/attendance/meeting_named_user/{meeting_id}", response_model=List[schemas.AttendanceWithUser])
async def list_attendance_for_meeting_named_user(
    meeting_id: PydanticObjectId, current_user=Depends(get_current_user)
):
    """Lista las asistencias de la reunión indicada, incluyendo el nombre de usuario.

    Esto permite al frontend obtener directamente la lista con `user_name` sin tener que solicitar
    todos los usuarios por separado.
    """
    return await crud.list_attendance_for_meeting_with_name_user(meeting_id=meeting_id)


@router.get("/attendance/my/{meeting_id}", response_model=schemas.Attendance)
async def get_my_attendance(
    meeting_id: PydanticObjectId, current_user=Depends(get_current_user)
):
    """Obtiene la asistencia del usuario autenticado a la reunión indicada."""
    return await crud.get_attendance_for_user(
        user_id=current_user.id, meeting_id=meeting_id
    )

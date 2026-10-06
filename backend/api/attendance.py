"""Endpoints de asistencia."""
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

import crud
import schemas
from api.deps import get_current_user
from db import get_db

router = APIRouter(tags=["attendance"])

ONLY_COORDINATOR_ADD = "Only the coordinator can add assistants"
ONLY_COORDINATOR_REMOVE = "Only the coordinator can remove assistants"
MEETING_NOT_FOUND = "Meeting not found"


def _get_meeting_as_coordinator(db: Session, meeting_id: int, current_user, forbidden_detail: str):
    """Devuelve la reunión validando que `current_user` sea su coordinador."""
    meeting = crud.get_meeting(db, meeting_id)
    if not meeting:
        raise HTTPException(status_code=404, detail=MEETING_NOT_FOUND)
    if meeting.coordinator_id != current_user.id:
        raise HTTPException(status_code=403, detail=forbidden_detail)
    return meeting


@router.post("/attendance/mark", response_model=schemas.Attendance)
def mark_attendance(
    payload: schemas.AttendanceCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """Marca la asistencia del usuario autenticado a la reunión indicada.

    Valida que la reunión esté en curso (ventana de tiempo) y actualiza o crea el registro.
    """
    return crud.mark_attendance(
        db,
        user_id=current_user.id,
        meeting_id=payload.meeting_id,
        status=payload.status or "present",
    )


@router.get("/attendance/my", response_model=List[schemas.Attendance])
def my_attendance(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    """Devuelve todas las asistencias del usuario autenticado."""
    return crud.list_attendance_for_user(db, user_id=current_user.id)


@router.post("/attendance", response_model=schemas.Attendance)
def add_attendance(
    payload: schemas.AttendanceAssign,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """Asigna o actualiza la asistencia de un usuario a una reunión (upsert).

    Sin restricciones por ventana de tiempo. Solo el coordinador puede agregar asistentes.
    """
    _get_meeting_as_coordinator(db, payload.meeting_id, current_user, ONLY_COORDINATOR_ADD)

    return crud.add_attendance(
        db,
        user_id=payload.user_id,
        meeting_id=payload.meeting_id,
        status=payload.status or "absent",
    )


@router.delete("/attendance")
def remove_attendance(
    user_id: int,
    meeting_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """Elimina la asistencia de un usuario a una reunión. Solo el coordinador."""
    _get_meeting_as_coordinator(db, meeting_id, current_user, ONLY_COORDINATOR_REMOVE)

    crud.remove_attendance(db, user_id=user_id, meeting_id=meeting_id)
    return {"message": "Attendance removed"}


@router.get("/attendance/meeting/{meeting_id}", response_model=List[schemas.Attendance])
def list_attendance_for_meeting(
    meeting_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)
):
    """Lista todas las asistencias registradas para la reunión indicada."""
    return crud.list_attendance_for_meeting(db, meeting_id=meeting_id)


@router.get("/attendance/meeting_named_user/{meeting_id}", response_model=List[schemas.AttendanceWithUser])
def list_attendance_for_meeting_named_user(
    meeting_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)
):
    """Lista las asistencias de la reunión indicada, incluyendo el nombre de usuario.

    Esto permite al frontend obtener directamente la lista con `user_name` sin tener que solicitar
    todos los usuarios por separado.
    """
    return crud.list_attendance_for_meeting_with_name_user(db, meeting_id=meeting_id)


@router.get("/attendance/my/{meeting_id}", response_model=schemas.Attendance)
def get_my_attendance(
    meeting_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)
):
    """Obtiene la asistencia del usuario autenticado a la reunión indicada."""
    return crud.get_attendance_for_user(db, user_id=current_user.id, meeting_id=meeting_id)

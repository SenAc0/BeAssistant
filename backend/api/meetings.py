"""Endpoints de reuniones."""
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

import crud
import schemas
from api.deps import get_current_user
from db import get_db

router = APIRouter(tags=["meetings"])


@router.post("/meetings", response_model=schemas.Meeting)
def create_meeting(
    meeting: schemas.MeetingCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    # Nota: en un escenario real, validar rol/admin aquí
    return crud.create_meeting(db, meeting, coordinator_id=current_user.id)


@router.get("/meetings", response_model=List[schemas.Meeting])
def list_meetings(db: Session = Depends(get_db)):
    return crud.list_meetings(db)


# endpoint para obtener reuniones del usuario actual
@router.get("/meetings/my", response_model=List[schemas.Meeting])
def list_meetings_for_user(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return crud.list_meetings_for_user(db, user_id=current_user.id)


# Devuelve la lista de todos los beacons disponibles para asociar a una reunión.
@router.get("/meetings/available-beacons", response_model=List[schemas.Beacon])
def get_available_beacons(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return crud.get_beacons(db)


# endpoint para obtener una reunion por id del usuario actual
@router.get("/meeting/{meeting_id}", response_model=schemas.MeetingDetail, status_code=status.HTTP_200_OK)
def get_meeting_for_user(meeting_id: int, db: Session = Depends(get_db)):
    meeting = crud.get_meeting(db, meeting_id)
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")

    response = schemas.MeetingDetail.model_validate(meeting)
    # Asignar location del beacon si existe
    if meeting.beacon:
        response.location = meeting.beacon.location

    return response

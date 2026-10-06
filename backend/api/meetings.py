"""Endpoints de reuniones."""
from typing import List

from beanie import PydanticObjectId
from fastapi import APIRouter, Depends, HTTPException, status

import crud
import schemas
from api.deps import get_current_user

router = APIRouter(tags=["meetings"])


@router.post("/meetings", response_model=schemas.Meeting)
async def create_meeting(
    meeting: schemas.MeetingCreate,
    current_user=Depends(get_current_user),
):
    # Nota: en un escenario real, validar rol/admin aquí
    return await crud.create_meeting(meeting, coordinator_id=current_user.id)


@router.get("/meetings", response_model=List[schemas.Meeting])
async def list_meetings():
    return await crud.list_meetings()


# endpoint para obtener reuniones del usuario actual
@router.get("/meetings/my", response_model=List[schemas.Meeting])
async def list_meetings_for_user(current_user=Depends(get_current_user)):
    return await crud.list_meetings_for_user(user_id=current_user.id)


# Devuelve la lista de todos los beacons disponibles para asociar a una reunión.
@router.get("/meetings/available-beacons", response_model=List[schemas.Beacon])
async def get_available_beacons(current_user=Depends(get_current_user)):
    return await crud.get_beacons()


# endpoint para obtener una reunion por id de la reunion
@router.get("/meeting/{meeting_id}", response_model=schemas.MeetingDetail, status_code=status.HTTP_200_OK)
async def get_meeting_for_user(meeting_id: PydanticObjectId):
    meeting = await crud.get_meeting(meeting_id)
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")

    response = schemas.MeetingDetail.model_validate(meeting)

    # Sin relaciones del ORM: se resuelven con una consulta por referencia.
    if meeting.beacon_id:
        beacon = await crud.get_beacon(meeting.beacon_id)
        if beacon:
            response.location = beacon.location
    if meeting.coordinator_id:
        coordinator = await crud.get_user(meeting.coordinator_id)
        if coordinator:
            response.coordinator = schemas.User.model_validate(coordinator)

    return response

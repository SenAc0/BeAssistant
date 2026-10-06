"""Endpoints de reportes (por reunión y general)."""
from beanie import PydanticObjectId
from fastapi import APIRouter, Depends, HTTPException

import crud
import schemas
from api.deps import get_current_user

router = APIRouter(tags=["reports"])

MEETING_NOT_FOUND = "Meeting not found"


async def _get_meeting_as_coordinator(
    meeting_id: PydanticObjectId, current_user, forbidden_detail: str
):
    meeting = await crud.get_meeting(meeting_id)
    if not meeting:
        raise HTTPException(status_code=404, detail=MEETING_NOT_FOUND)
    if meeting.coordinator_id != current_user.id:
        raise HTTPException(status_code=403, detail=forbidden_detail)
    return meeting


@router.post("/meetings/{meeting_id}/report", response_model=schemas.MeetingReport)
async def generate_meeting_report_endpoint(
    meeting_id: PydanticObjectId, current_user=Depends(get_current_user)
):
    """Genera (o devuelve si ya existe) el reporte de una reunión.

    Requiere que el usuario autenticado sea el coordinador de la reunión.
    Retorna el reporte generado.
    """
    await _get_meeting_as_coordinator(
        meeting_id, current_user, "Only the coordinator can generate the report"
    )

    return await crud.generate_meeting_report(meeting_id=meeting_id)


@router.get("/meetings/{meeting_id}/report", response_model=schemas.MeetingReport)
async def get_meeting_report(
    meeting_id: PydanticObjectId, current_user=Depends(get_current_user)
):
    """Obtiene el reporte ya generado de una reunión.

    No crea nada nuevo; si no hay reporte, responde 404.
    Solo el coordinador puede consultarlo.
    """
    await _get_meeting_as_coordinator(
        meeting_id, current_user, "Only the coordinator can view the report"
    )

    report = await crud.get_meeting_report(meeting_id=meeting_id)
    if not report:
        raise HTTPException(status_code=404, detail="Meeting report not found")

    return report


@router.get("/report/general", response_model=schemas.GeneralReport)
async def generate_general_report(current_user=Depends(get_current_user)):
    return await crud.generate_general_report(user_id=current_user.id)

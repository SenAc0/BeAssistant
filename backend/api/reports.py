"""Endpoints de reportes (por reunión y general)."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

import crud
import schemas
from api.deps import get_current_user
from db import get_db

router = APIRouter(tags=["reports"])

MEETING_NOT_FOUND = "Meeting not found"


def _get_meeting_as_coordinator(db: Session, meeting_id: int, current_user, forbidden_detail: str):
    meeting = crud.get_meeting(db, meeting_id)
    if not meeting:
        raise HTTPException(status_code=404, detail=MEETING_NOT_FOUND)
    if meeting.coordinator_id != current_user.id:
        raise HTTPException(status_code=403, detail=forbidden_detail)
    return meeting


@router.post("/meetings/{meeting_id}/report", response_model=schemas.MeetingReport)
def generate_meeting_report_endpoint(
    meeting_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)
):
    """Genera (o devuelve si ya existe) el reporte de una reunión.

    Requiere que el usuario autenticado sea el coordinador de la reunión.
    Requiere que la reunión haya finalizado.
    Retorna el reporte generado.
    """
    _get_meeting_as_coordinator(
        db, meeting_id, current_user, "Only the coordinator can generate the report"
    )

    return crud.generate_meeting_report(db, meeting_id=meeting_id)


@router.get("/meetings/{meeting_id}/report", response_model=schemas.MeetingReport)
def get_meeting_report(
    meeting_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)
):
    """Obtiene el reporte ya generado de una reunión.

    No crea nada nuevo; si no hay reporte, responde 404.
    Solo el coordinador puede consultarlo.
    """
    _get_meeting_as_coordinator(
        db, meeting_id, current_user, "Only the coordinator can view the report"
    )

    report = crud.get_meeting_report(db, meeting_id=meeting_id)
    if not report:
        raise HTTPException(status_code=404, detail="Meeting report not found")

    return report


@router.get("/report/general", response_model=schemas.GeneralReport)
def generate_general_report(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return crud.generate_general_report(db, user_id=current_user.id)

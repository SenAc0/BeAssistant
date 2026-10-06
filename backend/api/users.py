"""Endpoints de usuarios."""
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

import crud
import schemas
from api.deps import get_current_user
from db import get_db

router = APIRouter(tags=["users"])


@router.get("/users", response_model=List[schemas.User])
def list_users(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return crud.get_users(db)


@router.post("/users/register-device")
def register_device(
    payload: schemas.RegisterDeviceRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """Registra el OneSignal player_id del dispositivo del usuario autenticado."""
    user = crud.update_user_player_id(db, user_id=current_user.id, player_id=payload.player_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": "Device registered successfully", "player_id": payload.player_id}

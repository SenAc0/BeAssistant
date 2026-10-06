"""Endpoints de usuarios."""
from typing import List

from fastapi import APIRouter, Depends, HTTPException

import crud
import schemas
from api.deps import get_current_user

router = APIRouter(tags=["users"])


@router.get("/users", response_model=List[schemas.User])
async def list_users(current_user=Depends(get_current_user)):
    return await crud.get_users()


@router.post("/users/register-device")
async def register_device(
    payload: schemas.RegisterDeviceRequest,
    current_user=Depends(get_current_user),
):
    """Registra el OneSignal player_id del dispositivo del usuario autenticado."""
    user = await crud.update_user_player_id(
        user_id=current_user.id, player_id=payload.player_id
    )
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": "Device registered successfully", "player_id": payload.player_id}

"""Registro, login y perfil del usuario autenticado."""
from fastapi import APIRouter, Depends, HTTPException, status

import crud
import schemas
from api.deps import get_current_user
from utils.security import create_access_token

router = APIRouter(tags=["auth"])


@router.post("/register", response_model=schemas.User)
async def register(user: schemas.UserCreate):
    db_user = await crud.get_user_by_email(user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return await crud.create_user(user)


@router.post("/login")
async def login(data: schemas.LoginRequest):
    user = await crud.authenticate_user(data.email, data.password)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    access_token = create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}


# para perfil
@router.get("/me", response_model=schemas.User)
async def get_me(current_user=Depends(get_current_user)):
    return current_user

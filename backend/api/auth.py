"""Registro, login y perfil del usuario autenticado."""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

import crud
import schemas
from api.deps import get_current_user
from db import get_db
from utils.security import create_access_token

router = APIRouter(tags=["auth"])


@router.post("/register", response_model=schemas.User)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return crud.create_user(db, user)


@router.post("/login")
def login(data: schemas.LoginRequest, db: Session = Depends(get_db)):
    user = crud.authenticate_user(db, data.email, data.password)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    access_token = create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}


# para perfil
@router.get("/me", response_model=schemas.User)
def get_me(current_user=Depends(get_current_user)):
    return current_user

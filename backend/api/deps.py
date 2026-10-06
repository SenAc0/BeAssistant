"""Dependencias compartidas por los routers."""
from fastapi import Depends, HTTPException, status
from jose import JWTError
from sqlalchemy.orm import Session

import crud
from db import get_db
from utils.security import decode_access_token, oauth2_scheme


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_access_token(token)
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = crud.get_user_by_email(db, email)
    if user is None:
        raise credentials_exception
    return user

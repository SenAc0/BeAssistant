"""Operaciones de base de datos sobre usuarios."""
from sqlalchemy.orm import Session

from models import User
from schemas import UserCreate
from utils.security import hash_password, verify_password


def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()


def get_user(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()


def get_users(db: Session):
    return db.query(User).all()


def create_user(db: Session, user: UserCreate):
    db_user = User(
        name=user.name,
        email=user.email,
        hashed_password=hash_password(user.password),
        is_admin=getattr(user, "is_admin", False),
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def update_user(db: Session, user_id: int, new_email: str = None, new_password: str = None):
    user_instance = db.query(User).filter(User.id == user_id).first()
    if user_instance:
        if new_email:
            user_instance.email = new_email
        if new_password:
            user_instance.hashed_password = hash_password(new_password)
        db.commit()
        db.refresh(user_instance)
    return user_instance


def update_user_player_id(db: Session, user_id: int, player_id: str):
    """Actualiza el OneSignal player_id del usuario."""
    user_instance = db.query(User).filter(User.id == user_id).first()
    if user_instance:
        user_instance.onesignal_player_id = player_id
        db.commit()
        db.refresh(user_instance)
    return user_instance


def delete_user(db: Session, user_id: int):
    user_instance = db.query(User).filter(User.id == user_id).first()
    if user_instance:
        db.delete(user_instance)
        db.commit()
    return user_instance


def authenticate_user(db: Session, email: str, password: str):
    """Devuelve el usuario si las credenciales son válidas, `None` si no."""
    user = get_user_by_email(db, email)
    if not user or not verify_password(password, user.hashed_password):
        return None
    return user

from models import User

from schemas import UserCreate
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from fastapi import HTTPException

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# User CRUD operations

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def create_user(db: Session, user: UserCreate):
    hashed_pw = pwd_context.hash(user.password)
    db_user = User(email=user.email, hashed_password=hashed_pw)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)






def get_users(db: Session):
    return db.query(User).all()

def get_user(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()

def delete_user(db: Session, user_id: int):
    user_instance = db.query(User).filter(User.id == user_id).first()
    if user_instance:
        db.delete(user_instance)
        db.commit()
    return user_instance

def update_user(db: Session, user_id: int, new_email: str = None, new_password: str = None):
    user_instance = db.query(User).filter(User.id == user_id).first()
    if user_instance:
        if new_email:
            user_instance.email = new_email
        if new_password:
            user_instance.hashed_password = pwd_context.hash(new_password)
        db.commit()
        db.refresh(user_instance)
    return user_instance









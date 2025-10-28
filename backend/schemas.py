from pydantic import BaseModel
from datetime import datetime
from typing import List




class UserBase(BaseModel):
    email: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    class Config:
        #orm_mode = True
        from_attributes = True

from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional




class UserBase(BaseModel):
    email: str
    name: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    class Config:
        #orm_mode = True
        from_attributes = True


# ========= Meetings =========
class MeetingBase(BaseModel):
    title: str
    description: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    beacon_uuid: Optional[str] = None
    beacon_major: Optional[int] = None
    beacon_minor: Optional[int] = None


class MeetingCreate(MeetingBase):
    title: str


class Meeting(MeetingBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


# ========= Attendance =========
class AttendanceBase(BaseModel):
    meeting_id: int
    status: Optional[str] = "absent"  # present | late | absent


class AttendanceCreate(AttendanceBase):
    pass


class Attendance(BaseModel):
    id: int
    user_id: int
    meeting_id: int
    status: str
    marked_at: datetime

    class Config:
        from_attributes = True

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
    model_config = {"from_attributes": True}


# ========= Meetings =========
class MeetingBase(BaseModel):
    title: str
    description: Optional[str] = None
    start_time: Optional[datetime] = None
    # end_time is computed server-side for create; included in Meeting response only
    topics: Optional[str] = None
    repeat_weekly: Optional[bool] = False
    note: Optional[str] = None
    beacon_id: Optional[str] = None


class MeetingCreate(MeetingBase):
    title: str
    # duration in minutes to compute end_time
    duration_minutes: int


class Meeting(MeetingBase):
    id: int
    created_at: datetime
    end_time: Optional[datetime] = None
    coordinator_id: Optional[int] = None

    model_config = {"from_attributes": True}


# Schema con relaciones anidadas para detalles completos
class MeetingDetail(MeetingBase):
    id: int
    created_at: datetime
    end_time: Optional[datetime] = None
    coordinator_id: Optional[int] = None
    coordinator: Optional[User] = None
    location: Optional[str] = None  # Del beacon

    model_config = {"from_attributes": True}


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
    
    model_config = {"from_attributes": True}


# ========= Beacon =========
class BeaconBase(BaseModel):
    major: int
    minor: int
    location: str

class BeaconCreate(BeaconBase):
    id: str

class Beacon(BeaconBase):
    id: str
    last_used: datetime
    
    model_config = {"from_attributes": True}
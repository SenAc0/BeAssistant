from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class AttendanceBase(BaseModel):
    """Base fields for marking attendance for the current user."""
    meeting_id: int
    status: Optional[str] = "absent"  # present | late | absent


class AttendanceCreate(AttendanceBase):
    """Payload to mark the authenticated user's attendance."""
    pass


class AttendanceAssign(BaseModel):
    """Payload to assign/update attendance for a specific user and meeting."""
    user_id: int
    meeting_id: int
    status: Optional[str] = "absent"


class Attendance(BaseModel):
    """Attendance record returned by the API."""
    id: int
    user_id: int
    meeting_id: int
    status: str
    marked_at: datetime

    model_config = {"from_attributes": True}


class AttendanceWithUser(Attendance):
    """Attendance record including the user's name to simplify frontend lookups."""
    user_name: str

    model_config = {"from_attributes": True}

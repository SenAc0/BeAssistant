from datetime import datetime

from beanie import PydanticObjectId
from pydantic import BaseModel


class AttendanceBase(BaseModel):
    """Base fields for marking attendance for the current user."""
    meeting_id: PydanticObjectId
    status: str | None = "absent"  # present | late | absent


class AttendanceCreate(AttendanceBase):
    """Payload to mark the authenticated user's attendance."""
    pass


class AttendanceAssign(BaseModel):
    """Payload to assign/update attendance for a specific user and meeting."""
    user_id: PydanticObjectId
    meeting_id: PydanticObjectId
    status: str | None = "absent"


class Attendance(BaseModel):
    """Attendance record returned by the API."""
    id: PydanticObjectId
    user_id: PydanticObjectId
    meeting_id: PydanticObjectId
    status: str
    marked_at: datetime

    model_config = {"from_attributes": True}


class AttendanceWithUser(Attendance):
    """Attendance record including the user's name to simplify frontend lookups."""
    user_name: str

    model_config = {"from_attributes": True}

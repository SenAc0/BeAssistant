from datetime import datetime
from typing import Optional

from pydantic import BaseModel, field_serializer

from utils.timezone import to_chile

from .user import User


class _ChileTimes(BaseModel):
    """Serializa los datetime de la reunión a horario de Chile.

    Se persiste en UTC y la conversión ocurre solo al armar la respuesta, de modo
    que el objeto del ORM nunca se modifica (ver `utils/timezone.py`).
    """

    @field_serializer("start_time", "end_time", "created_at", check_fields=False)
    def _serialize_in_chile(self, value):
        return to_chile(value)


class MeetingBase(BaseModel):
    """Base meeting fields used for create/update and read."""
    title: str
    description: Optional[str] = None
    start_time: Optional[datetime] = None
    # end_time is computed server-side for create; included in Meeting response only
    topics: Optional[str] = None
    repeat_weekly: Optional[bool] = False
    note: Optional[str] = None
    location: Optional[str] = None
    beacon_id: Optional[str] = None


class MeetingCreate(MeetingBase):
    """Payload to create a meeting; end_time is computed from duration."""
    title: str
    # duration in minutes to compute end_time
    duration_minutes: int


class Meeting(_ChileTimes, MeetingBase):
    """Meeting model returned by list/detail endpoints."""
    id: int
    created_at: datetime
    end_time: Optional[datetime] = None
    coordinator_id: Optional[int] = None

    model_config = {"from_attributes": True}


# Schema con relaciones anidadas para detalles completos
class MeetingDetail(_ChileTimes, MeetingBase):
    """Meeting detail including coordinator and beacon location."""
    id: int
    created_at: datetime
    end_time: Optional[datetime] = None
    coordinator_id: Optional[int] = None
    coordinator: Optional[User] = None
    location: Optional[str] = None  # Del beacon

    model_config = {"from_attributes": True}

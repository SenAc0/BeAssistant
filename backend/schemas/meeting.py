from datetime import datetime

from beanie import PydanticObjectId
from pydantic import BaseModel, field_serializer

from utils.timezone import to_chile

from .user import User


class _ChileTimes(BaseModel):
    """Serializa los datetime de la reunión a horario de Chile.

    Se persiste en UTC y la conversión ocurre solo al armar la respuesta, de modo
    que el documento nunca se modifica (ver `utils/timezone.py`).
    """

    @field_serializer("start_time", "end_time", "created_at", check_fields=False)
    def _serialize_in_chile(self, value):
        return to_chile(value)


class MeetingBase(BaseModel):
    """Base meeting fields used for create/update and read."""
    title: str
    description: str | None = None
    start_time: datetime | None = None
    # end_time is computed server-side for create; included in Meeting response only
    topics: str | None = None
    repeat_weekly: bool | None = False
    note: str | None = None
    location: str | None = None
    beacon_id: str | None = None


class MeetingCreate(MeetingBase):
    """Payload to create a meeting; end_time is computed from duration."""
    title: str
    # duration in minutes to compute end_time
    duration_minutes: int


class Meeting(_ChileTimes, MeetingBase):
    """Meeting model returned by list/detail endpoints."""
    id: PydanticObjectId
    created_at: datetime
    end_time: datetime | None = None
    coordinator_id: PydanticObjectId | None = None

    model_config = {"from_attributes": True}


# Schema con relaciones anidadas para detalles completos
class MeetingDetail(_ChileTimes, MeetingBase):
    """Meeting detail including coordinator and beacon location."""
    id: PydanticObjectId
    created_at: datetime
    end_time: datetime | None = None
    coordinator_id: PydanticObjectId | None = None
    coordinator: User | None = None
    location: str | None = None  # Del beacon

    model_config = {"from_attributes": True}

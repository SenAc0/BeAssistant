from datetime import datetime, timezone

from beanie import Document, PydanticObjectId
from pydantic import Field
from pymongo import IndexModel


def _now_utc() -> datetime:
    return datetime.now(timezone.utc)


class Meeting(Document):
    title: str
    description: str | None = None
    start_time: datetime | None = None
    end_time: datetime | None = None

    # Nuevos campos solicitados
    topics: str | None = None
    repeat_weekly: bool = False
    note: str | None = None

    # Coordinador (quien creó la reunión)
    coordinator_id: PydanticObjectId | None = None

    # Beacon asociado por id (el id del hardware, ver models/beacon.py)
    beacon_id: str | None = None

    created_at: datetime = Field(default_factory=_now_utc)

    class Settings:
        name = "meetings"
        indexes = [
            IndexModel([("coordinator_id", 1)], name="ix_meeting_coordinator"),
            IndexModel([("beacon_id", 1)], name="ix_meeting_beacon"),
            IndexModel([("start_time", -1)], name="ix_meeting_start_time"),
        ]

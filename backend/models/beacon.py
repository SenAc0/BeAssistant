from datetime import datetime, timezone

from beanie import Document
from pydantic import Field
from pymongo import IndexModel


def _now_utc() -> datetime:
    return datetime.now(timezone.utc)


class Beacon(Document):
    """Beacon físico.

    El `_id` es el identificador del hardware (el UUID que emite el beacon), no
    un ObjectId: es una clave natural y es la que usan las reuniones y la app.
    """

    id: str = Field(default=None, alias="_id")
    major: int
    minor: int
    location: str
    name: str | None = None
    last_used: datetime = Field(default_factory=_now_utc)

    class Settings:
        name = "beacons"
        indexes = [
            IndexModel([("location", 1)], name="ix_beacon_location"),
            IndexModel([("major", 1), ("minor", 1)], name="ix_beacon_major_minor"),
        ]

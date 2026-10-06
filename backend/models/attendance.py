from datetime import datetime, timezone

from beanie import Document, PydanticObjectId
from pydantic import Field
from pymongo import IndexModel


def _now_utc() -> datetime:
    return datetime.now(timezone.utc)


class Attendance(Document):
    user_id: PydanticObjectId
    meeting_id: PydanticObjectId
    status: str = "absent"  # present | late | absent
    marked_at: datetime = Field(default_factory=_now_utc)

    class Settings:
        name = "attendance"
        indexes = [
            # Reemplaza al UniqueConstraint(user_id, meeting_id) de SQL:
            # un usuario no puede tener dos asistencias en la misma reunión.
            IndexModel(
                [("user_id", 1), ("meeting_id", 1)],
                unique=True,
                name="uq_attendance_user_meeting",
            ),
            IndexModel([("meeting_id", 1)], name="ix_attendance_meeting"),
        ]

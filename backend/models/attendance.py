from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, UniqueConstraint, func
from sqlalchemy.orm import relationship

from db import Base


class Attendance(Base):
    __tablename__ = "attendance"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    meeting_id = Column(Integer, ForeignKey("meetings.id", ondelete="CASCADE"), index=True, nullable=False)
    status = Column(String, nullable=False, default="absent")  # present | late | absent (default present)
    marked_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Constraints
    __table_args__ = (
        UniqueConstraint("user_id", "meeting_id", name="uq_attendance_user_meeting"),
    )

    # Relationships
    user = relationship("User", back_populates="attendances")
    meeting = relationship("Meeting", back_populates="attendances")

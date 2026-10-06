from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, func
from sqlalchemy.orm import relationship

from db import Base


class Meeting(Base):
    __tablename__ = "meetings"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    start_time = Column(DateTime(timezone=True), nullable=True)
    end_time = Column(DateTime(timezone=True), nullable=True)

    # Nuevos campos solicitados
    topics = Column(String, nullable=True)
    repeat_weekly = Column(Boolean, nullable=False, default=False)
    note = Column(String, nullable=True)

    # Coordinador (quien creó la reunión)
    coordinator_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), index=True, nullable=True)

    # Beacon asociado por id (ya no uuid/major/minor en la reunión)
    beacon_id = Column(String, ForeignKey("beacons.id", ondelete="SET NULL"), index=True, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Relationships
    attendances = relationship("Attendance", back_populates="meeting", cascade="all, delete-orphan")
    coordinator = relationship("User", back_populates="coordinated_meetings", foreign_keys=[coordinator_id])
    beacon = relationship("Beacon", back_populates="meetings", foreign_keys=[beacon_id])

from db import Base
from sqlalchemy import (
    Column,
    Integer,
    String,
    ForeignKey,
    DateTime,
    Boolean,
    func,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)

    # Relationships
    attendances = relationship("Attendance", back_populates="user", cascade="all, delete-orphan")


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


class Attendance(Base):
    __tablename__ = "attendance"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    meeting_id = Column(Integer, ForeignKey("meetings.id", ondelete="CASCADE"), index=True, nullable=False)
    status = Column(String, nullable=False, default="present")  # present | late | absent (default present)
    marked_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Constraints
    __table_args__ = (
        UniqueConstraint("user_id", "meeting_id", name="uq_attendance_user_meeting"),
    )

    # Relationships
    user = relationship("User", back_populates="attendances")
    meeting = relationship("Meeting", back_populates="attendances")


class Beacon(Base):
    __tablename__ = "beacons"

    id = Column(String, primary_key=True, index=True)
    major = Column(Integer, index=True)
    minor = Column(Integer, index=True)
    location = Column(String, index=True)
    last_used = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Relationships
    meetings = relationship("Meeting", back_populates="beacon")


# Add reverse relationship for meetings coordinated by a user
User.coordinated_meetings = relationship("Meeting", back_populates="coordinator", foreign_keys=[Meeting.coordinator_id])

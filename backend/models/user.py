from sqlalchemy import Boolean, Column, Integer, String
from sqlalchemy.orm import relationship

from db import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_admin = Column(Boolean, default=False)  # Boleano para saber si el usuario es admin
    onesignal_player_id = Column(String, nullable=True)  # Player ID de OneSignal para notificaciones

    # Relationships
    attendances = relationship("Attendance", back_populates="user", cascade="all, delete-orphan")
    coordinated_meetings = relationship(
        "Meeting",
        back_populates="coordinator",
        foreign_keys="Meeting.coordinator_id",
    )

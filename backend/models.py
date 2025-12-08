from db import Base
from sqlalchemy import (
    Column,
    Integer,
    String,
    ForeignKey,
    DateTime,
    Boolean,
    func,
    Float,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_admin = Column(Boolean, default=False) #Boleano para saber si el usuario es admin
    onesignal_player_id = Column(String, nullable=True)  # Player ID de OneSignal para notificaciones

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
    status = Column(String, nullable=False, default="absent")  # present | late | absent (default present)
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
    name = Column(String, index=True, nullable=True)
    # Relationships
    meetings = relationship("Meeting", back_populates="beacon")

    __table_args__ = (
        UniqueConstraint("id", "name", name="uq_beacon_id_name"),
    )


class MeetingReport(Base):
    __tablename__ = "meeting_reports"

    id = Column(Integer, primary_key=True, index=True)
    meeting_id = Column(Integer, ForeignKey("meetings.id", ondelete="CASCADE"), index=True, nullable=False)

    fecha = Column(String, nullable=False)
    nombre_reunion = Column(String, nullable=False)

    # Número total de invitados (usuarios asociados a la reunión, sin importar si asistieron)
    invitados_totales = Column(Integer, nullable=False, default=0)

    # Asistentes clasificados por estado
    asistentes_totales = Column(Integer, nullable=False, default=0)  # present + late
    llegadas_tarde = Column(Integer, nullable=False, default=0)      # late
    ausentes = Column(Integer, nullable=False, default=0)            # absent

    porcentaje_asistencias = Column(Float, nullable=False, default=0.0)
    porcentaje_ausencias = Column(Float, nullable=False, default=0.0)
    porcentaje_tarde = Column(Float, nullable=False, default=0.0)

    # Campos marcados con * (definir pero dejar sin uso por ahora)
    cantidad_asistencias = Column(Integer, nullable=True)
    cantidad_reuniones = Column(Integer, nullable=True)

    meeting = relationship("Meeting")


# Add reverse relationship for meetings coordinated by a user
User.coordinated_meetings = relationship("Meeting", back_populates="coordinator", foreign_keys=[Meeting.coordinator_id])

class GeneralReport(Base):
    __tablename__ = "general_reports"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)

    cantidad_asistencias = Column(Integer, nullable=False, default=0)
    cantidad_reuniones = Column(Integer, nullable=False, default=0)
    porcentaje_asistencias = Column(Float, nullable=False, default=0.0)
    porcentaje_ausencias = Column(Float, nullable=False, default=0.0)
    porcentaje_justificaciones = Column(Float, nullable=False, default=0.0)

    user = relationship("User")

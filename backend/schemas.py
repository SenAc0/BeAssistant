from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional




class UserBase(BaseModel):
    """Base fields for a user (shared by create/read)."""
    email: str
    name: str

class UserCreate(UserBase):
    """Payload to register a new user."""
    password: str

class User(UserBase):
    """User model returned by the API."""
    id: int
    model_config = {"from_attributes": True}


# ========= Meetings =========
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


class Meeting(MeetingBase):
    """Meeting model returned by list/detail endpoints."""
    id: int
    created_at: datetime
    end_time: Optional[datetime] = None
    coordinator_id: Optional[int] = None

    model_config = {"from_attributes": True}


# Schema con relaciones anidadas para detalles completos
class MeetingDetail(MeetingBase):
    """Meeting detail including coordinator and beacon location."""
    id: int
    created_at: datetime
    end_time: Optional[datetime] = None
    coordinator_id: Optional[int] = None
    coordinator: Optional[User] = None
    location: Optional[str] = None  # Del beacon

    model_config = {"from_attributes": True}


class GeneralReport(BaseModel):
    cantidad_asistencias: int
    cantidad_reuniones: int
    cantidad_atrasados: int
    porcentaje_asistencias: float
    porcentaje_ausencias: float
    porcentaje_atrasados: float


# ========= Attendance =========
class AttendanceBase(BaseModel):
    """Base fields for marking attendance for the current user."""
    meeting_id: int
    status: Optional[str] = "absent"  # present | late | absent


class AttendanceCreate(AttendanceBase):
    """Payload to mark the authenticated user's attendance."""
    pass


class AttendanceAssign(BaseModel):
    """Payload to assign/update attendance for a specific user and meeting."""
    user_id: int
    meeting_id: int
    status: Optional[str] = "absent"


class Attendance(BaseModel):
    """Attendance record returned by the API."""
    id: int
    user_id: int
    meeting_id: int
    status: str
    marked_at: datetime
    
    model_config = {"from_attributes": True}


class AttendanceWithUser(Attendance):
    """Attendance record including the user's name to simplify frontend lookups."""
    user_name: str

    model_config = {"from_attributes": True}


# ========= Beacon =========
class BeaconBase(BaseModel):
    """Base fields for a beacon device."""
    major: int
    minor: int
    location: str
    name: str

class BeaconCreate(BeaconBase):
    """Payload to register a new beacon."""
    id: str

class BeaconUpdate(BaseModel):
    major: int | None = None
    minor: int | None = None
    location: str | None = None
    name: str | None = None

class Beacon(BeaconBase):
    """Beacon resource as returned by the API."""
    id: str
    last_used: datetime
    
    model_config = {"from_attributes": True}


# ========= Meeting Report =========
class MeetingReport(BaseModel):
    """Reporte de una reunión específica."""
    id: int
    meeting_id: int
    fecha: str
    nombre_reunion: str
    invitados_totales: int
    asistentes_totales: int
    llegadas_tarde: int
    ausentes: int
    porcentaje_asistencias: float
    porcentaje_ausencias: float
    porcentaje_tarde: float

    # Campos marcados con * (definidos pero sin lógica todavía)
    cantidad_asistencias: int | None = None
    cantidad_reuniones: int | None = None

    model_config = {"from_attributes": True}
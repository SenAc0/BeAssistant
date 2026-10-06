"""Modelos SQLAlchemy.

Se importan todos aquí para que `Base.metadata` quede completo y para mantener
compatibilidad con el uso previo (`models.User`, `models.Meeting`, ...).
"""
from db import Base

from .attendance import Attendance
from .beacon import Beacon
from .meeting import Meeting
from .report import GeneralReport, MeetingReport
from .user import User

__all__ = [
    "Base",
    "Attendance",
    "Beacon",
    "Meeting",
    "GeneralReport",
    "MeetingReport",
    "User",
]

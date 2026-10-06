"""Documentos de MongoDB (Beanie).

`ALL_DOCUMENTS` es la lista que recibe `init_beanie`: todo documento nuevo tiene
que quedar registrado ahí o sus consultas fallarán al no estar inicializado.
"""
from .attendance import Attendance
from .beacon import Beacon
from .meeting import Meeting
from .report import GeneralReport, MeetingReport
from .user import User

ALL_DOCUMENTS = [
    User,
    Beacon,
    Meeting,
    Attendance,
    MeetingReport,
    GeneralReport,
]

__all__ = [
    "ALL_DOCUMENTS",
    "Attendance",
    "Beacon",
    "Meeting",
    "GeneralReport",
    "MeetingReport",
    "User",
]

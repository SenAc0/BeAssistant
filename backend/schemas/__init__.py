"""Schemas Pydantic expuestos por la API.

Se reexportan aquí para mantener el uso previo (`schemas.User`, `schemas.Meeting`, ...).
"""
from .attendance import (
    Attendance,
    AttendanceAssign,
    AttendanceBase,
    AttendanceCreate,
    AttendanceWithUser,
)
from .beacon import Beacon, BeaconBase, BeaconCreate, BeaconUpdate
from .meeting import Meeting, MeetingBase, MeetingCreate, MeetingDetail
from .report import GeneralReport, MeetingReport
from .user import LoginRequest, RegisterDeviceRequest, User, UserBase, UserCreate

__all__ = [
    "Attendance",
    "AttendanceAssign",
    "AttendanceBase",
    "AttendanceCreate",
    "AttendanceWithUser",
    "Beacon",
    "BeaconBase",
    "BeaconCreate",
    "BeaconUpdate",
    "Meeting",
    "MeetingBase",
    "MeetingCreate",
    "MeetingDetail",
    "GeneralReport",
    "MeetingReport",
    "LoginRequest",
    "RegisterDeviceRequest",
    "User",
    "UserBase",
    "UserCreate",
]

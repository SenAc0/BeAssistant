"""Capa de acceso a datos.

Se reexporta todo para mantener el uso previo (`crud.create_user`, `crud.get_meeting`, ...).
"""
from .attendance import (
    add_attendance,
    get_attendance_for_user,
    list_attendance_for_meeting,
    list_attendance_for_meeting_with_name_user,
    list_attendance_for_user,
    mark_attendance,
    remove_attendance,
)
from .beacon import (
    create_beacon,
    delete_beacon,
    get_beacon,
    get_beacon_by_location,
    get_beacons,
    update_beacon,
    update_beacon_last_used,
)
from .meeting import create_meeting, get_meeting, list_meetings, list_meetings_for_user
from .report import (
    generate_general_report,
    generate_meeting_report,
    get_meeting_report,
)
from .user import (
    authenticate_user,
    create_user,
    delete_user,
    get_user,
    get_user_by_email,
    get_users,
    update_user,
    update_user_player_id,
)

__all__ = [
    "add_attendance",
    "get_attendance_for_user",
    "list_attendance_for_meeting",
    "list_attendance_for_meeting_with_name_user",
    "list_attendance_for_user",
    "mark_attendance",
    "remove_attendance",
    "create_beacon",
    "delete_beacon",
    "get_beacon",
    "get_beacon_by_location",
    "get_beacons",
    "update_beacon",
    "update_beacon_last_used",
    "create_meeting",
    "get_meeting",
    "list_meetings",
    "list_meetings_for_user",
    "generate_general_report",
    "generate_meeting_report",
    "get_meeting_report",
    "authenticate_user",
    "create_user",
    "delete_user",
    "get_user",
    "get_user_by_email",
    "get_users",
    "update_user",
    "update_user_player_id",
]

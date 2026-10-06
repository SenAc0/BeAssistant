"""Operaciones de base de datos sobre reuniones."""
from datetime import timedelta, timezone

from beanie import PydanticObjectId
from fastapi import HTTPException

from models import Attendance, Beacon, Meeting, User
from schemas import MeetingCreate
from utils.timezone import CHILE_TZ

# En Mongo "no tiene fecha" es null o campo ausente; este filtro pide que exista.
_HAS_TIME_WINDOW = {
    "start_time": {"$ne": None},
    "end_time": {"$ne": None},
}


def _overlap_filter(start_utc, end_utc) -> dict:
    """Reuniones cuya ventana se cruza con [start_utc, end_utc)."""
    return {
        "start_time": {"$ne": None, "$lt": end_utc},
        "end_time": {"$ne": None, "$gt": start_utc},
    }


async def _validate_no_overlap(meeting: MeetingCreate, start_utc, end_utc) -> None:
    """Valida que no exista otra reunión solapada en el mismo beacon o ubicación."""
    # If a beacon_id is provided, optionally validate it exists
    beacon_obj = None
    if meeting.beacon_id:
        beacon_obj = await Beacon.get(meeting.beacon_id)
        if not beacon_obj:
            raise HTTPException(status_code=404, detail="Beacon not found")

    # 1) Same beacon overlap check
    if meeting.beacon_id:
        conflict_beacon = await Meeting.find_one(
            {"beacon_id": meeting.beacon_id, **_overlap_filter(start_utc, end_utc)}
        )
        if conflict_beacon:
            raise HTTPException(
                status_code=400,
                detail=(
                    "Overlap detected: another meeting is scheduled on the same beacon "
                    "within the selected time window"
                ),
            )

    # 2) Same location (room) overlap check
    # Determine the location to compare: payload location, otherwise beacon's location
    location_key = meeting.location or (beacon_obj.location if beacon_obj else None)
    if location_key:
        # Sin JOIN: primero los beacons de esa ubicación, después sus reuniones.
        beacon_ids = [
            b.id for b in await Beacon.find(Beacon.location == location_key).to_list()
        ]
        if beacon_ids:
            conflict_location = await Meeting.find_one(
                {"beacon_id": {"$in": beacon_ids}, **_overlap_filter(start_utc, end_utc)}
            )
            if conflict_location:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        "Overlap detected: another meeting is scheduled in the same location "
                        "within the selected time window"
                    ),
                )


async def _ensure_coordinator_attendance(
    meeting_id: PydanticObjectId, coordinator_id: PydanticObjectId
) -> None:
    """Crea la fila de Attendance del coordinador ('absent' = invitado sin confirmar)."""
    try:
        existing_att = await Attendance.find_one(
            Attendance.user_id == coordinator_id,
            Attendance.meeting_id == meeting_id,
        )
        if not existing_att:
            # Verificar que el usuario existe antes de crear la asistencia
            if await User.get(coordinator_id):
                await Attendance(
                    user_id=coordinator_id, meeting_id=meeting_id, status="absent"
                ).insert()
    except Exception:
        # No queremos que la creación de la asistencia bloquee la creación de la reunión.
        pass


async def create_meeting(
    meeting: MeetingCreate, coordinator_id: PydanticObjectId | None = None
) -> Meeting:
    # Compute end_time from start_time + duration_minutes
    start_utc = None
    end_utc = None
    if meeting.start_time is not None and meeting.duration_minutes is not None:
        start = meeting.start_time
        # Normalize to timezone-aware Chile if naive
        if start.tzinfo is None:
            start = start.replace(tzinfo=CHILE_TZ)
        # convert to UTC for saving (tz-aware UTC)
        start_utc = start.astimezone(timezone.utc)
        end_utc = start_utc + timedelta(minutes=meeting.duration_minutes)
    # If we don't have times, skip overlap validation and let it be created as-is

    if start_utc and end_utc:
        await _validate_no_overlap(meeting, start_utc, end_utc)

    db_meeting = await Meeting(
        title=meeting.title,
        description=meeting.description,
        start_time=start_utc,
        end_time=end_utc,
        topics=meeting.topics,
        repeat_weekly=bool(meeting.repeat_weekly) if meeting.repeat_weekly is not None else False,
        note=meeting.note,
        coordinator_id=coordinator_id,
        beacon_id=meeting.beacon_id,
    ).insert()

    if coordinator_id is not None:
        await _ensure_coordinator_attendance(db_meeting.id, coordinator_id)

    return db_meeting


async def list_meetings() -> list[Meeting]:
    # Mongo ordena null por debajo de cualquier fecha, así que en descendente
    # las reuniones sin fecha quedan al final (equivale al nullslast de antes).
    return await Meeting.find_all().sort(-Meeting.start_time).to_list()


async def get_meeting(meeting_id: PydanticObjectId) -> Meeting | None:
    return await Meeting.get(meeting_id)


async def list_meetings_for_user(user_id: PydanticObjectId) -> list[Meeting]:
    # Reuniones donde fue agregado como asistente
    attended_ids = [
        att.meeting_id
        for att in await Attendance.find(Attendance.user_id == user_id).to_list()
    ]

    # Unir con las que coordina, sin duplicados (el $or los evita por sí mismo)
    return (
        await Meeting.find(
            {"$or": [{"coordinator_id": user_id}, {"_id": {"$in": attended_ids}}]}
        )
        .sort(-Meeting.start_time)
        .to_list()
    )

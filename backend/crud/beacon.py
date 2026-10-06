"""Operaciones de base de datos sobre beacons."""
from datetime import datetime, timezone

from models import Beacon
from schemas import BeaconCreate, BeaconUpdate


async def create_beacon(beacon: BeaconCreate) -> Beacon:
    db_beacon = Beacon(
        id=beacon.id,
        major=beacon.major,
        minor=beacon.minor,
        location=beacon.location,
        name=beacon.name,
    )
    return await db_beacon.insert()


async def get_beacons() -> list[Beacon]:
    return await Beacon.find_all().to_list()


async def get_beacon(beacon_id: str) -> Beacon | None:
    return await Beacon.get(beacon_id)


async def get_beacon_by_location(location: str) -> Beacon | None:
    return await Beacon.find_one(Beacon.location == location)


async def update_beacon(beacon_id: str, beacon_data: BeaconUpdate) -> Beacon | None:
    beacon = await Beacon.get(beacon_id)
    if not beacon:
        return None

    if beacon_data.major is not None:
        beacon.major = beacon_data.major

    if beacon_data.minor is not None:
        beacon.minor = beacon_data.minor

    if beacon_data.location is not None:
        beacon.location = beacon_data.location

    beacon.last_used = datetime.now(timezone.utc)

    await beacon.save()
    return beacon


async def update_beacon_last_used(beacon_id: str) -> Beacon | None:
    beacon = await Beacon.get(beacon_id)
    if beacon:
        beacon.last_used = datetime.now(timezone.utc)
        await beacon.save()
    return beacon


async def delete_beacon(beacon_id: str) -> Beacon | None:
    beacon = await Beacon.get(beacon_id)
    if beacon:
        await beacon.delete()
    return beacon

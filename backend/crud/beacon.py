"""Operaciones de base de datos sobre beacons."""
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from models import Beacon
from schemas import BeaconCreate, BeaconUpdate


def create_beacon(db: Session, beacon: BeaconCreate):
    db_beacon = Beacon(
        id=beacon.id,
        major=beacon.major,
        minor=beacon.minor,
        location=beacon.location,
        name=beacon.name,
    )
    db.add(db_beacon)
    db.commit()
    db.refresh(db_beacon)
    return db_beacon


def get_beacons(db: Session):
    return db.query(Beacon).all()


def get_beacon(db: Session, beacon_id: str):
    return db.query(Beacon).filter(Beacon.id == beacon_id).first()


def get_beacon_by_location(db: Session, location: str):
    return db.query(Beacon).filter(Beacon.location == location).first()


def update_beacon(db: Session, beacon_id: str, beacon_data: BeaconUpdate):
    beacon = db.query(Beacon).filter(Beacon.id == beacon_id).first()
    if not beacon:
        return None

    if beacon_data.major is not None:
        beacon.major = beacon_data.major

    if beacon_data.minor is not None:
        beacon.minor = beacon_data.minor

    if beacon_data.location is not None:
        beacon.location = beacon_data.location

    beacon.last_used = datetime.now(timezone.utc)

    db.commit()
    db.refresh(beacon)
    return beacon


def update_beacon_last_used(db: Session, beacon_id: str):
    beacon = db.query(Beacon).filter(Beacon.id == beacon_id).first()
    if beacon:
        beacon.last_used = datetime.now(timezone.utc)
        db.commit()
        db.refresh(beacon)
    return beacon


def delete_beacon(db: Session, beacon_id: str):
    beacon = db.query(Beacon).filter(Beacon.id == beacon_id).first()
    if beacon:
        db.delete(beacon)
        db.commit()
    return beacon

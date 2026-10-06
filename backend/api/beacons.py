"""Endpoints de beacons."""
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

import crud
import schemas
from db import get_db

router = APIRouter(prefix="/beacons", tags=["beacons"])

BEACON_NOT_FOUND = "Beacon not found"


@router.post("", response_model=schemas.Beacon)
def create_beacon(beacon: schemas.BeaconCreate, db: Session = Depends(get_db)):
    return crud.create_beacon(db, beacon)


@router.get("", response_model=List[schemas.Beacon])
def list_beacons(db: Session = Depends(get_db)):
    return crud.get_beacons(db)


@router.get("/{beacon_id}", response_model=schemas.Beacon)
def get_beacon(beacon_id: str, db: Session = Depends(get_db)):
    beacon = crud.get_beacon(db, beacon_id)
    if not beacon:
        raise HTTPException(status_code=404, detail=BEACON_NOT_FOUND)
    return beacon


@router.put("/{beacon_id}", response_model=schemas.Beacon)
def update_beacon(beacon_id: str, beacon: schemas.BeaconUpdate, db: Session = Depends(get_db)):
    updated = crud.update_beacon(db, beacon_id, beacon)
    if not updated:
        raise HTTPException(status_code=404, detail=BEACON_NOT_FOUND)
    return updated


@router.delete("/{beacon_id}")
def delete_beacon(beacon_id: str, db: Session = Depends(get_db)):
    deleted = crud.delete_beacon(db, beacon_id)
    if not deleted:
        raise HTTPException(status_code=404, detail=BEACON_NOT_FOUND)
    return {"message": "Beacon deleted successfully"}

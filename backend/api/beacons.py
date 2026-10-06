"""Endpoints de beacons."""
from typing import List

from fastapi import APIRouter, Depends, HTTPException

import crud
import schemas

router = APIRouter(prefix="/beacons", tags=["beacons"])

BEACON_NOT_FOUND = "Beacon not found"


@router.post("", response_model=schemas.Beacon)
async def create_beacon(beacon: schemas.BeaconCreate):
    return await crud.create_beacon(beacon)


@router.get("", response_model=List[schemas.Beacon])
async def list_beacons():
    return await crud.get_beacons()


@router.get("/{beacon_id}", response_model=schemas.Beacon)
async def get_beacon(beacon_id: str):
    beacon = await crud.get_beacon(beacon_id)
    if not beacon:
        raise HTTPException(status_code=404, detail=BEACON_NOT_FOUND)
    return beacon


@router.put("/{beacon_id}", response_model=schemas.Beacon)
async def update_beacon(beacon_id: str, beacon: schemas.BeaconUpdate):
    updated = await crud.update_beacon(beacon_id, beacon)
    if not updated:
        raise HTTPException(status_code=404, detail=BEACON_NOT_FOUND)
    return updated


@router.delete("/{beacon_id}")
async def delete_beacon(beacon_id: str):
    deleted = await crud.delete_beacon(beacon_id)
    if not deleted:
        raise HTTPException(status_code=404, detail=BEACON_NOT_FOUND)
    return {"message": "Beacon deleted successfully"}

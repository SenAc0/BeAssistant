from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class BeaconBase(BaseModel):
    """Base fields for a beacon device."""
    major: int
    minor: int
    location: str
    name: Optional[str] = None


class BeaconCreate(BaseModel):
    """Payload to register a new beacon."""
    id: str
    major: int
    minor: int
    location: str
    name: Optional[str] = None


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

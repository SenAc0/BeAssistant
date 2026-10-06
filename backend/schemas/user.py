from typing import Optional

from pydantic import BaseModel


class UserBase(BaseModel):
    """Base fields for a user (shared by create/read)."""
    email: str
    name: str


class UserCreate(UserBase):
    """Payload to register a new user."""
    password: str
    is_admin: bool = False


class User(UserBase):
    """User model returned by the API."""
    id: int
    is_admin: bool
    onesignal_player_id: Optional[str] = None

    model_config = {"from_attributes": True}


class LoginRequest(BaseModel):
    """Credenciales para iniciar sesión."""
    email: str
    password: str


class RegisterDeviceRequest(BaseModel):
    """Payload para registrar el player_id de OneSignal del dispositivo."""
    player_id: str

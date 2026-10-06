from beanie import Document
from pydantic import Field
from pymongo import IndexModel


class User(Document):
    name: str
    email: str
    hashed_password: str
    is_admin: bool = False  # Boleano para saber si el usuario es admin
    onesignal_player_id: str | None = None  # Player ID de OneSignal para notificaciones

    class Settings:
        name = "users"
        indexes = [
            IndexModel([("email", 1)], unique=True, name="uq_user_email"),
        ]

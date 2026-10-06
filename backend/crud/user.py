"""Operaciones de base de datos sobre usuarios."""
from beanie import PydanticObjectId

from models import User
from schemas import UserCreate
from utils.security import hash_password, verify_password


async def get_user_by_email(email: str) -> User | None:
    return await User.find_one(User.email == email)


async def get_user(user_id: PydanticObjectId) -> User | None:
    return await User.get(user_id)


async def get_users() -> list[User]:
    return await User.find_all().to_list()


async def create_user(user: UserCreate) -> User:
    db_user = User(
        name=user.name,
        email=user.email,
        hashed_password=hash_password(user.password),
        is_admin=getattr(user, "is_admin", False),
    )
    return await db_user.insert()


async def update_user(
    user_id: PydanticObjectId,
    new_email: str | None = None,
    new_password: str | None = None,
) -> User | None:
    user_instance = await User.get(user_id)
    if user_instance:
        if new_email:
            user_instance.email = new_email
        if new_password:
            user_instance.hashed_password = hash_password(new_password)
        await user_instance.save()
    return user_instance


async def update_user_player_id(user_id: PydanticObjectId, player_id: str) -> User | None:
    """Actualiza el OneSignal player_id del usuario."""
    user_instance = await User.get(user_id)
    if user_instance:
        user_instance.onesignal_player_id = player_id
        await user_instance.save()
    return user_instance


async def delete_user(user_id: PydanticObjectId) -> User | None:
    user_instance = await User.get(user_id)
    if user_instance:
        await user_instance.delete()
    return user_instance


async def authenticate_user(email: str, password: str) -> User | None:
    """Devuelve el usuario si las credenciales son válidas, `None` si no."""
    user = await get_user_by_email(email)
    if not user or not verify_password(password, user.hashed_password):
        return None
    return user

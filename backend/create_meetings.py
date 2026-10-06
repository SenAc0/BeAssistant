import argparse
import asyncio
from datetime import datetime, timedelta, timezone

import crud
import db
import schemas
from models import User

# El coordinador ya no puede ser un id fijo (antes era 1): con Mongo los ids son
# ObjectId, así que se resuelve por email o se toma el primer usuario de la base.
DEFAULT_BEACON_ID = 'fda50693a4e24fb1afcfc6eb07647825271b4cb99c'


def parse_args():
    p = argparse.ArgumentParser(description="Crear 10 reuniones de prueba")
    p.add_argument("--coordinator-email", default=None,
                   help="Email del coordinador (por defecto, el primer usuario de la base)")
    p.add_argument("--beacon-id", default=DEFAULT_BEACON_ID, help="ID del beacon a asociar")
    return p.parse_args()


async def _resolve_coordinator(email: str | None) -> User:
    if email:
        user = await crud.get_user_by_email(email)
        if not user:
            raise SystemExit(f"No existe un usuario con email {email}. Corre create_users.py primero.")
        return user

    user = await User.find_all().first_or_none()
    if not user:
        raise SystemExit("No hay usuarios en la base. Corre create_users.py primero.")
    return user


async def create_test_meetings(coordinator_email=None, beacon_id=DEFAULT_BEACON_ID):
    print("Using MONGODB_URL:", db.MONGODB_URL, "| db:", db.MONGODB_DB)
    await db.init_db()

    coordinator = await _resolve_coordinator(coordinator_email)
    print(f"Coordinador: {coordinator.name} <{coordinator.email}> (id={coordinator.id})")

    if not await crud.get_beacon(beacon_id):
        print(f"Aviso: el beacon '{beacon_id}' no existe; las reuniones se crearan sin beacon.")
        beacon_id = None

    created = []
    base = datetime.now(timezone.utc).replace(hour=9, minute=0, second=0, microsecond=0)
    existing_titles = {m.title for m in await crud.list_meetings()}

    for i in range(10):
        title = f"Reunión de prueba {i}"
        # avoid duplicate titles
        if title in existing_titles:
            print(f"Meeting with title '{title}' already exists")
            continue

        meeting_in = schemas.MeetingCreate(
            title=title,
            description=f"Descripción de la reunión de prueba {i}",
            start_time=base + timedelta(days=i),
            duration_minutes=60,
            topics="Prueba, Demo",
            repeat_weekly=False,
            note="Reunión creada por script de prueba",
            beacon_id=beacon_id,
        )

        try:
            m = await crud.create_meeting(meeting_in, coordinator_id=coordinator.id)
            print(f"Created meeting id={m.id} title='{m.title}' start={m.start_time}")
            created.append(m)
        except Exception:
            import traceback
            print(f"Error creating meeting '{title}':")
            traceback.print_exc()

    return created


async def main():
    args = parse_args()
    try:
        await create_test_meetings(args.coordinator_email, args.beacon_id)
    finally:
        await db.close_db()


if __name__ == '__main__':
    asyncio.run(main())

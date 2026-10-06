# create 10 users for testing
import asyncio

import crud
import db
import schemas


async def create_test_users():
    """Inserta 10 usuarios de prueba."""
    await db.init_db()

    created = []
    for i in range(10):
        email = f"testuser{i}@example.com"
        # avoid duplicates
        existing = await crud.get_user_by_email(email)
        if existing:
            print(f"User with email {email} already exists (id={existing.id})")
            created.append(existing)
            continue

        user_in = schemas.UserCreate(
            name=f"Test User {i}",
            email=email,
            password="password",
        )
        u = await crud.create_user(user_in)
        print(f"Created user id={u.id} email={u.email}")
        created.append(u)

    return created


# intento de crear un admin
async def create_admin_user():
    await db.init_db()

    email = "admin@example.com"

    # Verificar si ya existe
    existing = await crud.get_user_by_email(email)
    if existing:
        print(f"Admin ya existe: id={existing.id}, email={existing.email}")
        return existing

    # CREAR ADMIN
    admin_user = schemas.UserCreate(
        name="Jefe Seba",
        email=email,
        password="123456",
        is_admin=True,
    )

    user = await crud.create_user(admin_user)
    print(f"Admin creado correctamente: id={user.id}, email={user.email}")
    return user


async def main():
    try:
        await create_test_users()
        # await create_admin_user()
    finally:
        await db.close_db()


if __name__ == '__main__':
    asyncio.run(main())

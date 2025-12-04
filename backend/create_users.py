# create 10 users for testing

from sqlalchemy.orm import Session
import crud, schemas, db


def create_test_users():
    # Create a DB session and insert 10 users for testing.
    session = db.SessionLocal()
    try:
        created = []
        for i in range(10):
            email = f"testuser{i}@example.com"
            # avoid duplicates
            existing = crud.get_user_by_email(session, email=email)
            if existing:
                print(f"User with email {email} already exists (id={existing.id})")
                created.append(existing)
                continue

            user_in = schemas.UserCreate(
                name=f"Test User {i}",
                email=email,
                password="password"
            )
            u = crud.create_user(session, user=user_in)
            print(f"Created user id={u.id} email={u.email}")
            created.append(u)

        return created
    finally:
        session.close()
#intento de crear un admin
def create_admin_user():
    session = db.SessionLocal()
    try:
        email = "admin@example.com"

        # Verificar si ya existe
        existing = crud.get_user_by_email(session, email=email)
        if existing:
            print(f"Admin ya existe: id={existing.id}, email={existing.email}")
            return existing

        # CREAR ADMIN
        admin_user = schemas.UserCreate(
            name="Jefe Seba",
            email=email,
            password="123456",
            is_admin=True 
        )

        user = crud.create_user(session, admin_user)
        session.commit()

        print(f"Admin creado correctamente: id={user.id}, email={user.email}")
        return user

    finally:
        session.close()
        
        
if __name__ == '__main__':
    create_test_users()
    #create_admin_user()

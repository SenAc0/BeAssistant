from datetime import datetime, timezone, timedelta
import crud, schemas, db


def create_test_meetings():
    # Diagnostic: print DB URL and ensure tables exist
    print("Using DATABASE_URL:", getattr(db, 'DATABASE_URL', '<not set>'))
    try:
        db.create_table()
    except Exception as e:
        print("Warning: db.create_table() failed:", e)

    session = db.SessionLocal()
    try:
        created = []
        base = datetime.now(timezone.utc).replace(hour=9, minute=0, second=0, microsecond=0)
        for i in range(10):
            title = f"Reunión de prueba {i}"
            # avoid duplicate titles
            existing = [m for m in crud.list_meetings(session) if m.title == title]
            if existing:
                print(f"Meeting with title '{title}' already exists (id={existing[0].id})")
                created.append(existing[0])
                continue

            start = base + timedelta(days=i)
            # For testing: attach beacon id (user provided earlier) and set coordinator to user id 1
            meeting_in = schemas.MeetingCreate(
                title=title,
                description=f"Descripción de la reunión de prueba {i}",
                start_time=start,
                duration_minutes=60,
                topics="Prueba, Demo",
                repeat_weekly=False,
                note="Reunión creada por script de prueba",
                beacon_id='fda50693a4e24fb1afcfc6eb07647825271b4cb99c',
            )

            # Use coordinator_id=1 for testing
            try:
                m = crud.create_meeting(session, meeting=meeting_in, coordinator_id=1)
                print(f"Created meeting id={m.id} title='{m.title}' start={m.start_time}")
            except Exception as e:
                import traceback
                print(f"Error creating meeting '{title}':")
                traceback.print_exc()
                # rollback and continue to attempt next
                try:
                    session.rollback()
                except Exception:
                    pass
            created.append(m)

        return created
    finally:
        session.close()


if __name__ == '__main__':
    create_test_meetings()

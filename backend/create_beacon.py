import argparse
from pprint import pprint
import db
import crud
import schemas



# USAR ASI:
# docker exec -it beacon_backend python create_beacon.py --id fda50693a4e24fb1afcfc6eb07647825271b4cb99c --major 100 --minor 1 --location "Sala A"


def parse_args():
    p = argparse.ArgumentParser(description="Crear un beacon de prueba en la base de datos")
    p.add_argument("--id", required=True, help="ID del beacon (UUID u otro identificador)")
    p.add_argument("--major", type=int, default=0, help="Major del beacon (por defecto 0)")
    p.add_argument("--minor", type=int, default=0, help="Minor del beacon (por defecto 0)")
    p.add_argument("--location", type=str, default="auto-created", help="Ubicación descrita del beacon")
    p.add_argument("--force", action="store_true", help="Si ya existe, forzar una actualización con los valores provistos")
    return p.parse_args()


def main():
    args = parse_args()
    # Print DB URL and ensure tables exist
    print("Using DATABASE_URL:", getattr(db, 'DATABASE_URL', '<not set>'))
    try:
        db.create_table()
    except Exception as e:
        print("Warning: db.create_table() failed:", e)

    session = db.SessionLocal()
    try:
        existing = crud.get_beacon(session, args.id)
        if existing:
            print(f"Beacon con id='{args.id}' ya existe: ")
            pprint({
                'id': existing.id,
                'major': existing.major,
                'minor': existing.minor,
                'location': existing.location,
                'last_used': getattr(existing, 'last_used', None),
            })
            if args.force:
                print("--force especificado: actualizando beacon con los nuevos valores...")
                beacon_in = schemas.BeaconCreate(id=args.id, major=args.major, minor=args.minor, location=args.location)
                updated = crud.update_beacon(session, args.id, beacon_in)
                print("Beacon actualizado:")
                pprint({
                    'id': updated.id,
                    'major': updated.major,
                    'minor': updated.minor,
                    'location': updated.location,
                    'last_used': getattr(updated, 'last_used', None),
                })
            else:
                print("No se realizaron cambios. Usa --force para forzar actualización.")
            return

        # Crear nuevo beacon
        beacon_in = schemas.BeaconCreate(id=args.id, major=args.major, minor=args.minor, location=args.location)
        try:
            created = crud.create_beacon(session, beacon_in)
            print("Beacon creado correctamente:")
            pprint({
                'id': created.id,
                'major': created.major,
                'minor': created.minor,
                'location': created.location,
                'last_used': getattr(created, 'last_used', None),
            })
        except Exception as e:
            # Print traceback to help diagnose commit/constraint issues
            import traceback
            print("Error creating beacon (exception during create_beacon):")
            traceback.print_exc()
            # Optionally rollback
            try:
                session.rollback()
            except Exception:
                pass

    finally:
        session.close()


if __name__ == '__main__':
    main()

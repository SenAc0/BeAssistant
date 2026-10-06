import argparse
import asyncio
from pprint import pprint

import crud
import db
import schemas

# USAR ASI:
# docker exec -it beacon_backend python create_beacon.py --id fda50693a4e24fb1afcfc6eb07647825271b4cb99c --major 100 --minor 1 --location "Sala A"


def parse_args():
    p = argparse.ArgumentParser(description="Crear un beacon de prueba en la base de datos")
    p.add_argument("--id", required=True, help="ID del beacon (UUID u otro identificador)")
    p.add_argument("--major", type=int, default=0, help="Major del beacon (por defecto 0)")
    p.add_argument("--minor", type=int, default=0, help="Minor del beacon (por defecto 0)")
    p.add_argument("--location", type=str, default="auto-created", help="Ubicación descrita del beacon")
    p.add_argument("--name", type=str, default="Beacon 1", help="Nombre del beacon")
    p.add_argument("--force", action="store_true", help="Si ya existe, forzar una actualización con los valores provistos")
    return p.parse_args()


def _show(beacon):
    pprint({
        'id': beacon.id,
        'major': beacon.major,
        'minor': beacon.minor,
        'location': beacon.location,
        'name': beacon.name,
        'last_used': getattr(beacon, 'last_used', None),
    })


async def main():
    args = parse_args()
    print("Using MONGODB_URL:", db.MONGODB_URL, "| db:", db.MONGODB_DB)
    # Beanie crea los indices declarados en models/ al inicializar.
    await db.init_db()

    try:
        existing = await crud.get_beacon(args.id)
        if existing:
            print(f"Beacon con id='{args.id}' ya existe: ")
            _show(existing)
            if args.force:
                print("--force especificado: actualizando beacon con los nuevos valores...")
                beacon_in = schemas.BeaconUpdate(
                    major=args.major, minor=args.minor, location=args.location, name=args.name
                )
                updated = await crud.update_beacon(args.id, beacon_in)
                print("Beacon actualizado:")
                _show(updated)
            else:
                print("No se realizaron cambios. Usa --force para forzar actualización.")
            return

        # Crear nuevo beacon
        beacon_in = schemas.BeaconCreate(
            id=args.id, major=args.major, minor=args.minor, location=args.location, name=args.name
        )
        try:
            created = await crud.create_beacon(beacon_in)
            print("Beacon creado correctamente:")
            _show(created)
        except Exception:
            import traceback
            print("Error creating beacon (exception during create_beacon):")
            traceback.print_exc()
    finally:
        await db.close_db()


if __name__ == '__main__':
    asyncio.run(main())

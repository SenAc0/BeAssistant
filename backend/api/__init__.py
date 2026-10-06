"""Router raíz de la API: agrupa todos los routers por recurso."""
from fastapi import APIRouter

from api import attendance, auth, beacons, meetings, reports, users

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(meetings.router)
api_router.include_router(reports.router)
api_router.include_router(attendance.router)
api_router.include_router(beacons.router)

__all__ = ["api_router"]

"""Punto de entrada de la aplicación FastAPI.

Aquí solo vive la configuración de la app (middleware, ciclo de vida y el registro
de routers). Los endpoints están en `api/`, la lógica de datos en `crud/`,
los documentos de Mongo en `models/`, los schemas en `schemas/` y lo transversal
en `utils/`.
"""
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api import api_router
from db import MONGODB_DB, MONGODB_URL, close_db, init_db
from utils import scheduler

# Cargar variables de entorno
load_dotenv()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("=" * 60, flush=True)
    print("INICIANDO APLICACION", flush=True)
    print("=" * 60, flush=True)

    # Mongo primero: el scheduler y los endpoints necesitan Beanie inicializado.
    # Beanie también crea aquí los índices declarados en models/ (no hay migraciones).
    await init_db()
    print(f"MongoDB conectado: {MONGODB_URL} (db: {MONGODB_DB})", flush=True)

    try:
        scheduler.start_scheduler()
        print("Scheduler iniciado correctamente", flush=True)
    except Exception as e:
        print(f"Error iniciando scheduler: {e}", flush=True)
        import traceback

        traceback.print_exc()
    print("=" * 60, flush=True)
    yield
    # Shutdown
    print("DETENIENDO APLICACION", flush=True)
    scheduler.stop_scheduler()
    await close_db()


# Crear la aplicación
app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Para pruebas, luego restringe
    allow_credentials=True,
    allow_methods=["*"],  # ← IMPORTANTE para OPTIONS
    allow_headers=["*"],
)


# Endpoint de prueba
@app.get("/")
def read_root():
    return {"message": "FastAPI"}


# Todos los endpoints de la API
app.include_router(api_router)

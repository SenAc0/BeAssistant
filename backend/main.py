"""Punto de entrada de la aplicación FastAPI.

Aquí solo vive la configuración de la app (middleware, ciclo de vida y el registro
de routers). Los endpoints están en `api/`, la lógica de datos en `crud/`,
los modelos en `models/`, los schemas en `schemas/` y lo transversal en `utils/`.
"""
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api import api_router
from utils import scheduler

# Cargar variables de entorno
load_dotenv()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("=" * 60, flush=True)
    print("INICIANDO APLICACION", flush=True)
    print("=" * 60, flush=True)
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


##############################

# Crear todas las tablas automáticamente (esto crea lo que esta en models/)
# ESTO ES TEMPORAL, DEBERIAMOS USAR ALEMBIC PARA MIGRACIONES

# from db import engine
# import models
# models.Base.metadata.drop_all(bind=engine)   # Descomentar para borrar todas las tablas (solo en desarrollo)
# models.Base.metadata.create_all(bind=engine) # Crear tablas según modelos definidos (solo en desarrollo)

##############################

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

"""Conexión a MongoDB e inicialización de Beanie.

A diferencia de SQLAlchemy, Beanie no necesita una sesión por request: los
documentos quedan ligados al cliente al inicializarse, así que los endpoints
no reciben ninguna dependencia de base de datos.

El cliente es `AsyncMongoClient` de PyMongo (el async nativo del driver). Beanie 2
dejó de usar Motor, que quedó deprecado upstream.
"""
import os

from beanie import init_beanie
from pymongo import AsyncMongoClient

MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
MONGODB_DB = os.getenv("MONGODB_DB", "beassistant")

_client: AsyncMongoClient | None = None


def get_client() -> AsyncMongoClient:
    """Cliente de Mongo (se crea en el primer uso).

    `tz_aware=True` hace que las fechas vuelvan como datetime con tzinfo UTC, que
    es lo que esperan `utils/timezone.py` y la validación de ventanas horarias.
    """
    global _client
    if _client is None:
        _client = AsyncMongoClient(MONGODB_URL, tz_aware=True)
    return _client


async def init_db(client: AsyncMongoClient | None = None) -> None:
    """Registra los documentos y crea los índices declarados en cada modelo.

    Hay que llamarla antes de usar cualquier modelo: lo hace el lifespan de la
    app y también los scripts de seed. `client` permite inyectar otro cliente.
    """
    # Import local para evitar un ciclo: models importa de este módulo.
    from models import ALL_DOCUMENTS

    await init_beanie(
        database=(client or get_client())[MONGODB_DB],
        document_models=ALL_DOCUMENTS,
    )


async def close_db() -> None:
    global _client
    if _client is not None:
        await _client.close()
        _client = None

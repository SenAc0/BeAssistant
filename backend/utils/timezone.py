"""Helpers de zona horaria.

Los datetime se persisten en UTC. Convertir a horario de Chile es un asunto de
presentación, así que se hace al serializar la respuesta (ver `schemas/meeting.py`)
y nunca mutando el objeto del ORM: mutarlo lo deja "dirty" en la sesión y el
siguiente commit persistiría la hora ya convertida.
"""
from datetime import timezone
from zoneinfo import ZoneInfo

CHILE_TZ = ZoneInfo("America/Santiago")


def to_chile(dt):
    """Devuelve `dt` en horario de Chile. Los naive se asumen UTC."""
    if dt is None:
        return None
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt.astimezone(CHILE_TZ)

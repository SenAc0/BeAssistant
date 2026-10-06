from pydantic import BaseModel


class MeetingReport(BaseModel):
    """Reporte de una reunión específica."""
    id: int
    meeting_id: int
    fecha: str
    nombre_reunion: str
    invitados_totales: int
    asistentes_totales: int
    llegadas_tarde: int
    ausentes: int
    porcentaje_asistencias: float
    porcentaje_ausencias: float
    porcentaje_tarde: float

    # Campos marcados con * (definidos pero sin lógica todavía)
    cantidad_asistencias: int | None = None
    cantidad_reuniones: int | None = None

    model_config = {"from_attributes": True}


class GeneralReport(BaseModel):
    cantidad_asistencias: int
    cantidad_reuniones: int
    cantidad_atrasados: int
    porcentaje_asistencias: float
    porcentaje_ausencias: float
    porcentaje_atrasados: float

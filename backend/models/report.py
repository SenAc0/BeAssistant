from beanie import Document, PydanticObjectId
from pymongo import IndexModel


class MeetingReport(Document):
    meeting_id: PydanticObjectId

    fecha: str
    nombre_reunion: str

    # Número total de invitados (usuarios asociados a la reunión, sin importar si asistieron)
    invitados_totales: int = 0

    # Asistentes clasificados por estado
    asistentes_totales: int = 0  # present + late
    llegadas_tarde: int = 0      # late
    ausentes: int = 0            # absent

    porcentaje_asistencias: float = 0.0
    porcentaje_ausencias: float = 0.0
    porcentaje_tarde: float = 0.0

    # Campos marcados con * (definir pero dejar sin uso por ahora)
    cantidad_asistencias: int | None = None
    cantidad_reuniones: int | None = None

    class Settings:
        name = "meeting_reports"
        indexes = [
            # Un reporte por reunión: generate_meeting_report devuelve el existente.
            IndexModel([("meeting_id", 1)], unique=True, name="uq_report_meeting"),
        ]


class GeneralReport(Document):
    user_id: PydanticObjectId

    cantidad_asistencias: int = 0
    cantidad_reuniones: int = 0
    porcentaje_asistencias: float = 0.0
    porcentaje_ausencias: float = 0.0
    porcentaje_justificaciones: float = 0.0

    class Settings:
        name = "general_reports"
        indexes = [
            IndexModel([("user_id", 1)], name="ix_general_report_user"),
        ]

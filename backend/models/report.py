from sqlalchemy import Column, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from db import Base


class MeetingReport(Base):
    __tablename__ = "meeting_reports"

    id = Column(Integer, primary_key=True, index=True)
    meeting_id = Column(Integer, ForeignKey("meetings.id", ondelete="CASCADE"), index=True, nullable=False)

    fecha = Column(String, nullable=False)
    nombre_reunion = Column(String, nullable=False)

    # Número total de invitados (usuarios asociados a la reunión, sin importar si asistieron)
    invitados_totales = Column(Integer, nullable=False, default=0)

    # Asistentes clasificados por estado
    asistentes_totales = Column(Integer, nullable=False, default=0)  # present + late
    llegadas_tarde = Column(Integer, nullable=False, default=0)      # late
    ausentes = Column(Integer, nullable=False, default=0)            # absent

    porcentaje_asistencias = Column(Float, nullable=False, default=0.0)
    porcentaje_ausencias = Column(Float, nullable=False, default=0.0)
    porcentaje_tarde = Column(Float, nullable=False, default=0.0)

    # Campos marcados con * (definir pero dejar sin uso por ahora)
    cantidad_asistencias = Column(Integer, nullable=True)
    cantidad_reuniones = Column(Integer, nullable=True)

    meeting = relationship("Meeting")


class GeneralReport(Base):
    __tablename__ = "general_reports"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)

    cantidad_asistencias = Column(Integer, nullable=False, default=0)
    cantidad_reuniones = Column(Integer, nullable=False, default=0)
    porcentaje_asistencias = Column(Float, nullable=False, default=0.0)
    porcentaje_ausencias = Column(Float, nullable=False, default=0.0)
    porcentaje_justificaciones = Column(Float, nullable=False, default=0.0)

    user = relationship("User")

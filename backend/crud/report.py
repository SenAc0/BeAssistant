"""Generación y consulta de reportes."""
from datetime import timezone

from beanie import PydanticObjectId
from fastapi import HTTPException

from models import Attendance, Meeting, MeetingReport
from utils.timezone import CHILE_TZ


async def generate_meeting_report(meeting_id: PydanticObjectId) -> MeetingReport:
    """Genera (o devuelve si ya existe) el reporte de una reunión específica.

    - fecha: se toma de start_time (en formato YYYY-MM-DD) o created_at si no hay start_time.
    - nombre_reunion: título de la reunión.
    - asistentes_totales: cantidad de 'present'.
    - porcentaje_asistencias / ausencias / tarde: sobre el total de invitados.

    Los campos cantidad_asistencias y cantidad_reuniones quedan definidos pero sin lógica aún.
    """
    meeting = await Meeting.get(meeting_id)
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")

    # Si ya existe un reporte para esta reunión, lo devolvemos
    existing = await MeetingReport.find_one(MeetingReport.meeting_id == meeting_id)
    if existing:
        return existing

    # Invitados totales: cantidad de asistencias registradas (todos los agregados)
    invitados_totales = await Attendance.find(Attendance.meeting_id == meeting_id).count()

    # Clasificación por estado
    present_count = await _count_status(meeting_id, "present")
    late_count = await _count_status(meeting_id, "late")
    absent_count = await _count_status(meeting_id, "absent")

    asistentes_totales = present_count  # + late_count -> considerar solo present como asistentes

    if invitados_totales > 0:
        porcentaje_asistencias = (asistentes_totales / invitados_totales) * 100.0
        porcentaje_ausencias = (absent_count / invitados_totales) * 100.0
        porcentaje_tarde = (late_count / invitados_totales) * 100.0
    else:
        porcentaje_asistencias = 0.0
        porcentaje_ausencias = 0.0
        porcentaje_tarde = 0.0

    return await MeetingReport(
        meeting_id=meeting.id,
        fecha=_format_report_date(meeting),
        nombre_reunion=meeting.title,
        invitados_totales=invitados_totales,
        asistentes_totales=asistentes_totales,
        llegadas_tarde=late_count,
        ausentes=absent_count,
        porcentaje_asistencias=porcentaje_asistencias,
        porcentaje_ausencias=porcentaje_ausencias,
        porcentaje_tarde=porcentaje_tarde,
        # Campos * quedan sin lógica aún
        cantidad_asistencias=None,
        cantidad_reuniones=None,
    ).insert()


async def _count_status(meeting_id: PydanticObjectId, status: str) -> int:
    return await Attendance.find(
        Attendance.meeting_id == meeting_id, Attendance.status == status
    ).count()


def _format_report_date(meeting: Meeting) -> str:
    """Fecha como string (usar start_time si existe, si no created_at)."""
    base_dt = meeting.start_time or meeting.created_at
    if base_dt is None:
        return ""
    # Normalizar a tz Chile y luego formatear solo fecha
    if base_dt.tzinfo is None:
        base_dt = base_dt.replace(tzinfo=timezone.utc)
    return base_dt.astimezone(CHILE_TZ).strftime("%Y-%m-%d")


async def get_meeting_report(meeting_id: PydanticObjectId) -> MeetingReport | None:
    """Obtiene el reporte de una reunión si existe, sin generarlo."""
    return await MeetingReport.find_one(MeetingReport.meeting_id == meeting_id)


async def generate_general_report(user_id: PydanticObjectId) -> dict:
    total_reuniones = await Attendance.find(Attendance.user_id == user_id).count()
    if total_reuniones == 0:
        return {
            "cantidad_asistencias": 0,
            "cantidad_reuniones": 0,
            "cantidad_atrasados": 0,
            "porcentaje_asistencias": 0.0,
            "porcentaje_ausencias": 0.0,
            "porcentaje_atrasados": 0.0,
        }

    asistencias = await _count_user_status(user_id, "present")
    ausencias = await _count_user_status(user_id, "absent")
    atrasados = await _count_user_status(user_id, "late")

    return {
        "cantidad_asistencias": asistencias,
        "cantidad_reuniones": total_reuniones,
        "cantidad_atrasados": atrasados,
        "porcentaje_asistencias": (asistencias / total_reuniones) * 100,
        "porcentaje_ausencias": (ausencias / total_reuniones) * 100,
        "porcentaje_atrasados": (atrasados / total_reuniones) * 100,
    }


async def _count_user_status(user_id: PydanticObjectId, status: str) -> int:
    return await Attendance.find(
        Attendance.user_id == user_id, Attendance.status == status
    ).count()

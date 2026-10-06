"""Generación y consulta de reportes."""
from datetime import timezone

from fastapi import HTTPException
from sqlalchemy.orm import Session

from models import Attendance, Meeting, MeetingReport
from utils.timezone import CHILE_TZ


def generate_meeting_report(db: Session, meeting_id: int) -> MeetingReport:
    """Genera (o devuelve si ya existe) el reporte de una reunión específica.

    - fecha: se toma de start_time (en formato YYYY-MM-DD) o created_at si no hay start_time.
    - nombre_reunion: título de la reunión.
    - asistencias_totales: total de registros de asistencia (present/late/absent).
    - porcentaje_asistencias: porcentaje de present + late sobre total.
    - porcentaje_ausencias: porcentaje de absent sobre total.

    Los campos cantidad_asistencias y cantidad_reuniones quedan definidos pero sin lógica aún.
    """
    meeting = db.query(Meeting).filter(Meeting.id == meeting_id).first()
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")

    # Si ya existe un reporte para esta reunión, lo devolvemos
    existing = db.query(MeetingReport).filter(MeetingReport.meeting_id == meeting_id).first()
    if existing:
        return existing

    # Calcular datos de asistencia
    attendance_qs = db.query(Attendance).filter(Attendance.meeting_id == meeting_id)

    # Invitados totales: cantidad de registros de attendance (todos los que fueron agregados)
    invitados_totales = attendance_qs.count()

    # Clasificación por estado
    present_count = attendance_qs.filter(Attendance.status == "present").count()
    late_count = attendance_qs.filter(Attendance.status == "late").count()
    absent_count = attendance_qs.filter(Attendance.status == "absent").count()

    asistentes_totales = present_count  # + late_count -> considerar solo present como asistentes

    if invitados_totales > 0:
        porcentaje_asistencias = (asistentes_totales / invitados_totales) * 100.0
        porcentaje_ausencias = (absent_count / invitados_totales) * 100.0
        porcentaje_tarde = (late_count / invitados_totales) * 100.0
    else:
        porcentaje_asistencias = 0.0
        porcentaje_ausencias = 0.0
        porcentaje_tarde = 0.0

    report = MeetingReport(
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
    )

    db.add(report)
    db.commit()
    db.refresh(report)
    return report


def _format_report_date(meeting: Meeting) -> str:
    """Fecha como string (usar start_time si existe, si no created_at)."""
    base_dt = meeting.start_time or meeting.created_at
    if base_dt is None:
        return ""
    # Normalizar a tz Chile y luego formatear solo fecha
    if base_dt.tzinfo is None:
        base_dt = base_dt.replace(tzinfo=timezone.utc)
    return base_dt.astimezone(CHILE_TZ).strftime("%Y-%m-%d")


def get_meeting_report(db: Session, meeting_id: int) -> MeetingReport | None:
    """Obtiene el reporte de una reunión si existe, sin generarlo."""
    return db.query(MeetingReport).filter(MeetingReport.meeting_id == meeting_id).first()


def generate_general_report(db: Session, user_id: int):
    attendance_qs = db.query(Attendance).filter(Attendance.user_id == user_id)

    total_reuniones = attendance_qs.count()
    if total_reuniones == 0:
        return {
            "cantidad_asistencias": 0,
            "cantidad_reuniones": 0,
            "cantidad_atrasados": 0,
            "porcentaje_asistencias": 0.0,
            "porcentaje_ausencias": 0.0,
            "porcentaje_atrasados": 0.0,
        }

    asistencias = attendance_qs.filter(Attendance.status == "present").count()
    ausencias = attendance_qs.filter(Attendance.status == "absent").count()
    atrasados = attendance_qs.filter(Attendance.status == "late").count()

    return {
        "cantidad_asistencias": asistencias,
        "cantidad_reuniones": total_reuniones,
        "cantidad_atrasados": atrasados,
        "porcentaje_asistencias": (asistencias / total_reuniones) * 100,
        "porcentaje_ausencias": (ausencias / total_reuniones) * 100,
        "porcentaje_atrasados": (atrasados / total_reuniones) * 100,
    }

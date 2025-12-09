"""
Scheduler para enviar notificaciones de reuniones próximas.
Revisa periódicamente reuniones que comenzarán pronto y notifica a los participantes.
"""
from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime, timezone, timedelta
from zoneinfo import ZoneInfo
from sqlalchemy.orm import Session
from db import SessionLocal
from models import Meeting, Attendance, User
import notification_service


CHILE_TZ = ZoneInfo("America/Santiago")
NOTIFICATION_MINUTES_BEFORE = 30  # Notificar 30 minutos antes

# Cache para evitar enviar notificaciones duplicadas
_notified_meetings = set()  # IDs de reuniones ya notificadas


def check_and_notify_upcoming_meetings():
    """
    Revisa reuniones que están por comenzar y envía notificaciones a los participantes.
    Se ejecuta cada minuto.
    """
    db: Session = SessionLocal()
    try:
        now = datetime.now(timezone.utc)
        notification_window_start = now + timedelta(minutes=NOTIFICATION_MINUTES_BEFORE - 1)
        notification_window_end = now + timedelta(minutes=NOTIFICATION_MINUTES_BEFORE + 1)
        
        print(f"\n{'='*60}", flush=True)
        print(f"SCHEDULER EJECUTANDOSE - {now}", flush=True)
        print(f"Buscando reuniones entre:", flush=True)
        print(f"   Inicio: {notification_window_start}", flush=True)
        print(f"   Fin: {notification_window_end}", flush=True)
        
        # Ver TODAS las reuniones futuras para debugging
        all_future_meetings = db.query(Meeting).filter(Meeting.start_time > now).all()
        print(f"Total reuniones futuras en BD: {len(all_future_meetings)}", flush=True)
        for m in all_future_meetings:
            print(f"   - '{m.title}' inicia en: {m.start_time} (ID: {m.id})", flush=True)
        
        # Buscar reuniones que iniciarán
        upcoming_meetings = db.query(Meeting).filter(
            Meeting.start_time >= notification_window_start,
            Meeting.start_time < notification_window_end
        ).all()
        
        print(f"Reuniones en ventana de notificacion: {len(upcoming_meetings)}", flush=True)
        print(f"{'='*60}\n", flush=True)
        
        for meeting in upcoming_meetings:
            print(f"Procesando reunion: '{meeting.title}' (ID: {meeting.id})", flush=True)
            
            # Verificar si ya se notificó esta reunión
            if meeting.id in _notified_meetings:
                print(f"   Reunion ya notificada anteriormente, saltando", flush=True)
                continue
            
            # Obtener todos los participantes (asistencias registradas)
            attendances = db.query(Attendance).filter(
                Attendance.meeting_id == meeting.id
            ).all()
            
            print(f"   Participantes registrados: {len(attendances)}", flush=True)
            
            if not attendances:
                print(f"   Sin participantes, saltando", flush=True)
                continue
            
            # Obtener player_ids de los usuarios que tienen dispositivo registrado
            user_ids = [att.user_id for att in attendances]
            print(f"   User IDs: {user_ids}", flush=True)
            
            users = db.query(User).filter(
                User.id.in_(user_ids),
                User.onesignal_player_id.isnot(None)
            ).all()
            
            print(f"   Usuarios con dispositivo: {len(users)}", flush=True)
            
            player_ids = [user.onesignal_player_id for user in users if user.onesignal_player_id]
            
            if player_ids:
                print(f"Enviando notificacion para reunion '{meeting.title}' a {len(player_ids)} usuarios", flush=True)
                print(f"   Player IDs: {player_ids}", flush=True)
                result = notification_service.notify_meeting_starting(
                    player_ids=player_ids,
                    meeting_title=meeting.title,
                    minutes_before=NOTIFICATION_MINUTES_BEFORE
                )
                print(f"   Resultado: {result}", flush=True)
                
                # Marcar como notificada para evitar spam
                _notified_meetings.add(meeting.id)
                print(f"   Reunion marcada como notificada", flush=True)
            else:
                print(f"No hay dispositivos registrados para la reunion '{meeting.title}'", flush=True)
        
        # Limpiar reuniones pasadas del cache (para liberar memoria)
        past_meetings = db.query(Meeting).filter(Meeting.end_time < now).all()
        for m in past_meetings:
            _notified_meetings.discard(m.id)
    
    except Exception as e:
        print(f"Error en check_and_notify_upcoming_meetings: {e}", flush=True)
    finally:
        db.close()


# Scheduler
scheduler = BackgroundScheduler()


def start_scheduler():
    """Inicia el scheduler que revisa reuniones cada minuto."""
    print("start_scheduler() llamado", flush=True)
    if not scheduler.running:
        print("Scheduler no esta corriendo, iniciandolo", flush=True)
        # Ejecutar cada minuto
        scheduler.add_job(
            check_and_notify_upcoming_meetings,
            'interval',
            seconds=30,
            id='check_meetings',
            replace_existing=True
        )
        scheduler.start()
        print(f"Scheduler de notificaciones iniciado (revisa cada 30 segundos, notifica {NOTIFICATION_MINUTES_BEFORE} minutos antes)", flush=True)
        
        # Ejecutar inmediatamente la primera vez para testing
        print("Ejecutando primera verificacion inmediatamente", flush=True)
        check_and_notify_upcoming_meetings()
    else:
        print("Scheduler ya esta corriendo", flush=True)


def stop_scheduler():
    """Detiene el scheduler."""
    if scheduler.running:
        scheduler.shutdown()
        print("Scheduler detenido", flush=True)

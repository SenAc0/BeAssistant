"""
Scheduler para enviar notificaciones de reuniones próximas.
Revisa periódicamente reuniones que comenzarán pronto y notifica a los participantes.

Usa AsyncIOScheduler (no BackgroundScheduler) porque el job consulta Mongo con el
driver async: corre sobre el mismo event loop de la app.
"""
import asyncio
from datetime import datetime, timedelta, timezone

from apscheduler.schedulers.asyncio import AsyncIOScheduler

from models import Attendance, Meeting, User
from utils import notifications

NOTIFICATION_MINUTES_BEFORE = 30  # Notificar 30 minutos antes

# Cache para evitar enviar notificaciones duplicadas
_notified_meetings = set()  # IDs de reuniones ya notificadas


async def check_and_notify_upcoming_meetings():
    """
    Revisa reuniones que están por comenzar y envía notificaciones a los participantes.
    """
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
        all_future_meetings = await Meeting.find({"start_time": {"$gt": now}}).to_list()
        print(f"Total reuniones futuras en BD: {len(all_future_meetings)}", flush=True)
        for m in all_future_meetings:
            print(f"   - '{m.title}' inicia en: {m.start_time} (ID: {m.id})", flush=True)

        # Buscar reuniones que iniciarán
        upcoming_meetings = await Meeting.find(
            {
                "start_time": {
                    "$gte": notification_window_start,
                    "$lt": notification_window_end,
                }
            }
        ).to_list()

        print(f"Reuniones en ventana de notificacion: {len(upcoming_meetings)}", flush=True)
        print(f"{'='*60}\n", flush=True)

        for meeting in upcoming_meetings:
            print(f"Procesando reunion: '{meeting.title}' (ID: {meeting.id})", flush=True)

            # Verificar si ya se notificó esta reunión
            if meeting.id in _notified_meetings:
                print(f"   Reunion ya notificada anteriormente, saltando", flush=True)
                continue

            # Obtener todos los participantes (asistencias registradas)
            attendances = await Attendance.find(Attendance.meeting_id == meeting.id).to_list()

            print(f"   Participantes registrados: {len(attendances)}", flush=True)

            if not attendances:
                print(f"   Sin participantes, saltando", flush=True)
                continue

            # Obtener player_ids de los usuarios que tienen dispositivo registrado
            user_ids = [att.user_id for att in attendances]
            print(f"   User IDs: {user_ids}", flush=True)

            users = await User.find(
                {"_id": {"$in": user_ids}, "onesignal_player_id": {"$ne": None}}
            ).to_list()

            print(f"   Usuarios con dispositivo: {len(users)}", flush=True)

            player_ids = [user.onesignal_player_id for user in users if user.onesignal_player_id]

            if player_ids:
                print(f"Enviando notificacion para reunion '{meeting.title}' a {len(player_ids)} usuarios", flush=True)
                print(f"   Player IDs: {player_ids}", flush=True)
                # OneSignal es un cliente sincrono: va a un thread para no bloquear el loop.
                result = await asyncio.to_thread(
                    notifications.notify_meeting_starting,
                    player_ids=player_ids,
                    meeting_title=meeting.title,
                    minutes_before=NOTIFICATION_MINUTES_BEFORE,
                )
                print(f"   Resultado: {result}", flush=True)

                # Marcar como notificada para evitar spam
                _notified_meetings.add(meeting.id)
                print(f"   Reunion marcada como notificada", flush=True)
            else:
                print(f"No hay dispositivos registrados para la reunion '{meeting.title}'", flush=True)

        # Limpiar reuniones pasadas del cache (para liberar memoria)
        past_meetings = await Meeting.find({"end_time": {"$lt": now}}).to_list()
        for m in past_meetings:
            _notified_meetings.discard(m.id)

    except Exception as e:
        print(f"Error en check_and_notify_upcoming_meetings: {e}", flush=True)


# Scheduler
scheduler = AsyncIOScheduler()


def start_scheduler():
    """Inicia el scheduler que revisa reuniones periodicamente."""
    print("start_scheduler() llamado", flush=True)
    if not scheduler.running:
        print("Scheduler no esta corriendo, iniciandolo", flush=True)
        scheduler.add_job(
            check_and_notify_upcoming_meetings,
            'interval',
            seconds=30,
            id='check_meetings',
            replace_existing=True,
        )
        scheduler.start()
        print(f"Scheduler de notificaciones iniciado (revisa cada 30 segundos, notifica {NOTIFICATION_MINUTES_BEFORE} minutos antes)", flush=True)

        # Ejecutar la primera verificacion enseguida, sin bloquear el arranque
        print("Programando primera verificacion inmediata", flush=True)
        asyncio.get_event_loop().create_task(check_and_notify_upcoming_meetings())
    else:
        print("Scheduler ya esta corriendo", flush=True)


def stop_scheduler():
    """Detiene el scheduler."""
    if scheduler.running:
        scheduler.shutdown()
        print("Scheduler detenido", flush=True)

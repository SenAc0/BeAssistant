"""
Servicio de notificaciones usando OneSignal SDK.
Permite enviar notificaciones push a usuarios específicos.
"""
import os
from onesignal_sdk.client import Client
from typing import List, Optional
from dotenv import load_dotenv
import sys

# Cargar variables de entorno
load_dotenv()

# Configuración de OneSignal desde variables de entorno
ONESIGNAL_APP_ID = os.getenv("ONESIGNAL_APP_ID")
ONESIGNAL_REST_API_KEY = os.getenv("ONESIGNAL_REST_API_KEY")

print("=" * 60, flush=True)
print(f"Configuracion OneSignal:", flush=True)
print(f"   APP_ID: {ONESIGNAL_APP_ID}", flush=True)
print(f"   REST_API_KEY: {'Configurado' if ONESIGNAL_REST_API_KEY else 'No encontrado'}", flush=True)
print("=" * 60, flush=True)

# Cliente de OneSignal
onesignal_client = None

if ONESIGNAL_APP_ID and ONESIGNAL_REST_API_KEY:
    onesignal_client = Client(
        app_id=ONESIGNAL_APP_ID,
        rest_api_key=ONESIGNAL_REST_API_KEY,
    )


def send_notification_to_players(
    player_ids: List[str],
    title: str,
    message: str,
    data: Optional[dict] = None
) -> dict:
    """
    Envía una notificación a una lista de player_ids específicos.
    
    Args:
        player_ids: Lista de OneSignal player IDs
        title: Título de la notificación
        message: Cuerpo del mensaje
        data: Datos adicionales (opcional)
    
    Returns:
        Respuesta de OneSignal API
    """
    if not onesignal_client:
        error_msg = "OneSignal no esta configurado. Verifica ONESIGNAL_APP_ID y ONESIGNAL_REST_API_KEY en .env"
        print(error_msg, flush=True)
        return {"error": "OneSignal not configured"}
    
    if not player_ids:
        return {"error": "No player_ids provided"}
    
    notification_body = {
        "include_player_ids": player_ids,
        "headings": {"en": title},
        "contents": {"en": message},
    }
    
    if data:
        notification_body["data"] = data
    
    try:
        print(f"Enviando notificacion a OneSignal", flush=True)
        print(f"   Body: {notification_body}", flush=True)
        response = onesignal_client.send_notification(notification_body)
        print(f"Notificacion enviada exitosamente", flush=True)
        print(f"   Respuesta: {response.body}", flush=True)
        return response.body
    except Exception as e:
        print(f"Error enviando notificacion: {e}", flush=True)
        import traceback
        traceback.print_exc()
        return {"error": str(e)}


def notify_meeting_starting(player_ids: List[str], meeting_title: str, minutes_before: int = 5):
    """
    Envía notificación de que una reunión está por comenzar.
    
    Args:
        player_ids: Lista de OneSignal player IDs de los participantes
        meeting_title: Título de la reunión
        minutes_before: Minutos antes del inicio
    """
    title = f"Reunión próxima: {meeting_title}"
    message = f"La reunión comenzará en {minutes_before} minutos."
    
    data = {
        "type": "meeting_starting",
        "meeting_title": meeting_title,
        "minutes_before": minutes_before
    }
    
    return send_notification_to_players(player_ids, title, message, data)

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';

/// Asistencia: marcar la propia, invitar/quitar asistentes y consultar listas.
class AttendanceService extends ApiClient {
  Future<bool> markAttendance(String meetingID) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      endpoint('/attendance/mark'),
      headers: authHeaders(token),
      body: jsonEncode({'meeting_id': meetingID, 'status': 'present'}),
    );

    print("Respuesta marcar asistencia: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Obtiene la asistencia del usuario autenticado para una reunión específica.
  /// Retorna un mapa con la asistencia o `null` si no existe o hay error.
  Future<Map<String, dynamic>?> getMyAttendanceForMeeting(String meetingID) async {
    final token = await getToken();
    if (token == null) {
      print("No hay token disponible.");
      return null;
    }

    final response = await http.get(
      endpoint('/attendance/my/$meetingID'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Asistencia obtenida: $data");

      if (data is Map<String, dynamic>) return data;

      return data as Map<String, dynamic>?;
    } else {
      print("Error al obtener asistencia: ${response.body}");
      return null;
    }
  }

  /// Obtener todas las asistencias del usuario a sus reuniones
  Future<List<dynamic>> getMyAttendances() async {
    final token = await getToken();
    if (token == null) {
      throw Exception("No autorizado: falta token");
    }

    final response = await http.get(
      endpoint('/attendance/my'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error al obtener asistencias: ${response.body}");
      throw Exception("Error al obtener lista de asistencias");
    }
  }

  /// Agregar asistente a una reunión
  Future<bool> addAssistant(String meetingId, String userId) async {
    final url = endpoint('/attendance');

    final body = {
      "user_id": userId,
      "meeting_id": meetingId,
      "status": "absent",
    };

    final token = await getToken();

    final response = await http.post(
      url,
      headers: authHeaders(token),
      body: jsonEncode(body),
    );

    print("POST $url -> ${response.statusCode}");
    print("Body: ${response.body}");

    return response.statusCode == 200;
  }

  /// Eliminar asistente de una reunión
  Future<bool> removeAssistant(String meetingId, String userId) async {
    final token = await getToken();

    final url = endpoint('/attendance').replace(
      queryParameters: {
        "user_id": userId,
        "meeting_id": meetingId,
      },
    );

    final response = await http.delete(
      url,
      headers: authHeaders(token),
    );

    print("DELETE $url -> ${response.statusCode}");
    print("Body: ${response.body}");

    return response.statusCode == 200;
  }

  /// Obtener la lista de asistentes de una reunión
  Future<List<dynamic>> getAttendanceForMeeting(String meetingId) async {
    final token = await getToken();

    final response = await http.get(
      endpoint('/attendance/meeting/$meetingId'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error obteniendo asistentes: ${response.body}");
    }
  }

  /// Obtener la lista de asistentes de una reunión incluyendo el nombre de usuario
  Future<List<dynamic>> getAttendanceForMeetingWithUserName(String meetingId) async {
    final token = await getToken();

    final response = await http.get(
      endpoint('/attendance/meeting_named_user/$meetingId'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error obteniendo asistentes (con nombre): ${response.body}");
    }
  }
}

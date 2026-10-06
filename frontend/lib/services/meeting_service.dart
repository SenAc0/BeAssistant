import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';

/// Listado, detalle y creación de reuniones.
class MeetingService extends ApiClient {
  /// Obtiene la lista de reuniones del backend.
  /// Retorna la lista decodificada (List) en caso de éxito, o `null` en caso de error.
  Future<List<dynamic>?> getMeetings() async {
    final token = await getToken();
    if (token == null) {
      print("No hay token disponible.");
      return null;
    }

    final response = await http.get(
      endpoint('/meetings'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Reuniones obtenidas: $data");
      if (data is List) return data;
      // sometimes backend can return an object with items under a key
      return data as List<dynamic>?;
    } else {
      print("Error al obtener reuniones: ${response.body}");
      return null;
    }
  }

  /// Obtiene las reuniones del usuario autenticado. Retorna `List` o `null`.
  Future<List<dynamic>?> getMyMeetings() async {
    final token = await getToken();
    if (token == null) {
      print("No hay token disponible.");
      return null;
    }

    final response = await http.get(
      endpoint('/meetings/my'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Mis reuniones obtenidas: $data");
      if (data is List) return data;
      return data as List<dynamic>?;
    } else {
      print("Error al obtener mis reuniones: ${response.body}");
      return null;
    }
  }

  /// Obtener solo una reunion por id de la reunion
  Future<Map<String, dynamic>?> getMeeting(int meetingID) async {
    final token = await getToken();
    if (token == null) {
      print("No hay token disponible");
      return null;
    }

    final response = await http.get(
      endpoint('/meeting/$meetingID'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Reunión obtenida: $data");
      return data;
    } else {
      print("Error al obtener la reunión: ${response.body}");
      return null;
    }
  }

  Future<bool> createMeeting(Map<String, dynamic> meetingData) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      endpoint('/meetings'),
      headers: authHeaders(token),
      body: jsonEncode(meetingData),
    );

    print("Respuesta crear meeting: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }
}

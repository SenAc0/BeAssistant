import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';

/// Usuarios y registro del dispositivo para notificaciones.
class UserService extends ApiClient {
  /// Obtener la lista de usuarios
  Future<List<dynamic>> getUsers() async {
    final token = await getToken();
    if (token == null) {
      throw Exception("Token no disponible");
    }

    final response = await http.get(
      endpoint('/users'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener usuarios: ${response.body}");
    }
  }

  /// Registra el OneSignal player_id del dispositivo en el backend
  Future<bool> registerDevice(String playerId) async {
    final token = await getToken();
    if (token == null) {
      print("No hay token disponible.");
      return false;
    }

    final response = await http.post(
      endpoint('/users/register-device'),
      headers: authHeaders(token),
      body: jsonEncode({'player_id': playerId}),
    );

    if (response.statusCode == 200) {
      print("Dispositivo registrado con player_id: $playerId");
      return true;
    } else {
      print("Error al registrar dispositivo: ${response.body}");
      return false;
    }
  }
}

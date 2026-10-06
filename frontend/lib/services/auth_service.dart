import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

/// Registro, inicio/cierre de sesión y perfil del usuario autenticado.
class AuthService extends ApiClient {
  Future<http.Response> register(String name, String email, String password) async {
    final response = await http.post(
      endpoint('/register'),
      headers: jsonHeaders(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    // Devolver la respuesta completa para que el llamador pueda interpretar el código
    if (!(response.statusCode == 200 || response.statusCode == 201)) {
      print("Error al registrar: ${response.statusCode} -> ${response.body}");
    }

    return response;
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      endpoint('/login'),
      headers: jsonHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token); // guarda el token
      print("Token guardado: $token");
      return true;
    } else {
      print("Error al iniciar sesión: ${response.body}");
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  /// Perfil del usuario autenticado (`/me`).
  Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();
    if (token == null) return null;

    final response = await http.get(
      endpoint('/me'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error obteniendo perfil: ${response.body}");
      return null;
    }
  }
}

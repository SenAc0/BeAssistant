import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base compartida por todos los servicios de la API.
///
/// Centraliza la URL del backend, el token guardado y la construcción de
/// headers/URLs, para que cada servicio solo se ocupe de sus endpoints.
abstract class ApiClient {
  /// URL del backend. Se setea con BASE_URL en el .env
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://192.168.0.178:8000';

  /// Token JWT guardado al iniciar sesión (`null` si no hay sesión).
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Construye la URL de un endpoint: `endpoint('/meetings')`.
  Uri endpoint(String path) => Uri.parse('$baseUrl$path');

  /// Headers para endpoints públicos (register, login).
  Map<String, String> jsonHeaders() => {
        'Content-Type': 'application/json',
      };

  /// Headers para endpoints autenticados.
  Map<String, String> authHeaders(String? token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}

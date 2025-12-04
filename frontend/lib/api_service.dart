import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ApiService {
  // Setear la url para conectar con el backend
  
  static final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://192.168.0.178:8000';





  Future<http.Response> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    // Devolver la respuesta completa para que el llamador pueda interpretar el código
    if (!(response.statusCode == 200 || response.statusCode == 201)) {
      print("Error al registrar: ${response.statusCode} -> ${response.body}");
    }

    return response;
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
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

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  /// Obtiene la lista de reuniones del backend.
  /// Retorna la lista decodificada (List) en caso de éxito, o `null` en caso de error.
  Future<List<dynamic>?> getMeetings() async {
    final token = await getToken();
    if (token == null) {
      print("No hay token disponible.");
      return null;
    }

    final url = Uri.parse('$baseUrl/meetings');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

    final url = Uri.parse('$baseUrl/meetings/my');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
    final url = Uri.parse('$baseUrl/meeting/$meetingID');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

  //perfil
  Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/me');

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error obteniendo perfil: ${response.body}");
      return null;
    }
  }

  Future<bool> createMeeting(Map<String, dynamic> meetingData) async {
    final token = await getToken();
    if (token == null) return false;

    final url = Uri.parse('$baseUrl/meetings');

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(meetingData),
    );

    print("Respuesta crear meeting: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Obtener la lista de usuarios
  Future<List<dynamic>> getUsers() async {
    final token = await getToken();
    if (token == null) {
      throw Exception("Token no disponible");
    }

    final url = Uri.parse('$baseUrl/users');

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener usuarios: ${response.body}");
    }
  }
/// Agregar asistente a una reunión
Future<bool> addAssistant(int meetingId, int userId) async {
    final url = Uri.parse("$baseUrl/attendance");

    final body = {
      "user_id": userId,
      "meeting_id": meetingId,
      "status": "absent",
    };

    final token = await getToken();

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("POST $url -> ${response.statusCode}");
    print("Body: ${response.body}");

    return response.statusCode == 200;
  }
/// Obtener la lista de asistentes de una reunión
Future<List<dynamic>> getAttendanceForMeeting(int meetingId) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/attendance/meeting/$meetingId');

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error obteniendo asistentes: ${response.body}");
    }
  }

  /// Obtener la lista de asistentes de una reunión incluyendo el nombre de usuario
  Future<List<dynamic>> getAttendanceForMeetingWithUserName(int meetingId) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/attendance/meeting_named_user/$meetingId');

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error obteniendo asistentes (con nombre): ${response.body}");
    }
  }
  Future<bool> markAttendance(int meetingID) async {
    final token = await getToken();
    if (token == null) return false;
    final url = Uri.parse('$baseUrl/attendance/mark');
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({'meeting_id': meetingID,
                        'status': 'present'}),
    );

    print("Respuesta marcar asistencia: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }


  /// Obtiene la asistencia del usuario autenticado para una reunión específica.
  /// Retorna un mapa con la asistencia o `null` si no existe o hay error.


  Future<Map<String, dynamic>?> getMyAttendanceForMeeting(int meetingID) async {
    final token = await getToken();
    if (token == null) {
      print("No hay token disponible.");
      return null;
    }
    final url = Uri.parse('$baseUrl/attendance/my/$meetingID');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

  Future<List<dynamic>> getBeacons() async {
    final url = Uri.parse('$baseUrl/meetings/available-beacons');

    final token = await getToken();
    if (token == null) {
      throw Exception("No autorizado: falta token");
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error al obtener beacons: ${response.body}");
      throw Exception("Error al obtener lista de beacons");
    }
  }
  // obtener todas las asistencias del usuario a sus reuniones
  Future<List<dynamic>> getMyAttendances() async {
    final token = await getToken();
    if (token == null) {
      throw Exception("No autorizado: falta token");
    }

    final url = Uri.parse('$baseUrl/attendance/my');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error al obtener asistencias: ${response.body}");
      throw Exception("Error al obtener lista de asistencias");
    }
  }

  Future<Map<String, dynamic>?> getReportGeneral() async {
    final token = await getToken();
    if (token == null) {
      print("No hay token disponible.");
      return null;
    }

    final url = Uri.parse('$baseUrl/report/general');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Reporte general obtenido: $data");
      if (data is Map<String, dynamic>) return data;
      return data as Map<String, dynamic>?;
    } else {
      print("Error al obtener reporte general: ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getReportMeeting(int meetingID) async {
    final token = await getToken();
    if (token == null) {
      print("No hay token disponible.");
      return null;
    }

    final url = Uri.parse('$baseUrl/meetings/$meetingID/report');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Reporte de reunión obtenido: $data");
      if (data is Map<String, dynamic>) return data;
      return data as Map<String, dynamic>?;
    } else {
      print("Error al obtener reporte de reunión: ${response.body}");
      return null;
    }
  }


}

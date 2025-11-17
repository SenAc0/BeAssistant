import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // Setear la url para conectar con el backend
  

  // En caso de usar un emulador de Android, usar esta dirección IP para localhost
  //static const String baseUrl = 'http://10.0.2.2:8000';


  // En caso de usar ngrok, insertar la url ngrok y usar esto
  //static const String baseUrl = 'https://7c599f4c595a.ngrok-free.app';


  // Para ejecutar en Linux/Desktop (mismo equipo que el backend Docker)
  //static const String baseUrl = 'http://localhost:8000';
  
  // En caso de usar telefono fisico como dispositivo en development, usar la IP local de la pc (misma red wifi)
  // Nota: IP actual de esta máquina es 192.168.1.129
  static const String baseUrl = 'http://192.168.1.11:8000';

  Future<bool> register(String name, String email, String password) async {

    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Error al registrar: ${response.body}");
      return false;
    }
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
      await prefs.setString('token', token);              // guarda el token
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
      headers:{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200 ) {
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
  
}
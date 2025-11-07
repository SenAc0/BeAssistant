import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // Setear la url para conectar con el backend
  

  // En caso de usar un emulador de Android, usar esta dirección IP para localhost
  static const String baseUrl = 'http://10.0.2.2:8000';


  // En caso de usar ngrok, insertar la url ngrok y usar esto
  //static const String baseUrl = 'https://7c599f4c595a.ngrok-free.app';


  //En caso de usar telefono fisico como dispositivo en development, usar la IP local de la pc (misma red wifi)
  //static const String baseUrl = 'http://192.168.0.178:8000';

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
}
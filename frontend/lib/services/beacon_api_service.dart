import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';

/// Beacons en el backend (CRUD).
///
/// Se llama `BeaconApiService` y no `BeaconService` porque ese nombre ya lo usa
/// el scanner BLE de `lib/pages/beacon_service.dart`, que es otra cosa: ese lee
/// los beacons por bluetooth, este habla con la API.
class BeaconApiService extends ApiClient {
  /// Lista de beacons disponibles para asociar a una reunión.
  Future<List<dynamic>> getBeacons() async {
    final token = await getToken();
    if (token == null) {
      throw Exception("No autorizado: falta token");
    }

    final response = await http.get(
      endpoint('/meetings/available-beacons'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error al obtener beacons: ${response.body}");
      throw Exception("Error al obtener lista de beacons");
    }
  }

  Future<Map<String, dynamic>?> getBeacon(String id) async {
    final token = await getToken();

    if (token == null) {
      throw Exception("No autorizado: falta token");
    }

    final response = await http.get(
      endpoint('/beacons/$id'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Beacon obtenido: $data");
      return data as Map<String, dynamic>;
    } else {
      print("Error al obtener el beacon: ${response.statusCode} -> ${response.body}");
      return null;
    }
  }

  /// Crear beacon en la bd
  Future<bool> addBeacon(String location, String id, String major, String minor, String name) async {
    final token = await getToken();

    if (token == null) {
      throw Exception("No autorizado: falta token");
    }

    final body = {
      "id": id,
      "name": name,
      "location": location,
      "major": major,
      "minor": minor,
    };

    final response = await http.post(
      endpoint('/beacons'),
      headers: authHeaders(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Beacon creado exitosamente");
      return true;
    } else {
      print("Error al crear beacon: ${response.statusCode} -> ${response.body}");
      return false;
    }
  }

  /// Eliminar beacon
  Future<bool> deleteBeacon(String id) async {
    final token = await getToken();
    if (token == null) {
      throw Exception("No autorizado: falta token");
    }

    final response = await http.delete(
      endpoint('/beacons/$id'),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      print("Beacon eliminado exitosamente");
      return true;
    } else {
      print("Error al eliminar beacon: ${response.statusCode} -> ${response.body}");
      return false;
    }
  }
}

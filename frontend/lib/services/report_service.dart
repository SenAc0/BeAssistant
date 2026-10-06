import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';

/// Reportes: general del usuario y por reunión.
class ReportService extends ApiClient {
  Future<Map<String, dynamic>?> getReportGeneral() async {
    final token = await getToken();
    if (token == null) {
      print("No hay token disponible.");
      return null;
    }

    final response = await http.get(
      endpoint('/report/general'),
      headers: authHeaders(token),
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

  /// Genera (o devuelve, si ya existe) el reporte de una reunión.
  Future<Map<String, dynamic>?> getReportMeeting(String meetingID) async {
    final token = await getToken();
    if (token == null) {
      print("No hay token disponible.");
      return null;
    }

    final response = await http.post(
      endpoint('/meetings/$meetingID/report'),
      headers: authHeaders(token),
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

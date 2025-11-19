import 'package:flutter/material.dart';
import 'package:myapp/api_service.dart';
import 'package:myapp/pages/beacon_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:myapp/pages/crearReunion3.dart';

class PaginaReunion extends StatefulWidget {
  final int meetingID;

  const PaginaReunion({super.key, required this.meetingID});

  @override
  State<PaginaReunion> createState() => _PaginaReunionState();
}

class _PaginaReunionState extends State<PaginaReunion> {
  Map<String, dynamic>? _reunion;
  bool _loading = true;
  String? _error;
  String? _beaconID;
  final BeaconService _beaconService = BeaconService();
  bool _isCheckingAttendance = false;
  String _attendanceStatusCode = 'unknown';
  bool _isCoordinator = false; // ← nuevo
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _cargarReunion();
  }

  @override
  void dispose() {
    _beaconService.stopScanning();
    super.dispose();
  }

  Future<void> _cargarReunion() async {
    try {
      final data = await ApiService().getMeeting(widget.meetingID);
      setState(() {
        _reunion = data;
        _loading = false;
      });
      _beaconID = _reunion?['beacon_id'];
      print('Beacon ID: $_beaconID');
      _loadAttendance();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
    final profile = await ApiService().getProfile();
    if (profile != null) {
      final currentUserId = profile["id"];
      final coordinatorId = _reunion?["coordinator_id"];
      setState(() {
        _isCoordinator = currentUserId == coordinatorId;
      });
    }
  }

 Future<void> _loadAttendance() async {
    try {

      final data = await _apiService.getMyAttendanceForMeeting(widget.meetingID);
      setState(() {
        if (data != null && data['status'] != null) {
          // se espera status: 'present' | 'absent' | 'late'
          _attendanceStatusCode = data['status'].toString();
        } else {
          _attendanceStatusCode = 'not_recorded';
        }
      });
    } catch (e) {
      setState(() {
        _attendanceStatusCode = 'error';
      });
    }
  }



  Future<void> markAttendance() async {
    if (_beaconID == null || _beaconID!.isEmpty) {
      setState(() {
        _attendanceStatusCode = "error";
      });
      return;
    }

    setState(() {
      _isCheckingAttendance = true;
      _attendanceStatusCode = "Verificando...";
    });

    try {
      final detected = await _beaconService.detectBeacon(_beaconID!);

      if (!detected) {
        setState(() {
          _isCheckingAttendance = false;
          _attendanceStatusCode = 'absent';
        });
        return;
      }
      // Si se detectó el beacon, llamar al backend para marcar asistencia


      final success = await _apiService.markAttendance(widget.meetingID);
      setState(() {
        _isCheckingAttendance = false;
        if (success) {
          _attendanceStatusCode = 'present';
          print("Asistencia marcada como presente");
        } else {
          _attendanceStatusCode = 'error';
          print("Error al marcar asistencia para la reunión ${widget.meetingID}");
        }
      });
    } catch (e) {
      setState(() {
        _isCheckingAttendance = false;
        _attendanceStatusCode = "error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8C3CE6),
                Color(0xFFA159FF),
              ],
            ),
          ),
        ),
          title: const Text('Cargando...'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          
          title: Text('Error'),
        ),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8C3CE6),
                Color(0xFFA159FF),
              ],
            ),
          ),
        ),
        title: Text(
          _reunion?['title'] ?? 'Reunión',
        ),
      ),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            SesionCard(
              tituloSesion: _reunion?['title'] ?? 'Sin título',
              fecha: _formatDate(_reunion?['start_time']),
              hora: _formatHora(_reunion?['start_time']),
              coordinador:
                  _reunion?['coordinator']?['name'] ?? 'Sin coordinador',
              sala: _reunion?['location'] ?? 'Sin sala',
              startTime: _reunion?['start_time'],
              endTime: _reunion?['end_time'],
            ),
            const SizedBox(height: 12),

            if (_reunion?['topics'] != null && _reunion!['topics'].isNotEmpty)
              TopicoCard(
                titulo: _reunion?['topics'] ?? 'Sin título',
              ),
            const SizedBox(height: 12),

            // Descripción como card independiente (si existe)
            if (_reunion?['description'] != null && _reunion!['description'].isNotEmpty)
              DescripcionCard(descripcion: _reunion?['description'] ?? ''),

            const SizedBox(height: 12),

            if (_reunion?['note'] != null && _reunion!['note'].isNotEmpty)
              NotaCard(descripcionNota: _reunion?['note'] ?? 'Sin notas'),

            const SizedBox(height: 12),

            AsistenciaCard(
              statusCode: _attendanceStatusCode ,
              isChecking: _isCheckingAttendance,
              onCheckAttendance: markAttendance,
            ),
          ],
        ),
      ),
    
      //Boton coordinador
      floatingActionButton: _isCoordinator
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CrearReunion3(meetingId: widget.meetingID),
                    ),
                );
              },
              //backgroundColor: Color(0xFFA159FF),
              shape: const CircleBorder(),
              child: const Icon(Icons.person_add),
            )
          : null,
    );
    
  }

  String _formatDate(String? iso) {
    if (iso == null) return 'Sin fecha';
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return 'Sin fecha';
      try {
        final loc = tz.getLocation('America/Santiago');
        final tz.TZDateTime chileDt = tz.TZDateTime.from(dt, loc);
        return '${chileDt.day}/${chileDt.month}/${chileDt.year}';
      } catch (e) {
        final local = dt.toLocal();
        return '${local.day}/${local.month}/${local.year}';
      }
    } catch (_) {
      return 'Sin fecha';
    }
  }

  String _formatHora(String? iso) {
    if (iso == null) return 'Sin hora';
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return 'Sin hora';
      try {
        final loc = tz.getLocation('America/Santiago');
        final tz.TZDateTime chileDt = tz.TZDateTime.from(dt, loc);
        return '${chileDt.hour.toString().padLeft(2, '0')}:${chileDt.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        final local = dt.toLocal();
        return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return 'Sin hora';
    }
  }
}

class SesionCard extends StatelessWidget {
  final String tituloSesion;
  final String fecha;
  final String hora;
  final String coordinador;
  final String sala;
  final String? startTime;
  final String? endTime;

  const SesionCard({
    super.key,
    required this.tituloSesion,
    required this.fecha,
    required this.hora,
    required this.coordinador,
    required this.sala,
    this.startTime,
    this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    int duracionMin = 0;
    if (startTime != null && endTime != null) {
      try {
        final start = DateTime.parse(startTime!);
        final end = DateTime.parse(endTime!);
        duracionMin = end.difference(start).inMinutes;
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        color: Colors.grey[300], 
        borderRadius: BorderRadius.circular(8),//16
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // TÍTULO
          Text(
            "Sesión: $tituloSesion",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          // LÍNEA DIVISORIA
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black,
          ),
          const SizedBox(height: 10),

          // FECHA / HORA / DURACIÓN
          Row(
            children: [
              // FECHA
              Expanded(
              child: Text(
                  "Fecha: $fecha",
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              // ESPACIADOR
              const SizedBox(width: 4),

              // INICIO + DURACIÓN
              Expanded(
                child: Text(
                  "Inicio: $hora ($duracionMin min)",
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          

          const SizedBox(height: 20),

          // COORDINADOR
          Row(
            children: [
              const Text(
                "Coordinador:",
                style: TextStyle(fontSize: 14),
              ),
              const Spacer(),
              _Pill(
                texto: coordinador,
                background: Colors.white.withOpacity(0.25),
                textColor: Colors.black,
              ),
            ],
          ),

          //const SizedBox(height: 12),
          //Divider(color: Colors.black),
          const SizedBox(height: 12),

          // SALA
          Row(
            children: [
              const Text(
                "Sala:",
                style: TextStyle(fontSize: 14),
              ),
              const Spacer(),
              _Pill(
                texto: sala,
                background: Colors.white.withOpacity(0.25),
                textColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TopicoCard extends StatelessWidget {
  final String titulo;

  const TopicoCard({
    super.key,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        color: Colors.grey[300], 
        borderRadius: BorderRadius.circular(8),//16
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "Tópico",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // LÍNEA DIVISORIA
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black,
          ),
          const SizedBox(height: 10),

          Text(
            titulo,
            style: const TextStyle(fontSize: 16),
          ),

        ],
      ),
    );
  }
}

// Nueva card para la descripción (se muestra por separado)
class DescripcionCard extends StatelessWidget {
  final String descripcion;

  const DescripcionCard({super.key, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        color: Colors.grey[300], 
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Descripción",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // LÍNEA DIVISORIA
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black,
          ),
          const SizedBox(height: 10),
          Text(
            descripcion,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class NotaCard extends StatelessWidget {
  final String descripcionNota;

  const NotaCard({super.key, required this.descripcionNota});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        color:  Colors.grey[300],
        borderRadius: BorderRadius.circular(8),//16
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nota",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // LÍNEA DIVISORIA
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black,
          ),
          const SizedBox(height: 10),

          Text(
            descripcionNota,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class AsistenciaCard extends StatelessWidget {
  final String statusCode;
  final bool isChecking;
  final VoidCallback onCheckAttendance;

  const AsistenciaCard({
    super.key,
    required this.statusCode,
    required this.onCheckAttendance,
    this.isChecking = false,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    IconData iconData;
    String statusText;

    if (isChecking) {
      cardColor = const Color(0xFFFFC75F);
      iconData = Icons.refresh;
      statusText = "Verificando asistencia...";
    } else if (statusCode == "present") {
      cardColor = const Color(0xFFA2CF68);
      iconData = Icons.check_circle;
      statusText = "Asistencia registrada";
    } else if (statusCode == "late") {
      cardColor = const Color(0xFFFFC878);
      iconData = Icons.access_time;
      statusText = "Llegaste tarde";
    } else if (statusCode == "error") {
      cardColor = const Color(0xFFB0BEC5);
      iconData = Icons.error;
      statusText = "Error al registrar";
    } else {
      cardColor = const Color(0xFFFF0967);
      iconData = Icons.close;
      statusText = "No se ha registrado tu asistencia";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        color: cardColor,
        borderRadius: BorderRadius.circular(8),//16
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 🔹 TÍTULO SUPERIOR
          const Text(
            "Asistencia",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // LÍNEA DIVISORIA
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white,
          ),

          const SizedBox(height: 12),

          // 🔹 FILA PRINCIPAL: texto - icon - botón
          Row(
            children: [
              // Texto del estado
              Expanded(
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),

              // Ícono del estado
              Icon(iconData, size: 32, color: Colors.white),

              const SizedBox(width: 12),

              // Botón circular (refresh)
              GestureDetector(
                onTap: isChecking ? null : onCheckAttendance,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: Colors.white),
                  ),
                  child: Center(
                    child: isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}



class _Pill extends StatelessWidget {
  final String texto;
  final Color background;
  final Color textColor;

  const _Pill({
    required this.texto,
    required this.background,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 14, color: textColor),
      ),
    );
  }
}

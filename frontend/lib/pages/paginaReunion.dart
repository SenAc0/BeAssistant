import 'package:flutter/material.dart';
import 'package:myapp/api_service.dart';
import 'package:myapp/pages/beacon_service.dart';
//import 'package:myapp/pages/crearReunion3.dart';

class PaginaReunion extends StatefulWidget {
  final int meetingID;
  
  const PaginaReunion({super.key, required this.meetingID});

  @override
  State<PaginaReunion> createState() => _PaginaReunionState();
}

class _PaginaReunionState extends State<PaginaReunion>{
  Map<String, dynamic>? _reunion;
  bool _loading = true;
  String? _error;
  String? _beaconID;
  final BeaconService _beaconService = BeaconService();
  bool _isCheckingAttendance = false;
  String _attendanceStatus = "Ausente";

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
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }
  Future<void> markAttendance() async {
    if (_beaconID == null || _beaconID!.isEmpty) {
      setState(() {
        _attendanceStatus = "Error: No hay beacon configurado";
      });
      return;
    }

    setState(() {
      _isCheckingAttendance = true;
      _attendanceStatus = "Verificando...";
    });

    try {
      final detected = await _beaconService.detectBeacon(_beaconID!);
      
      setState(() {
        _isCheckingAttendance = false;
        if (detected) {
          _attendanceStatus = "Presente";
          print('Asistencia marcada para la reunión ${widget.meetingID}');
        } else {
          _attendanceStatus = "Ausente";
          print('Beacon no detectado para la reunión ${widget.meetingID}');
        }
      });
    } catch (e) {
      setState(() {
        _isCheckingAttendance = false;
        _attendanceStatus = "Error: $e";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando...'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null){
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_reunion?['title'] ?? 'Reunión'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SesionCard(
              tituloSesion: _reunion?['title'] ?? 'Sin título',
              fecha: _formatDate(_reunion?['start_time']),
              hora: _formatHora(_reunion?['start_time']),
              coordinador: _reunion?['coordinator']?['name'] ?? 'Sin coordinador',
              sala: _reunion?['location'] ?? 'Sin sala',
            ),
            const SizedBox(height: 12),
            
            if (_reunion?['topics'] != null && _reunion!['topics'].isNotEmpty)
              TopicoCard(
                titulo: _reunion?['topics'] ?? 'Sin título',
                descripcion: _reunion?['description'] ?? 'Sin tópicos',
              ),
            
            const SizedBox(height: 12),
        
            if (_reunion?['note'] != null && _reunion!['note'].isNotEmpty)
              NotaCard(
                descripcionNota: _reunion?['note'] ?? 'Sin notas',
              ),
            
            const SizedBox(height: 12),
          
            AsistenciaCard(
              asistencia: _attendanceStatus,
              isChecking: _isCheckingAttendance,
              onCheckAttendance: markAttendance,
            ),
          ],
        ),
      ),
    );
  }
  String _formatDate(String? iso) {
    if (iso == null) return 'Sin fecha';
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return 'Sin fecha';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Sin fecha';
    }
  }

  String _formatHora(String? iso) {
    if (iso == null) return 'Sin hora';
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return 'Sin hora';
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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

  const SesionCard({
    super.key,
    required this.tituloSesion,
    required this.fecha,
    required this.hora,
    required this.coordinador,
    required this.sala,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 60, 157, 237),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          'Sesión: $tituloSesion',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              '$fecha - $hora',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Coordinador ',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    coordinador,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Sala ', style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Text(
                    sala,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TopicoCard extends StatelessWidget {
  final String titulo;
  final String descripcion;
  const TopicoCard({
    super.key,
    required this.titulo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(251, 223, 223, 90),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Topico: $titulo',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Descripción: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: descripcion,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
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
      height: 130,
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(228, 236, 157, 94),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text(
          'Nota',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          descripcionNota,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class AsistenciaCard extends StatelessWidget {
  final String asistencia;
  final bool isChecking;
  final VoidCallback onCheckAttendance;

  const AsistenciaCard({
    super.key, 
    required this.asistencia,
    this.isChecking = false,
    required this.onCheckAttendance,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    IconData iconData;
    String statusText;

    if (isChecking) {
      cardColor = Colors.orange;
      iconData = Icons.refresh;
      statusText = "Verificando asistencia...";
    } else if (asistencia == "Presente") {
      cardColor = const Color.fromARGB(255, 61, 200, 72);
      iconData = Icons.check;
      statusText = "Tu asistencia ha sido registrada";
    } else if (asistencia.startsWith("Error")) {
      cardColor = Colors.grey;
      iconData = Icons.error;
      statusText = asistencia;
    } else {
      cardColor = const Color.fromARGB(255, 237, 78, 78);
      iconData = Icons.close;
      statusText = "Tu asistencia no ha sido registrada";
    }

    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Asistencia",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),

              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: isChecking ? null : onCheckAttendance,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
                child: isChecking 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

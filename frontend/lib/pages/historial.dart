import 'package:flutter/material.dart';
import 'package:myapp/api_service.dart';
import 'package:myapp/pages/reporteReunion.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});
  @override
  State<Historial> createState() => _HistorialState();
  
}

class _HistorialState extends State<Historial> {
  List<dynamic> reunionesSemana = [];
  List<dynamic> reunionesMesPasado = [];
  List<dynamic> reunionesAntiguas = [];
  bool cargando = true;
  bool mostrarSoloCoordinador = false;


  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }

  Future<void> cargarHistorial() async {
    final allMeetings = await ApiService().getMyMeetings();
    final perfil = await ApiService().getProfile();
    final int myUserId = perfil?['id'] ?? 0;


    if (allMeetings == null) {
      setState(() => cargando = false);
      return;
    }

    // Also fetch user's attendances to mark presence/absence
    List<dynamic> myAttendances = [];
    try {
      myAttendances = await ApiService().getMyAttendances();
    } catch (_) {
      // If the request fails, we'll assume no attendances.
      myAttendances = [];
    }

    // Build a map meetingId -> status for quick lookup
    final Map<String, String> attendanceMap = {};
    for (final a in myAttendances) {
      try {
        final mid = a['meeting_id']?.toString();
        final status = a['status']?.toString();
        if (mid != null && status != null) attendanceMap[mid] = status;
      } catch (_) {
        // ignore malformed entry
      }
    }

    // Consider only meetings that already finished (end_time < now).
    // If end_time is missing, fall back to start_time.
    final now = DateTime.now();
    final past = <dynamic>[];
    for (final m in allMeetings) {
      final endStr = m['end_time'] ?? m['start_time'];
      if (endStr == null) continue;
      final endDt = DateTime.tryParse(endStr.toString());
      if (endDt == null) continue;
      if (endDt.toLocal().isBefore(now)) {
        past.add(m);
      }
    }

    // Group by how long ago the meeting ended (based on end_time fallback)
    final semana = past.where((m) {
      final endStr = m['end_time'] ?? m['start_time'];
      final fecha = DateTime.parse(endStr).toLocal();
      return fecha.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    final mes = past.where((m) {
      final endStr = m['end_time'] ?? m['start_time'];
      final fecha = DateTime.parse(endStr).toLocal();
      final within30 = fecha.isAfter(now.subtract(const Duration(days: 30)));
      return within30 && fecha.isBefore(now.subtract(const Duration(days: 7)));
    }).toList();

    final antiguas = past.where((m) {
      final endStr = m['end_time'] ?? m['start_time'];
      final fecha = DateTime.parse(endStr).toLocal();
      return fecha.isBefore(now.subtract(const Duration(days: 30)));
    }).toList();

    // Sort each list by start_time descending (most recent first)
    int cmpByStartDesc(a, b) {
      final da = DateTime.tryParse(a['start_time'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db_ = DateTime.tryParse(b['start_time'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return db_.compareTo(da);
    }

    semana.sort(cmpByStartDesc);
    mes.sort(cmpByStartDesc);
    antiguas.sort(cmpByStartDesc);

    // Attach attendance status to each meeting object for UI rendering
    String lookupStatus(dynamic meeting) {
      final mid = meeting['id']?.toString() ?? meeting['meeting_id']?.toString();
      if (mid == null) return 'Ausente';
      final s = attendanceMap[mid];
      if (s != null && s.toLowerCase() == 'present') return 'Presente';
      return 'Ausente';
    }

    for (final m in semana) {
      m['_asistencia_label'] = lookupStatus(m);
    }
    for (final m in mes) {
      m['_asistencia_label'] = lookupStatus(m);
    }
    for (final m in antiguas) {
      m['_asistencia_label'] = lookupStatus(m);
    }
    setState(() {
      reunionesSemana = semana;
      reunionesMesPasado = mes;
      reunionesAntiguas = antiguas;

      if (mostrarSoloCoordinador) {
        reunionesSemana = reunionesSemana
            .where((m) => m["coordinator_id"] == myUserId)
            .toList();

        reunionesMesPasado = reunionesMesPasado
            .where((m) => m["coordinator_id"] == myUserId)
            .toList();

        reunionesAntiguas = reunionesAntiguas
            .where((m) => m["coordinator_id"] == myUserId)
            .toList();
      }

      cargando = false;
    });

  }

  List<dynamic> filtrarEstaSemana(List<dynamic> meetings) {
    final now = DateTime.now();
    final inicioSemana = now.subtract(Duration(days: now.weekday - 1));
    final finSemana = inicioSemana.add(const Duration(days: 7));

    return meetings.where((m) {
      final fecha = DateTime.parse(m["start_time"]).toLocal();
      return fecha.isAfter(inicioSemana) && fecha.isBefore(finSemana);
    }).toList();
  }

  List<dynamic> filtrarMesPasado(List<dynamic> meetings) {
    final now = DateTime.now();
    final mesPasado = DateTime(now.year, now.month - 1);

    final inicio = DateTime(mesPasado.year, mesPasado.month, 1);
    final fin = DateTime(mesPasado.year, mesPasado.month + 1, 1);

    return meetings.where((m) {
      final fecha = DateTime.parse(m["start_time"]).toLocal();
      return fecha.isAfter(inicio) && fecha.isBefore(fin);
    }).toList();
  }
  

  String formatearFechaTexto(DateTime fecha) {
    const dias = [
      "Lunes", "Martes", "Miércoles", "Jueves",
      "Viernes", "Sábado", "Domingo"
    ];
    const meses = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo",
      "Junio", "Julio", "Agosto", "Septiembre",
      "Octubre", "Noviembre", "Diciembre"
    ];

    final dia = dias[fecha.weekday - 1];
    final mes = meses[fecha.month - 1];

    return "$dia, ${fecha.day} $mes ${fecha.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
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
        title: const Text('Historial'),
        centerTitle: true,
        elevation: 0,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: ListView(
                children: [
                  CoordinadorCard(
                    value: mostrarSoloCoordinador,
                    onChanged: (value) {
                      setState(() {
                        mostrarSoloCoordinador = value;
                      });
                      cargarHistorial();  
                    },
                  ),

                  const SizedBox(height: 20),


                  // Esta semana
                  if (reunionesSemana.isNotEmpty) ...[
                    Text("Esta semana",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...reunionesSemana.map((m) {
                      final inicio = DateTime.parse(m['start_time']).toLocal();
                      final fin = m['end_time'] != null
                          ? DateTime.parse(m['end_time']).toLocal()
                          : null;

                      final asistencia = m['_asistencia_label'] ?? "Ausente";

                      return ListaCard(
                        nombre: m["title"] ?? "Reunión sin título",
                        fecha: formatearFechaTexto(inicio),
                        hora:
                            "${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')} - "
                            "${fin != null ? "${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}" : "--"}",
                        asistencia: asistencia,
                        onTap: mostrarSoloCoordinador ? () {
                          
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (_) => ReporteReunion(),
                             ),
                           );
                         } : null, 
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // Mes pasado (7-30 días)
                  if (reunionesMesPasado.isNotEmpty) ...[
                    Text("Mes pasado",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...reunionesMesPasado.map((m) {
                      final inicio = DateTime.parse(m['start_time']).toLocal();
                      final fin = m['end_time'] != null
                          ? DateTime.parse(m['end_time']).toLocal()
                          : null;

                      final asistencia = m['_asistencia_label'] ?? "Ausente";

                      return ListaCard(
                        nombre: m["title"] ?? "Reunión sin título",
                        fecha: formatearFechaTexto(inicio),
                        hora:
                            "${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')} - "
                            "${fin != null ? "${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}" : "--"}",
                        asistencia: asistencia,
                        onTap: mostrarSoloCoordinador ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReporteReunion(),
                            ),
                          );
                        } : null,
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // Antiguas (>30 días)
                  if (reunionesAntiguas.isNotEmpty) ...[
                    Text("Antiguas",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...reunionesAntiguas.map((m) {
                      final inicio = DateTime.parse(m['start_time']).toLocal();
                      final fin = m['end_time'] != null
                          ? DateTime.parse(m['end_time']).toLocal()
                          : null;

                      final asistencia = m['_asistencia_label'] ?? "Ausente";

                      return ListaCard(
                        nombre: m["title"] ?? "Reunión sin título",
                        fecha: formatearFechaTexto(inicio),
                        hora:
                            "${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')} - "
                            "${fin != null ? "${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}" : "--"}",
                        asistencia: asistencia,
                        onTap: mostrarSoloCoordinador ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReporteReunion(),
                            ),
                          );
                        } : null,
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // Empty state if nothing
                  if (reunionesSemana.isEmpty && reunionesMesPasado.isEmpty && reunionesAntiguas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text('No hay reuniones pasadas.')),
                    ),
                ],
              ),
            ),
    );
  }
}

class ListaCard extends StatelessWidget {
  final String hora;
  final String fecha;
  final String asistencia;
  final String nombre;
  final VoidCallback? onTap;

  const ListaCard({
    super.key,
    required this.hora,
    required this.fecha,
    required this.asistencia,
    required this.nombre,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool estaPresente = asistencia.toLowerCase() == "presente";
    final bool pendiente = asistencia.toLowerCase() == "pendiente";

    return InkWell(
      onTap: onTap,
       borderRadius: BorderRadius.circular(10),
      splashColor: Colors.purple.withOpacity(0.2),
      highlightColor: Colors.transparent,
      child: Card(
      color: Colors.white,
      elevation: 6, 
      shadowColor: Color(0xFFAF79F2), 
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: pendiente
                    ? Colors.grey
                    : (estaPresente ? Color(0xFFA2CF68) : Color(0xFFFF0967)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                pendiente
                    ? Icons.help_outline
                    : (estaPresente ? Icons.check : Icons.close),
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    fecha,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    hora,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            Text(
              asistencia,
              style: TextStyle(
                color: pendiente
                    ? Colors.grey
                    : (estaPresente ? Color(0xFFA2CF68) : Color(0xFFFF0967)),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}



class CoordinadorCard extends StatefulWidget {
  final bool value;
  final Function(bool) onChanged;

  const CoordinadorCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CoordinadorCard> createState() => _CoordinadorCardState();
}


class _CoordinadorCardState extends State<CoordinadorCard> {
  bool notificacionesActivadas = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFAF79F2).withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: ListTile(
    leading: const Icon(Icons.manage_accounts, color: Colors.black),
    title: const Text(
      'Mis reuniones como coordinador',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
    subtitle: const Text('Filtra para ver solo reuniones que coordinaste'),
    trailing: Switch(
      value: widget.value,       
      onChanged: (value) {
        widget.onChanged(value); 
      },
      activeColor: const Color(0xFFAF79F2),
    )
  ),
),


      ],
    );
  }
}

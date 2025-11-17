import 'package:flutter/material.dart';
import 'package:myapp/api_service.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});
  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  List<dynamic> reunionesSemana = [];
  List<dynamic> reunionesMesPasado = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }

  Future<void> cargarHistorial() async {
    final allMeetings = await ApiService().getMeetings();

    if (allMeetings == null) {
      setState(() => cargando = false);
      return;
    }

    final semana = filtrarEstaSemana(allMeetings);
    final mesPasado = filtrarMesPasado(allMeetings);

    setState(() {
      reunionesSemana = semana;
      reunionesMesPasado = mesPasado;
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Historial'),
        centerTitle: true,
        elevation: 0,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: [
                  Text("Esta semana",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  ...reunionesSemana.map((m) {
                    final inicio = DateTime.parse(m['start_time']).toLocal();
                    final fin = m['end_time'] != null
                        ? DateTime.parse(m['end_time']).toLocal()
                        : null;

                    final bool esFuturo = inicio.isAfter(DateTime.now());
                    final asistencia = esFuturo ? "Pendiente" : "Presente";

                    return ListaCard(
                      nombre: m["title"] ?? "Reunión sin título",
                      fecha: formatearFechaTexto(inicio),
                      hora:
                          "${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')} - "
                          "${fin != null ? "${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}" : "--"}",
                      asistencia: asistencia,
                    );
                  }),

                  const SizedBox(height: 20),
                  Text("Mes pasado",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  ...reunionesMesPasado.map((m) {
                    final inicio = DateTime.parse(m['start_time']).toLocal();
                    final fin = m['end_time'] != null
                        ? DateTime.parse(m['end_time']).toLocal()
                        : null;

                    final bool esFuturo = inicio.isAfter(DateTime.now());
                    final asistencia = esFuturo ? "Pendiente" : "Ausente";

                    return ListaCard(
                      nombre: m["title"] ?? "Reunión sin título",
                      fecha: formatearFechaTexto(inicio),
                      hora:
                          "${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')} - "
                          "${fin != null ? "${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}" : "--"}",
                      asistencia: asistencia,
                    );
                  }),
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

  const ListaCard({
    super.key,
    required this.hora,
    required this.fecha,
    required this.asistencia,
    required this.nombre,
  });

  @override
  Widget build(BuildContext context) {
    final bool estaPresente = asistencia.toLowerCase() == "presente";
    final bool pendiente = asistencia.toLowerCase() == "pendiente";

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: pendiente
                    ? Colors.grey
                    : (estaPresente ? Colors.green : Colors.red),
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
                    : (estaPresente ? Colors.green : Colors.red),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

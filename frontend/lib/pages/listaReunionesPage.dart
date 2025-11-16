import 'package:flutter/material.dart';
//import 'package:myapp/pages/crearReunion1.dart';
import 'package:myapp/pages/paginaReunion.dart';
import 'package:myapp/api_service.dart';
import 'package:timezone/timezone.dart' as tz;

class ListaReunionesScreen extends StatefulWidget {
  const ListaReunionesScreen({super.key});

  @override
  State<ListaReunionesScreen> createState() => _ListaReunionesScreenState();
}

class _ListaReunionesScreenState extends State<ListaReunionesScreen> {
  final ApiService apiService = ApiService();
  bool _loading = false;
  String? _error;
  List<dynamic> _meetings = [];

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await apiService.getMyMeetings();
      if (data == null) {
        setState(() {
          _error = 'No se pudieron obtener las reuniones.';
          _meetings = [];
        });
      } else {
        setState(() {
          _meetings = data;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _meetings = [];
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return 'Fecha no disponible';
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return iso;

      // Try to convert to America/Santiago using timezone package.
      // Ensure you called timezone.initializeTimeZones() in main.dart at app startup.
      try {
        final loc = tz.getLocation('America/Santiago');
        final tz.TZDateTime chileDt = tz.TZDateTime.from(dt, loc);
        return '${chileDt.day}/${chileDt.month}/${chileDt.year} - ${chileDt.hour.toString().padLeft(2, '0')}:${chileDt.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        // If timezone DB not initialized, fallback to device local
        final local = dt.toLocal();
        return '${local.day}/${local.month}/${local.year} - ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Reuniones"),
        centerTitle: true,
      ),

      // --- CONTENIDO PRINCIPAL ---
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMeetings,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // --- BUSCADOR ---
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar reuniones...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      // Aquí podrías implementar búsqueda local
                    },
                  ),
                  const SizedBox(height: 10),

                  // --- BOTONES DE FILTRO ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      FilterButton(text: 'Todas'),
                      FilterButton(text: 'Próximas'),
                      FilterButton(text: 'En curso'),
                    ],
                  ),
                  const SizedBox(height: 15),

                  if (_loading) const CircularProgressIndicator(),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // --- LISTA DE REUNIONES ---
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _meetings.length,
                    itemBuilder: (context, index) {
                      final m = _meetings[index];
                      final title = m['title'] ?? 'Reunión sin título';
                      final start = _formatDate(m['start_time']);
                      final id = m['id'];

                      return ReunionCard(titulo: title, fecha: start, meetingId: id,);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // --- BOTÓN FLOTANTE PARA CREAR NUEVA REUNIÓN ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/crearReunion1');
        },
        backgroundColor: Colors.blueAccent,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- BOTÓN DE FILTRO ---
class FilterButton extends StatelessWidget {
  final String text;
  const FilterButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text),
    );
  }
}

// --- TARJETA DE REUNIÓN ---
class ReunionCard extends StatelessWidget {
  final String titulo;
  final String fecha;
  final int meetingId;
  
  const ReunionCard({super.key, required this.titulo, required this.fecha, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(fecha),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaginaReunion(meetingID: meetingId)),
          );
        },
      ),
    );
  }
}

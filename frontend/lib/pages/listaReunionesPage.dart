import 'package:flutter/material.dart';
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

  // --- FILTRADO ---
  List<dynamic> _filteredMeetings = [];
  String _selectedFilter = "Todas";
  String _searchQuery = ""; // Texto de búsqueda

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  // Convierte ISO string a DateTime local 
  DateTime? _parse(String? raw) {
    if (raw == null) return null;
    try {
      final dt = DateTime.parse(raw); // reconoce offsets como +00
      return dt.toLocal();
    } catch (_) {
      return null;
    }
  }

  // Getter que indica si hay al menos una reunión en curso
  bool get _hasOngoing {
    final now = DateTime.now();
    return _meetings.any((m) {
      final start = _parse(m['start_time']);
      final end = _parse(m['end_time']);
      if (start == null || end == null) return false;
      return now.isAfter(start) && now.isBefore(end);
    });
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
          _filteredMeetings = [];
        });
      } else {
        setState(() {
          _meetings = data;
          _applyFilter(); // aplicar filtro después de cargar
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _meetings = [];
        _filteredMeetings = [];
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Aplica el filtro seleccionado + búsqueda
  void _applyFilter() {
    final now = DateTime.now(); // local time

    DateTime? parse(String? raw) {
      if (raw == null) return null;
      try {
        final dt = DateTime.parse(raw); 
        return dt.toLocal(); // convertir UTC → local
      } catch (_) {
        return null;
      }
    }

    // Primer filtro: por categoría (Todas/Próximas/En curso)
    List<dynamic> tempFiltered;

    if (_selectedFilter == "Todas") {
      // Mostrar solo reuniones actuales/futuras: excluir las que tienen end_time < now
      tempFiltered = _meetings.where((m) {
        final end = parse(m['end_time']);
        if (end == null) return true; // sin end_time, mantener
        return !end.isBefore(now); // end >= now -> mantener
      }).toList();
    }
    // ===================== PRÓXIMAS =====================
    else if (_selectedFilter == "Próximas") {
      final limit = now.add(const Duration(days: 7));

      tempFiltered = _meetings.where((m) {
        final start = parse(m["start_time"]);
        if (start == null) return false;
        return start.isAfter(now) && start.isBefore(limit);
      }).toList();
    }
    // ===================== EN CURSO =====================
    else if (_selectedFilter == "En curso") {
      tempFiltered = _meetings.where((m) {
        final start = parse(m["start_time"]);
        final end = parse(m["end_time"]); 
        if (start == null || end == null) return false;
        return now.isAfter(start) && now.isBefore(end);
      }).toList();
    } else {
      tempFiltered = List.from(_meetings);
    }

    // Segundo filtro: por texto de búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      tempFiltered = tempFiltered.where((m) {
        final title = (m['title'] ?? '').toString().toLowerCase();
        final description = (m['description'] ?? '').toString().toLowerCase();
        final topics = (m['topics'] ?? '').toString().toLowerCase();
        
        // Busca en título, descripción o tópicos
        return title.contains(query) || 
               description.contains(query) || 
               topics.contains(query);
      }).toList();
    }

    _filteredMeetings = tempFiltered;
    setState(() {});
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
      //backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
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
        title: const Text("Sesiones"),
        centerTitle: true,
      ),

      // === CONTENIDO PRINCIPAL ===
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMeetings,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [

                  // === BUSCADOR ===
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      
                      // Obtener títulos únicos 
                      final query = textEditingValue.text.toLowerCase();
                      return _meetings
                          .map((m) => m['title']?.toString() ?? '')
                          .where((title) => title.toLowerCase().contains(query))
                          .toSet(); // Elimina duplicados
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _searchQuery = selection;
                        _applyFilter();
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Buscar reuniones...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    controller.clear();
                                    setState(() {
                                      _searchQuery = "";
                                      _applyFilter();
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _applyFilter();
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // === BOTONES DE FILTRO ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilterButton(
                        text: 'Todas',
                        active: _selectedFilter == "Todas",
                        onTap: () {
                          setState(() {
                            _selectedFilter = "Todas";
                            _applyFilter();
                          });
                        },
                      ),
                      FilterButton(
                        text: 'Próximas',
                        active: _selectedFilter == "Próximas",
                        onTap: () {
                          setState(() {
                            _selectedFilter = "Próximas";
                            _applyFilter();
                          });
                        },
                      ),
                      FilterButton(
                        text: 'En curso',
                        showBadge: _hasOngoing,
                        active: _selectedFilter == "En curso",
                        onTap: () {
                          setState(() {
                            _selectedFilter = "En curso";
                            _applyFilter();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  if (_loading) const CircularProgressIndicator(),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFFFF0967)),
                      ),
                    ),

                  // === LISTA DE REUNIONES ===
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredMeetings.length,
                    itemBuilder: (context, index) {
                      final m = _filteredMeetings[index];
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
        elevation: 6, 
        backgroundColor: Color(0xFFB897E6),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- BOTÓN DE FILTRO ---
class FilterButton extends StatelessWidget {
  final String text;
  final bool active;
  final bool showBadge;      // nuevo
  final VoidCallback onTap;
  const FilterButton({
    super.key,
    required this.text,
    required this.active,
    required this.onTap,
    this.showBadge = false,  // por defecto false
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // permite posicionar el badge fuera del botón si es necesario
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.black,
            backgroundColor: active ? Color(0xFFAF79F2) : Colors.grey[300],
            foregroundColor: active ? Colors.white : Colors.black,
            elevation: active ? 1 : 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(text),
        ),

        // Badge posicionado en la esquina superior derecha del botón
        if (showBadge)
          Positioned(
            right: -6, 
            top: -6,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Color(0xFFA2CF68),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
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
      color: Colors.white,
      elevation: 6, 
      shadowColor: Color(0xFFAF79F2), 
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

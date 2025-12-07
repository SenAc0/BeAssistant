import 'package:flutter/material.dart';
import 'package:myapp/api_service.dart';

class CrearReunion3 extends StatefulWidget {
  final int meetingId;

  const CrearReunion3({super.key, required this.meetingId});

  @override
  State<CrearReunion3> createState() => _CrearReunion3State();
}

class _CrearReunion3State extends State<CrearReunion3> {
  List<int> asistentesSeleccionados = [];
  bool _cargadoInicial =
      false; // evita sobrescribir la selección al reconstruir

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Asistentes'),
      ),

      //  CARGA USUARIOS + ASISTENTES YA AGREGADOS
      body: FutureBuilder(
        future: Future.wait([
          ApiService().getUsers(),
          ApiService().getAttendanceForMeeting(widget.meetingId),
          ApiService().getMeeting(widget.meetingId),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final usuariosRaw = snapshot.data![0] as List<dynamic>;
          final asistentes = snapshot.data![1] as List<dynamic>;
          final meeting = snapshot.data![2] as Map<String, dynamic>;

          final coordinatorId = meeting["coordinator_id"];

          // FILTRAR ADMIN Y COORDINADOR 
          final usuarios = usuariosRaw
              .where((u) => u["is_admin"] == false && u["id"] != coordinatorId)
              .toList();

          // Cargar asistentes preseleccionados solo la primera vez
          if (!_cargadoInicial) {
            asistentesSeleccionados = asistentes
                .map<int>((a) => a["user_id"] as int)
                .toList();
            _cargadoInicial = true;
          }


          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Agregar asistentes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 10),

                // LISTA DE USUARIOS
               Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ListView(
                    children: usuarios.map((user) {
                      final id = user["id"];
                      final yaSeleccionado = asistentesSeleccionados.contains(
                        id,
                      );

                      return AgregarAsistenteCard(
                        key: Key("user_$id"),
                        userId: id,
                        nombre: user["name"],
                        correo: user["email"],
                        inicialmenteSeleccionado: yaSeleccionado,
                        onSelected: (id, selected) {
                          setState(() {
                            if (selected) {
                              asistentesSeleccionados.add(id);
                            } else {
                              asistentesSeleccionados.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),


                const SizedBox(height: 10),
                Center(child: BotonesReunion3(onConfirm: guardarAsistentes)),
              ],
            ),
          );
        },
      ),
    );
  }

 //GUARDAR CAMBIOS (agregar + quitar)
  Future<void> guardarAsistentes() async {
    final asistentesBackend =
        await ApiService().getAttendanceForMeeting(widget.meetingId);

    final asistentesActuales =
        asistentesBackend.map<int>((a) => a["user_id"] as int).toList();

    bool todoOK = true;

    // Agregar nuevos
    for (int id in asistentesSeleccionados) {
      if (!asistentesActuales.contains(id)) {
        bool ok = await ApiService().addAssistant(widget.meetingId, id);
        if (!ok) todoOK = false;
      }
    }

    // Eliminar los que ya no están seleccionados
    for (int id in asistentesActuales) {
      if (!asistentesSeleccionados.contains(id)) {
        bool ok = await ApiService().removeAssistant(widget.meetingId, id);
        if (!ok) todoOK = false;
      }
    }

    // Mensajes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          todoOK
              ? "Asistentes actualizados correctamente"
              : "Ocurrió un error con algunos usuarios",
        ),
      ),
    );

    Navigator.pop(context);
  }
}

// BOTONES DE CONFIRMAR/CANCELAR
class BotonesReunion3 extends StatelessWidget {
  final VoidCallback onConfirm;

  const BotonesReunion3({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFAF79F2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onConfirm,
            child: const Text('Confirmar', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0967),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

// --- WIDGET TARJETA DE REUNIÓN ---

class AgregarAsistenteCard extends StatefulWidget {
  final int userId;
  final String nombre;
  final String correo;
  final bool inicialmenteSeleccionado;
  final Function(int userId, bool selected) onSelected;

  const AgregarAsistenteCard({
    super.key,
    required this.userId,
    required this.nombre,
    required this.correo,
    required this.onSelected,
    this.inicialmenteSeleccionado = false,
  });

  @override
  State<AgregarAsistenteCard> createState() => _AgregarAsistenteCardState();
}

class _AgregarAsistenteCardState extends State<AgregarAsistenteCard> {
  late bool _seleccionado;

  @override
  void initState() {
    super.initState();
    _seleccionado = widget.inicialmenteSeleccionado;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Color(0xFFAF79F2), 
      color: _seleccionado
          ? const Color(0xFFA2CF68)
          : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          widget.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(widget.correo),
        trailing: Icon(
          _seleccionado ? Icons.remove : Icons.add,
          color: _seleccionado ? Colors.white : Colors.black,
        ),
        onTap: () {
          setState(() {
            _seleccionado = !_seleccionado;
          });

          widget.onSelected(widget.userId, _seleccionado);
        },
      ),
    );
  }
}

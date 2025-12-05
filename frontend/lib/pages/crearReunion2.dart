import 'package:flutter/material.dart';
import 'package:myapp/utils/homeNavigation.dart';
import '../api_service.dart';

class CrearReunion2 extends StatefulWidget {
  final Map<String, dynamic> dataReunion;

  const CrearReunion2({super.key, required this.dataReunion});

  @override
  State<CrearReunion2> createState() => _CrearReunion2State();
}

class _CrearReunion2State extends State<CrearReunion2> {
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;
  String? beaconSeleccionado; // <-- El ID real del beacon elegido

  late Future<List<dynamic>> futureBeacons;
  Future<bool>? futureCrear;

  @override
  void initState() {
    super.initState();
    futureBeacons = ApiService().getBeacons();
  }

  // -------------------- PICKERS -----------------------
  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365 * 6)),
    );

    if (fecha != null) {
      setState(() => fechaSeleccionada = fecha);
    }
  }

  Future<void> seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() => horaSeleccionada = hora);
    }
  }

  // -------------------- ENVIAR REUNIÓN -----------------------
  Future<bool> enviarReunion() async {
    final api = ApiService();

    final data = {
      "title": widget.dataReunion["title"],
      "description": widget.dataReunion["description"],
      "topics": widget.dataReunion["topics"],
      "note": widget.dataReunion["note"],
      "duration_minutes": widget.dataReunion["duration"],
      "repeat_weekly": false,
      "beacon_id": beaconSeleccionado, // <-- ahora se envía el ID real del beacon
      "start_time": fechaSeleccionada != null && horaSeleccionada != null
          ? DateTime(
        fechaSeleccionada!.year,
        fechaSeleccionada!.month,
        fechaSeleccionada!.day,
        horaSeleccionada!.hour,
        horaSeleccionada!.minute,
      ).toIso8601String()
          : null,
    };

    return await api.createMeeting(data);
  }

  // --------------------------------------------------------------
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
        title: const Text('Crear Reunión'),
      ),
      body: futureCrear == null
          ? _formulario()
          : FutureBuilder<bool>(
        future: futureCrear,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _mensajeResultado("Error al crear la reunión", Color(0xFFFF0967));
          }

          if (snapshot.data == true) {
            return _mensajeResultado("Reunión creada con éxito", Color(0xFF5BD107));
          }

          return _mensajeResultado("No se pudo crear la reunión", Color(0xFFFF0967));
        },
      ),
    );
  }

  // -------------------- FORMULARIO -----------------------
  Widget _formulario() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha
            const Text("Fecha", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: seleccionarFecha,
              style: ElevatedButton.styleFrom(
                elevation: 6, 
                shadowColor: Colors.black,
                backgroundColor: Colors.grey[300],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    fechaSeleccionada == null
                        ? "Seleccionar Fecha"
                        : "${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Hora
            const Text("Hora", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: seleccionarHora,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                elevation: 6, 
                shadowColor: Colors.black, 
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    horaSeleccionada == null
                        ? "Seleccionar Hora"
                        : "${horaSeleccionada!.hour.toString().padLeft(2, '0')}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            const Text("Sala / Beacon", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),

            _listaBeacons(),

            const SizedBox(height: 20),

            _botones(),
          ],
        ),
      ),
    );
  }

  // -------------------- LISTA DE BEACONS -----------------------
  Widget _listaBeacons() {
    return FutureBuilder<List<dynamic>>(
      future: futureBeacons,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final beacons = snapshot.data!;
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          height: screenHeight * 0.5, // 50% de la pantalla
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ListView.builder(
              //padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: beacons.length,
              itemBuilder: (context, index) {
                final b = beacons[index];
                final id = b["id"];
                final location = b["location"] ?? "Sin sala";
                final activo = true;

                return _salaCard(
                  id,
                  activo ? "Activo" : "Inactivo",
                  location,
                );
                
              },
            ),
          ),
        );
      },
    );
  }

  // -------------------- TARJETA -----------------------
  Widget _salaCard(String id, String estado, String sala) {
    bool seleccionado = beaconSeleccionado == id;

    return GestureDetector(
      onTap: () => setState(() => beaconSeleccionado = id),
      child: Card(
        elevation: 6, 
        shadowColor: Color(0xFFAF79F2),
        color: seleccionado ? Color(0xFFA2CF68) : Colors.white,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          title: Text(
            id,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("$estado | $sala"),
        ),
      ),
    );
  }

  // -------------------- BOTONES -----------------------
  Widget _botones() {
    return Center(
      child: Column(
        children: [
          // Confirmar
          SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 6, 
                shadowColor: Colors.black,
                backgroundColor: Color(0xFFAF79F2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (fechaSeleccionada == null ||
                    horaSeleccionada == null ||
                    beaconSeleccionado == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Completa todos los campos")),
                  );
                  return;
                }

                setState(() {
                  futureCrear = enviarReunion();
                });
              },
              child: const Text("Confirmar"),
            ),
          ),

          const SizedBox(height: 20),

          // Cancelar
          SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 6, 
                shadowColor: Color.fromARGB(255, 180, 15, 15),
                backgroundColor: Color(0xFFFF0967),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => volverAlInicio(context),
              child: const Text("Cancelar"),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- RESULTADO -----------------------
  Widget _mensajeResultado(String texto, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: color, size: 60),
          const SizedBox(height: 20),
          Text(texto, style: TextStyle(fontSize: 20, color: color)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => volverAlInicio(context),
            child: const Text("Volver al inicio"),
          ),
        ],
      ),
    );
  }
}

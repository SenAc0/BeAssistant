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
  String? salaSeleccionada;

  Future<bool>? futureCrear;

  // --- PICKERS ---
  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (fecha != null) {
      setState(() {
        fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        horaSeleccionada = hora;
      });
    }
  }

  // --- ENVIAR A LA API ---
  Future<bool> enviarReunion() async {
    final api = ApiService();

 final data = {
  "title": widget.dataReunion["title"],
  "description": widget.dataReunion["description"],
  "topics": widget.dataReunion["topics"],
  "note": widget.dataReunion["note"],
  "duration_minutes": widget.dataReunion["duration"],        
  "repeat_weekly": false,                                    // O según  UI
  "beacon_id": "fda50693a4e24fb1afcfc6eb07647825271b4cb99c",                             // Cambiar según  backend
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Crear Reunión'),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),

      // -------------------------- BODY -------------------------------
      body: futureCrear == null
          ? _formulario()
          : FutureBuilder<bool>(
              future: futureCrear,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _mensajeResultado(
                    "Error al crear la reunión",
                    Colors.red,
                  );
                }

                if (snapshot.data == true) {
                  return _mensajeResultado(
                    "Reunión creada con éxito",
                    Colors.green,
                  );
                }

                return _mensajeResultado(
                  "No se pudo crear la reunión",
                  Colors.red,
                );
              },
            ),
    );
  }

  // ------------------ WIDGET FORMULARIO --------------------
  Widget _formulario() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha
            const Text("Fecha", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: seleccionarFecha,
              style: ElevatedButton.styleFrom(
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

            // Sala / Beacon
            const Text("Sala / Beacon", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),

            _salaCard("Beacon A1-1", "Activo", "Oficina 1"),
            _salaCard("Beacon A1-2", "Inactivo", "Oficina 2"),

            const SizedBox(height: 20),
            _botones(),
          ],
        ),
      ),
    );
  }

  // ------------------- TARJETA DE SALAS ------------------------
  Widget _salaCard(String titulo, String estado, String lugar) {
    bool seleccionado = salaSeleccionada == titulo;

    return GestureDetector(
      onTap: () => setState(() => salaSeleccionada = titulo),
      child: Card(
        color: seleccionado ? Colors.green[300] : Colors.white,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          title: Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("$estado | $lugar"),
        ),
      ),
    );
  }

  // -------------------- BOTONES ------------------------
  Widget _botones() {
    return Center(
    child:Column(
      children: [
        // Confirmar
        SizedBox(
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
            ),
            onPressed: () {
              if (fechaSeleccionada == null ||
                  horaSeleccionada == null ||
                  salaSeleccionada == null) {
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
            ),
            onPressed: () => volverAlInicio(context),
            child: const Text("Cancelar"),
          ),
        ),
      ],
    ),
    );
  }

  // ------------------- RESULTADO FINAL ------------------------
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

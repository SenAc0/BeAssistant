import 'package:flutter/material.dart';
import 'package:myapp/pages/crearReunion2.dart';
import 'package:myapp/utils/homeNavigation.dart';

class CrearReunion1 extends StatefulWidget {
  const CrearReunion1({super.key});

  @override
  State<CrearReunion1> createState() => _CrearReunion1State();
}

class _CrearReunion1State extends State<CrearReunion1> {
  // ✅ Controllers para guardar los datos del formulario
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController duracionController = TextEditingController();
  final TextEditingController topicoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController notaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Crear Reunion'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // --- Nombre reunión ---
              const Text(
                'Nombre de la reunion',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  hintText: 'Reunión Semanal',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- Duración ---
              const Text('Duración (minutos)', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              TextField(
                controller: duracionController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '45',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- Tópico ---
              const Text('Tópico', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              TextField(
                controller: topicoController,
                decoration: InputDecoration(
                  hintText: 'Proyecto informático',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- Descripción ---
              const Text('Descripción', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              TextField(
                controller: descripcionController,
                decoration: InputDecoration(
                  hintText: 'En la sesión del viernes hablaremos sobre...',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- Nota ---
              const Text('Nota', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              TextField(
                controller: notaController,
                decoration: InputDecoration(
                  hintText: 'Recuerden llevar sus computadores',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    // ✅ Botón siguiente -> pasa los datos a crearReunion2
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            56,
                            140,
                            208,
                          ),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          // ✅ Enviar datos a CrearReunion2
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CrearReunion2(
                                dataReunion: {
                                  "title": nombreController.text,
                                  "duration":
                                      int.tryParse(duracionController.text) ??
                                      0,
                                  "topics": topicoController.text,
                                  "description": descripcionController.text,
                                  "note": notaController.text,
                                },
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Siguiente',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ✅ Botón cancelar
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            172,
                            48,
                            48,
                          ),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => volverAlInicio(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

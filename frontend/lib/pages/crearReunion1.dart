import 'package:flutter/material.dart';
import 'package:myapp/pages/crearReunion2.dart';
import 'package:myapp/utils/homeNavigation.dart';

class CrearReunion1 extends StatefulWidget {
  const CrearReunion1({super.key});

  @override
  State<CrearReunion1> createState() => _CrearReunion1State();
}

class _CrearReunion1State extends State<CrearReunion1> {
  //  Controllers para guardar los datos del formulario
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController duracionController = TextEditingController();
  final TextEditingController topicoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController notaController = TextEditingController();

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
        automaticallyImplyLeading: false,
        centerTitle: true,
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4), // hacia abajo
                    ),
                  ],
                ),
                child: TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    hintText: 'Reunión Semanal',
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- Duración ---
              const Text('Duración (minutos)', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4), // hacia abajo
                    ),
                  ],
                ),
                child: TextField(
                  controller: duracionController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '45',
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- Tópico ---
              const Text('Tópico', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4), // hacia abajo
                    ),
                  ],
                ),
                child:TextField(
                  controller: topicoController,
                  decoration: InputDecoration(
                    hintText: 'Proyecto informático',
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- Descripción ---
              const Text('Descripción', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4), // hacia abajo
                    ),
                  ],
                ),
                child: TextField(
                  controller: descripcionController,
                  decoration: InputDecoration(
                    hintText: 'En la sesión del viernes hablaremos sobre...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- Nota ---
              const Text('Nota', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4), // hacia abajo
                    ),
                  ],
                ),
                child: TextField(
                  controller: notaController,
                  decoration: InputDecoration(
                    hintText: 'Recuerden llevar sus computadores',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent, // IMPORTANTE: deja que el Container dé el color
                  ),
                ),
              ),


              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    //  Botón siguiente -> pasa los datos a crearReunion2
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 6, 
                          shadowColor: Colors.black,   
                          backgroundColor: const Color(0xFFAF79F2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          //Enviar datos a CrearReunion2
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

                    // Botón cancelar
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 6, 
                          shadowColor: Color.fromARGB(255, 180, 15, 15), 
                          backgroundColor: const Color(0xFFFF0967),
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

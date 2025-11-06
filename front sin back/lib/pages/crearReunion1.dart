import 'package:flutter/material.dart';
//import 'package:myapp/pages/listaReunionesPage.dart';
import 'package:myapp/pages/crearReunion2.dart';
import 'package:myapp/utils/homeNavigation.dart';

class CrearReunion1 extends StatelessWidget {
  const CrearReunion1({super.key});

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
          //padding: const EdgeInsets.all(12.0),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Nombre de la reunion',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 6),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Reunion Semanal',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  // Agregar lógica
                },
              ),
              const SizedBox(height: 10),

              const Text(
                'Duración (minutos)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  hintText: '45',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  // Agregar lógica
                },
              ),
              const SizedBox(height: 10),

              const Text(
                'Tópico',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Proyecto informático',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  // Agregar lógica
                },
              ),
              const SizedBox(height: 10),

              const Text(
                'Descripción',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  hintText: 'En la sesión del viernes 17 de Octubre...',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  // Agregar lógica
                },
              ),
              const SizedBox(height: 10),

              const Text(
                'Nota',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Recuerden llevar sus computadores',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  // Agregar lógica
                },
              ),
              const SizedBox(height: 20),
              Center(child: BotonesReunion1()),
            ],
          ),
        ),
      ),
    );
  }
}

class BotonesReunion1 extends StatelessWidget {
  const BotonesReunion1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón de siguiente
        SizedBox(
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 56, 140, 208),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CrearReunion2()),
              );
            },
            child: const Text('Siguiente', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 20),
        // Botón de cancelar
        SizedBox(
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 172, 48, 48),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              volverAlInicio(context);
            },
            child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

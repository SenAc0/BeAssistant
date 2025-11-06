import 'package:flutter/material.dart';
import 'package:myapp/pages/listaReunionesPage.dart';
//import 'package:myapp/pages/crearReunion2.dart';
import 'package:myapp/utils/homeNavigation.dart';

class CrearReunion3 extends StatelessWidget {
  const CrearReunion3({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Crear Reunion'),
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Agregar asistentes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),

            const SizedBox(height: 6),

            // --- EJEMPLO LISTA DE REUNIONES ---
            Expanded(
              child: ListView(
                children: const [
                  AgregarAsistenteCard(nombre: 'algo ', correo: 'algo@udec.cl'),
                  AgregarAsistenteCard(
                    nombre: 'algo 2',
                    correo: 'algo2@gmail.com',
                  ),
                ],
              ),
            ),
            Center(child: BotonesReunion3()),
          ],
        ),
      ),
    );
  }
}

class BotonesReunion3 extends StatelessWidget {
  const BotonesReunion3({super.key});

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
                MaterialPageRoute(
                  builder: (context) => const ListaReunionesScreen(),
                ),
              );
            },
            child: const Text('Crear Reunion', style: TextStyle(fontSize: 16)),
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

// --- WIDGET TARJETA DE REUNIÓN ---
class AgregarAsistenteCard extends StatefulWidget {
  final String nombre;
  final String correo;
  const AgregarAsistenteCard({
    super.key,
    required this.nombre,
    required this.correo,
  });

  @override
  State<AgregarAsistenteCard> createState() => _AgregarAsistenteCardState();
}

class _AgregarAsistenteCardState extends State<AgregarAsistenteCard> {
  bool _seleccionado = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: _seleccionado
          ? const Color.fromARGB(255, 87, 177, 60)
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
          if (!_seleccionado) {
            setState(() {
              _seleccionado = !_seleccionado;
            });
          } else {
            setState(() {
              _seleccionado = !_seleccionado;
            });
          }
        },
      ),
    );
  }
}

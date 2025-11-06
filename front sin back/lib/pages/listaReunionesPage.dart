import 'package:flutter/material.dart';
//import 'package:myapp/pages/crearReunion1.dart';
import 'package:myapp/pages/paginaReunion.dart';

class ListaReunionesScreen extends StatelessWidget {
  const ListaReunionesScreen({super.key});

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
        child: SingleChildScrollView(
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
                    // Aquí podrías implementar búsqueda
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

                // --- LISTA DE REUNIONES ---
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    ReunionCard(
                      titulo: 'Reunión de Proyecto',
                      fecha: '28 de Noviembre, 2025 - 10:00 AM',
                    ),
                    ReunionCard(
                      titulo: 'Revisión de diseño',
                      fecha: '14 de Octubre, 2025 - 10:00 AM',
                    ),
                    ReunionCard(
                      titulo: 'Reunión de planificación',
                      fecha: '04 de Septiembre, 2025 - 10:00 AM',
                    ),
                  ],
                ),
              ],
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
  const ReunionCard({super.key, required this.titulo, required this.fecha});

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
            MaterialPageRoute(builder: (context) => const PaginaReunion()),
          );
        },
      ),
    );
  }
}

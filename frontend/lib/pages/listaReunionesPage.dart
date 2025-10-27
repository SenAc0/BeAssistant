import 'package:flutter/material.dart';
import 'package:myapp/pages/noHecho.dart';

class ReunionesApp extends StatelessWidget {
  const ReunionesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reuniones',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFE5E5E5),
      ),
      home: const ListaReunionesScreen(),
    );
  }
}

class ListaReunionesScreen extends StatelessWidget {
  const ListaReunionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reuniones'),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // --- BUSCADOR ---
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar reuniones ...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // Agregar lógica para filtrar reuniones por texto
              },
            ),
            const SizedBox(height: 10),

            // --- BOTONES DE FILTRO ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterButton(text: 'Todas'),
                FilterButton(text: 'Próximas'),
                FilterButton(text: 'En curso'),
              ],
            ),
            const SizedBox(height: 15),

            // --- EJEMPLO LISTA DE REUNIONES ---
            Expanded(
              child: ListView(
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
            ),
          ],
        ),
      ),

      // --- BOTÓN FLOTANTE PARA AGREGAR REUNIONES ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const noHechoScreen(),
            ),
          ); 
          //Agregar lógica para crear nueva reunión
        },
        backgroundColor: Colors.blueAccent,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),

      // --- BARRA DE NAVEGACIÓN INFERIOR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // "Sesiones" seleccionada
        onTap: (index) {
          if (index == 0) { // index historial
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const noHechoScreen(),
              ),
            );
          }
          if (index == 2) { // index reportes
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const noHechoScreen(),
              ),
            );
          }
          if (index == 3) { // index perfil
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const noHechoScreen(),
              ),
            );
          }
          // Agregar navegación entre pantallas
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Sesiones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// --- WIDGET BOTÓN DE FILTRO ---
class FilterButton extends StatelessWidget {
  final String text;
  const FilterButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        //Agregar lógica de filtrado según el tipo (todas, próximas, en curso)
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }
}

// --- WIDGET TARJETA DE REUNIÓN ---
class ReunionCard extends StatelessWidget {
  final String titulo;
  final String fecha;
  const ReunionCard({super.key, required this.titulo, required this.fecha});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(fecha),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const noHechoScreen(),
              ),
            );
          // Agregar navegación al detalle de la reunión
        },
      ),
    );
  }
}

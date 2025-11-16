import 'package:flutter/material.dart';
class Historial extends StatefulWidget {
  const Historial({super.key});
  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Historial'),
        centerTitle: true,
        elevation: 0,
      ),
      body:Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Esta semana", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
            const SizedBox(height: 10),
            ListaCard(
              hora: "08:30 AM - 10:00 AM",
              fecha: "Jueves, 06 de Octubre",
              asistencia: "Ausente",
            ),
            const SizedBox(height: 10),
            Text("Mes  pasado", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
            const SizedBox(height: 10),
            ListaCard(
              hora: "08:30 AM - 10:00 AM",
              fecha: "Jueves, 06 de Octubre",
              asistencia: "Presente",
            ),
          ],  
        ),
      ),
    );
  }
}

class ListaCard extends StatelessWidget {
  final String hora;
  final String fecha;
  final String asistencia;
  
  const ListaCard({super.key, required this.hora, required this.fecha, required this.asistencia});


  @override
  Widget build(BuildContext context) {
    final bool estaPresente = asistencia.toLowerCase() == "presente";
        return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(               
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 173, 176, 181),
                shape: BoxShape.circle,
              ),

              child: Icon(
                estaPresente ? Icons.check : Icons.close, 
                color: Colors.white,
                size: 32,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  fecha,
                  style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                ),
                subtitle: Text(hora),
                trailing: Text(
                  asistencia,
                  style: TextStyle(
                    color: estaPresente ? Colors.green : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
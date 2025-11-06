import 'package:flutter/material.dart';

class PaginaReunion extends StatelessWidget {
  const PaginaReunion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reunion'),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            SesionCard(
              tituloSesion: "Revisión del Proyecto",
              fecha: "02/11/2025",
              hora: "10:00 AM",
              coordinador: "Juan Pérez",
              sala: "Sala 3",
            ),
            const SizedBox(height: 10),
            TopicoCard(
              titulo: "UI del sistema",
              descripcion:
                  " En la sesión del viernes 17 de Octubre, abordaremos como construir y estructurar la UI",
            ),
            const SizedBox(height: 10),
            NotaCard(descripcionNota: "Recuerden llevar sus computadores"),
            const SizedBox(height: 10),
            AsistenciaCard(
              asistencia: "Presente",
              //asistencia: "Presente",
            ),
          ],
        ),
      ),
    );
  }
}

class SesionCard extends StatelessWidget {
  final String tituloSesion;
  final String fecha;
  final String hora;
  final String coordinador;
  final String sala;

  const SesionCard({
    super.key,
    required this.tituloSesion,
    required this.fecha,
    required this.hora,
    required this.coordinador,
    required this.sala,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 60, 157, 237),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          'Sesión: $tituloSesion',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              '$fecha - $hora',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Coordinador ',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    coordinador,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Sala ', style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Text(
                    sala,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TopicoCard extends StatelessWidget {
  final String titulo;
  final String descripcion;
  const TopicoCard({
    super.key,
    required this.titulo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(251, 223, 223, 90),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Topico: $titulo',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Descripción: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: descripcion,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotaCard extends StatelessWidget {
  final String descripcionNota;

  const NotaCard({super.key, required this.descripcionNota});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(228, 236, 157, 94),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text(
          'Nota',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          descripcionNota,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class AsistenciaCard extends StatelessWidget {
  final String asistencia;

  const AsistenciaCard({super.key, required this.asistencia});

  @override
  Widget build(BuildContext context) {
    bool esAusente = asistencia == "Ausente";

    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: esAusente
            ? const Color.fromARGB(255, 237, 78, 78)
            : const Color.fromARGB(255, 61, 200, 72),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Asistencia",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                esAusente
                    ? "Tu asistencia no ha sido registrada"
                    : "Tu asistencia ha sido registrada",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),

              const SizedBox(width: 20),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: esAusente
                      ? const Color.fromARGB(255, 99, 28, 28)
                      : const Color.fromARGB(255, 20, 69, 24),
                ),

                child: Icon(
                  esAusente ? Icons.close : Icons.check,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

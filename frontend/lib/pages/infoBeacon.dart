import 'package:flutter/material.dart';

class InfoBeacon extends StatefulWidget {
  const InfoBeacon({super.key});

  @override
  State<InfoBeacon> createState() => _InfoBeaconState();
}

class Beacon {
  final String id;
  final int major;
  final int minor;
  final String ultimaVezUsado;
  final String ubicacion;
  final String colorNombre;
  final Color color;
  final String nombre;
  final bool activo;

  Beacon({
    required this.id,
    required this.major,
    required this.minor,
    required this.ultimaVezUsado,
    required this.ubicacion,
    required this.colorNombre,
    required this.color,
    required this.nombre,
    required this.activo,
  });
}

class BeaconService {
  Future<Beacon> fetchBeacon() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula carga

    return Beacon(
      id: "XXXXXXXXXXXXXXXXXXXX",
      major: 12,
      minor: 45,
      ultimaVezUsado: "20/02/2025 13:40",
      ubicacion: "Oficina Central",
      colorNombre: "Azul",
      color: const Color(0xFF4A90E2),
      nombre: "Beacon XX-X",
      activo: true,
    );
  }
}

class _InfoBeaconState extends State<InfoBeacon> {
  final BeaconService service = BeaconService();
  late Future<Beacon> beaconFuture;

  @override
  void initState() {
    super.initState();
    beaconFuture = service.fetchBeacon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
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
        title: const Text("Información del Beacon"),
        centerTitle: true,
      ),
      body: FutureBuilder<Beacon>(
        future: beaconFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final beacon = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Tarjeta superior
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFAF79F2), width: 2),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.rss_feed, size: 60, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        beacon.nombre,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: beacon.activo ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          beacon.activo ? "ACTIVO" : "INACTIVO",
                          style: TextStyle(
                            color: beacon.activo ? const Color(0xFFA2CF68) : const Color(0xFFFF0967),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Tarjeta de datos
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField("ID:", beacon.id),
                      _buildField("Major:", "${beacon.major}"),
                      _buildField("Minor:", "${beacon.minor}"),
                      _buildField("Última vez usado:", beacon.ultimaVezUsado),
                      _buildField("Ubicación:", beacon.ubicacion),
                      
                      const SizedBox(height: 6),
                      _buildField(
                        "Color:",
                        beacon.colorNombre,
                        trailing: CircleAvatar(radius: 12, backgroundColor: beacon.color),
                        valueMaxWidthFraction: 0.5,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(String title, String value, {Widget? trailing, double valueMaxWidthFraction = 0.6}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              if (value.isNotEmpty)
                Flexible(
                  flex: 0,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * valueMaxWidthFraction),
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 8),
          if(title != 'Color:') Divider(color: Colors.grey.shade300, thickness: 1),
        ],
      ),
    );
  }
}

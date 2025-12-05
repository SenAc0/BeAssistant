import 'package:flutter/material.dart';
import '../api_service.dart';

class BeaconPage extends StatefulWidget {
  const BeaconPage({super.key});

  @override
  State<BeaconPage> createState() => _BeaconPageState();
}

class _BeaconPageState extends State<BeaconPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> beacons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBeacons();
  }

  Future<void> _loadBeacons() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _apiService.getBeacons();
      setState(() {
        beacons = List<Map<String, dynamic>>.from(data.map((item) => {
          "id": item["id"],
          "name": item["name"] ?? "Sin nombre",
          "location": item["ubicacion"] ?? item["location"] ?? "",
        }));
        _isLoading = false;
      });
    } catch (e) {
      print("Error al cargar beacons: $e");
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al cargar los beacons")),
        );
      }
    }
  }

  Future<bool> _confirmDelete() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Column(
              children: const [
                Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFFFC75F), size: 45),
                SizedBox(height: 10),
                Text(
                  "¿Está seguro que desea eliminar el beacon?",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0967),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFA2CF68),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Eliminar"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
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
        title: const Text("Gestión de Beacons"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'beaconPageFAB',
        onPressed: () async {
          await Navigator.pushNamed(context, '/addBeacon');
          // Recargar la lista después de agregar un beacon
          _loadBeacons();
        },
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar beacon ...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: beacons.isEmpty
                ? const Center(
                    child: Text(
                      "No hay beacons disponibles",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
              itemCount: beacons.length,
              itemBuilder: (context, index) {
                final beacon = beacons[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Dismissible(
                    key: Key(beacon["id"].toString()),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      final confirmar = await _confirmDelete();
                      if (confirmar) {
                        try {
                          final success = await _apiService.deleteBeacon(beacon["id"]);
                          if (success) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Beacon eliminado exitosamente")),
                              );
                            }
                            return true; 
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Error al eliminar el beacon")),
                              );
                            }
                            return false; 
                          }
                        } catch (e) {
                          print("Error al eliminar beacon: $e");
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                          return false;
                        }
                      }
                      return false;
                    },
                    background: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF0967),
                        ),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 28),
                      ),
                    ),
                    child: Material(
                      elevation: 6,
                      shadowColor: const Color(0xFFAF79F2),
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        leading: const Icon(Icons.sensors, size: 35, color: Color(0xFFA2CF68),),
                        title: Text(beacon["name"]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (beacon["location"] != "")
                              Text(beacon["location"]),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            Navigator.pushNamed(
                              context, 
                              '/infoBeacon',
                              arguments: beacon["id"], // Pasar el ID del beacon
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

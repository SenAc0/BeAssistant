import 'package:flutter/material.dart';

class BeaconPage extends StatefulWidget {
  const BeaconPage({super.key});

  @override
  State<BeaconPage> createState() => _BeaconPageState();
}

class _BeaconPageState extends State<BeaconPage> {
  // Datos de ejemplo mientras no exista backend
  List<Map<String, dynamic>> beacons = [
    {
      "name": "Beacon A1-1",
      "status": "Activo",
      "location": "Oficina 2",
      "active": true
    },
    {
      "name": "Beacon B3-3",
      "status": "Activo",
      "location": "Sala de juntas 4",
      "active": true
    },
    {
      "name": "Beacon B3-4",
      "status": "Activo",
      "location": "Sala de juntas 4",
      "active": true
    },
    {
      "name": "Beacon F2-3",
      "status": "Inactivo",
      "location": "",
      "active": false
    },
    {
      "name": "Beacon A6-6",
      "status": "Inactivo",
      "location": "",
      "active": false
    },
  ];

  // Popup de confirmación de borrado
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
                  backgroundColor: Color(0xFFFF0967),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFA2CF68),
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

  // Pop-up del menú "Ver información / Desactivar"
  void _showMoreOptions(Map<String, dynamic> beacon) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Ver información"),
              onTap: () {
                Navigator.pop(context);
                // Callback editable:
                print("Ver información → ${beacon["name"]}");
              },
            ),
            ListTile(
              title: Text(beacon["active"] ? "Desactivar" : "Activar"),
              onTap: () {
                Navigator.pop(context);
                // Callback editable:
                print("Cambiar estado → ${beacon["name"]}");
              },
            ),
          ],
        );
      },
    );
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
        onPressed: () {
          // callback editable
        },
        elevation: 6, 
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // Barra de búsqueda
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

          // Lista de beacons
          Expanded(
            child: ListView.builder(
              itemCount: beacons.length,
              itemBuilder: (context, index) {
                final beacon = beacons[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        final confirmar = await _confirmDelete();
                        if (confirmar) {
                          setState(() => beacons.removeAt(index));
                        }
                        return confirmar;
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF0967),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete, color: Colors.white, size: 28),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.sensors, size: 35),
                            title: Text(beacon["name"]),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  beacon["status"],
                                  style: TextStyle(
                                    color: beacon["active"]
                                        ? const Color(0xFFA2CF68)
                                        : const Color(0xFFFF0967),
                                  ),
                                ),
                                if (beacon["location"] != "") Text(beacon["location"]),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => _showMoreOptions(beacon),
                            ),
                          ),
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

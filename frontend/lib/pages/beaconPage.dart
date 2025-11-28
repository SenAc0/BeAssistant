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
                Navigator.pushNamed(context, '/infoBeacon');
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

  int? expandedIndex;
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
          Navigator.pushNamed(context, '/addBeacon');
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
                final bool isExpanded = expandedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Material(
                        elevation: 6,
                        shadowColor: const Color(0xFFAF79F2),
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: [
                            // ================= CARD PRINCIPAL =================
                            Expanded(
                              flex: 7,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.horizontal(
                                    left: const Radius.circular(12),
                                    right: isExpanded ? Radius.zero : const Radius.circular(12),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  leading: const Icon(Icons.sensors, size: 35),
                                  title: Text(beacon["name"]),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    onPressed: () {
                                      setState(() {
                                        expandedIndex = isExpanded ? null : index;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),

                            // ================= LINEA SEPARADORA =================
                            if (isExpanded)
                              Container(
                                width: 1,
                                color: Colors.black.withOpacity(0.2),
                              ),

                            // ================= PANEL LATERAL =================
                            if (isExpanded)
                              Container(
                                width: 130,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/infoBeacon');
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text("Ver información"),
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          beacon["active"] = !beacon["active"];
                                          beacon["status"] = beacon["active"] ? "Activo" : "Inactivo";
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          beacon["active"] ? "Desactivar" : "Activar",
                                          style: const TextStyle(color: Color(0xFFFF0967)),
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

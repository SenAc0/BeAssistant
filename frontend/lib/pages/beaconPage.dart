import 'package:flutter/material.dart';

class BeaconPage extends StatefulWidget {
  const BeaconPage({super.key});

  @override
  State<BeaconPage> createState() => _BeaconPageState();
}

class _BeaconPageState extends State<BeaconPage> {
  List<Map<String, dynamic>> beacons = [
    {
      "name": "Beacon A1-1",
      "location": "Oficina 2",
    },
    {
      "name": "Beacon B3-3",
      "location": "Sala de juntas 4",
    },
    {
      "name": "Beacon B3-4",
      "location": "Sala de juntas 4",
    },
    {
      "name": "Beacon F2-3",
      "location": "TM 3-1",
    },
    {
      "name": "Beacon A6-6",
      "location": "A-313",
    },
  ];

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
        onPressed: () {
          Navigator.pushNamed(context, '/addBeacon');
        },
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: Column(
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
            child: ListView.builder(
              itemCount: beacons.length,
              itemBuilder: (context, index) {
                final beacon = beacons[index];

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
                            Navigator.pushNamed(context, '/infoBeacon');
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

import 'package:flutter/material.dart';
import 'package:myapp/pages/beaconPage.dart';
import 'package:myapp/pages/configurationPage.dart';
import 'package:myapp/pages/historial.dart';
import 'package:myapp/pages/listaReunionesPage.dart';
import 'package:myapp/pages/beacon_service.dart';
import 'package:myapp/pages/reporteReunion.dart';
import 'package:myapp/pages/reporteGeneral.dart';
import 'package:myapp/api_service.dart';
class MainScaffold extends StatefulWidget {
  
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 1;
  bool? isAdmin;
  late final List<Widget> _pages;

  @override
  void initState() {
    cargarPerfil();
    super.initState();
    _pages = [
      const Historial(),
      const ListaReunionesScreen(),
      const BeaconPage(),//BeaconDetector(),
      const ReporteGeneral(), 
      const ConfigurationPage(),
    ];
  }

  Future<void> cargarPerfil() async {
    final me = await ApiService().getProfile();
    setState(() {
      isAdmin = me?["is_admin"] ?? false;
      // si no es admin y estaba parado en index 2 → moverlo
      if (isAdmin == false && _selectedIndex == 2) _selectedIndex = 1;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      if (isAdmin == true) {
        // admin usa índices tal cual
        _selectedIndex = index;
      } else {
        // NO admin tiene que saltarse el índice 2
        if (index == 0) _selectedIndex = 0; // Historial
        if (index == 1) _selectedIndex = 1; // Sesiones
        if (index == 2) _selectedIndex = 3; // Reportes
        if (index == 3) _selectedIndex = 4; // Configuración
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: isAdmin == true
            ? _selectedIndex
            : (_selectedIndex == 0
                  ? 0
                  : _selectedIndex == 1
                  ? 1
                  : _selectedIndex == 3
                  ? 2
                  : 3),
                  
        selectedItemColor: Color(0xFFAF79F2), 
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Sesiones',
          ),
          if (isAdmin == true)
            const BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth_connected_outlined),
              label: 'Beacons',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}

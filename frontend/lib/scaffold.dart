import 'package:flutter/material.dart';
import 'package:myapp/pages/beaconPage.dart';
import 'package:myapp/pages/configurationPage.dart';
import 'package:myapp/pages/historial.dart';
import 'package:myapp/pages/listaReunionesPage.dart';
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
    super.initState();
    cargarPerfil();

    _pages = [
      const Historial(), // 0
      const ListaReunionesScreen(), // 1
      const BeaconPage(), // 2
      const ReporteGeneral(), // 3
      const ConfigurationPage(), // 4
    ];
  }

  Future<void> cargarPerfil() async {
    final me = await ApiService().getProfile();
    setState(() {
      isAdmin = me?["is_admin"] ?? false;

      // Si es admin, no puede quedar en indexes no permitidos
      if (isAdmin == true && (_selectedIndex != 2 && _selectedIndex != 4)) {
        _selectedIndex = 2; // abre Beacons
      }

      // Si NO es admin y estaba en Beacons lo sacamos
      if (isAdmin == false && _selectedIndex == 2) {
        _selectedIndex = 1;
      }
    });
  }

  void _onItemTapped(int index) {
    if (isAdmin == true) {
      // Admin, solo puede acceder Beacons y Configuración
      if (index == 0) {
        setState(() => _selectedIndex = 2); // Beacons
      } else if (index == 1) {
        setState(() => _selectedIndex = 4); // Configuración
      }
      return;
    }

    // Usuario normal    
    if (index == 0) setState(() => _selectedIndex = 0); // Historial
    if (index == 1) setState(() => _selectedIndex = 1); // Sesiones
    if (index == 2) setState(() => _selectedIndex = 3); // Reportes
    if (index == 3) setState(() => _selectedIndex = 4); // Configuración
  }

  @override
  Widget build(BuildContext context) {
    // Mientras carga el perfil evitamos errores
    if (isAdmin == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: isAdmin == true
            ? (_selectedIndex == 2 ? 0 : 1) // admin: 0=beacons, 1=config
            : (_selectedIndex == 0
                  ? 0
                  : _selectedIndex == 1
                  ? 1
                  : _selectedIndex == 3
                  ? 2
                  : 3),

        selectedItemColor: const Color(0xFFAF79F2),
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,

        items: [
          if (isAdmin == false)
            const BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historial',
            ),
          if (isAdmin == false)
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Sesiones',
            ),

          if (isAdmin == true)
            const BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth_connected_outlined),
              label: 'Beacons',
            ),

          if (isAdmin == false)
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

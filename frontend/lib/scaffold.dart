import 'package:flutter/material.dart';
import 'package:myapp/pages/beaconPage.dart';
import 'package:myapp/pages/configurationPage.dart';
import 'package:myapp/pages/historial.dart';
import 'package:myapp/pages/listaReunionesPage.dart';
//import 'package:myapp/pages/noHecho.dart';
import 'package:myapp/pages/beacon_service.dart';
import 'package:myapp/pages/noHecho.dart';
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 1;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Historial(),
      const ListaReunionesScreen(),
      const BeaconPage(),//BeaconDetector(),
      const NoHechoPage(title: "Reportes"), //Cambiar por ReportesPage cuando esté implementada
      const ConfigurationPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFAF79F2), 
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
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
            icon: Icon(Icons.bluetooth_connected_outlined),
            label: 'Beacons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}

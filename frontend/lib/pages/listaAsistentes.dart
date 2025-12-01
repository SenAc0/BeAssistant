import 'package:flutter/material.dart';

class ListaAsistentes extends StatefulWidget {
  const ListaAsistentes({super.key});

  @override
  State<ListaAsistentes> createState() => _ListaAsistentesState();
}

class _ListaAsistentesState extends State<ListaAsistentes> {


  final List<Map<String, String>> _asistentes = [
    {"nombre": "Juan", "estado": "Presente"},
    {"nombre": "Ana", "estado": "Ausente"},
    {"nombre": "Luis", "estado": "Atrasado"},
    {"nombre": "Marta", "estado": "Presente"},
    {"nombre": "Carlos", "estado": "Ausente"},
    {"nombre": "Matias", "estado": "Ausente"},
    {"nombre": "Julia", "estado": "Ausente"},
  ];

  List<Map<String, String>> _filteredAsistentes = [];
  String _selectedFilter = "";

  @override
  void initState() {
    super.initState();
    _filteredAsistentes = [];
  }

  // Filtros
  void _applyFilter(String filter) {
    // Si se presiona el mismo botón → limpiar selección
    if (_selectedFilter == filter) {
      setState(() {
        _selectedFilter = "";
        _filteredAsistentes = [];
      });
      return;
    }

    // Aplicar nuevo filtro
    setState(() {
      _selectedFilter = filter;
      _filteredAsistentes = _asistentes
          .where((a) => a["estado"] == filter)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Botones Filtro
        Card(
          elevation: 4,
          color: Colors.white,
          shadowColor: const Color(0xFFAF79F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterButton(
                  text: "Presente",
                  active: _selectedFilter == "Presente",
                  onTap: () => _applyFilter("Presente"),
                ),
                FilterButton(
                  text: "Ausente",
                  active: _selectedFilter == "Ausente",
                  onTap: () => _applyFilter("Ausente"),
                ),
                FilterButton(
                  text: "Atrasado",
                  active: _selectedFilter == "Atrasado",
                  onTap: () => _applyFilter("Atrasado"),
                ),
              ],
            ),
          ),
        ),


        const SizedBox(height: 20),

        // Lista 
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredAsistentes.length,
          itemBuilder: (context, index) {
            final a = _filteredAsistentes[index];
            return AsistenteCard(
              nombre: a["nombre"]!,
              estado: a["estado"]!,
            );
          },
        ),
      ],
    );
  }
}

// Botón Filtro
class FilterButton extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const FilterButton({
    super.key,
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? const Color(0xFFAF79F2) : Colors.grey[300],
        foregroundColor: active ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }
}


class AsistenteCard extends StatelessWidget {
  final String nombre;
  final String estado;

  const AsistenteCard({
    super.key,
    required this.nombre,
    required this.estado,
  });

  Color _colorEstado() {
    switch (estado) {
      case "Presente":
        return const Color(0xFFA2CF68);
      case "Ausente":
        return const Color(0xFFFF0967);
      case "Atrasado":
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shadowColor: const Color(0xFFAF79F2),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      child: ListTile(
        
        leading: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: _colorEstado(),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 28, color: Colors.white),
        ),

       
        title: Row(
          children: [
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
            const Spacer(),
            Text(
              estado,
              style: TextStyle(
                fontSize: 14,
                color: _colorEstado(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

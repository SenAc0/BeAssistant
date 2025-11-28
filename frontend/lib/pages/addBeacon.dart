import 'package:flutter/material.dart';

class AddBeaconPage extends StatefulWidget {
  const AddBeaconPage({super.key});

  @override
  State<AddBeaconPage> createState() => _AddBeaconPageState();
}

class _AddBeaconPageState extends State<AddBeaconPage> {
  // Controladores
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController minorController = TextEditingController();
  final TextEditingController majorController = TextEditingController();

  // Estado
  Color selectedColor = const Color(0xFF39FF11); // color por defecto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const Text("Agregar Beacon"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Nombre
            const Text("Nombre del beacon",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            _grayInput(
              controller: nombreController,
              hint: "Ej: Entrada principal",
            ),

            const SizedBox(height: 20),

            // Ubicación
            const Text("Ubicación",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            _grayInput(
              controller: ubicacionController,
              hint: "Seleccionar ubicación",
              //icon: Icons.map_outlined,
            ),

            const SizedBox(height: 20),

            // ID del beacon
            const Text("ID del beacon",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            _grayInput(
              controller: idController,
              hint: "XXXXXXXXXXXXXXXXXXXX",
            ),

            const SizedBox(height: 10),
            const Divider(),

            const SizedBox(height: 10),

            // Señales
            const Text(
              "Señales",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Minor"),
                      const SizedBox(height: 6),
                      _grayInput(
                        controller: minorController,
                        hint: "XX",
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Major"),
                      const SizedBox(height: 6),
                      _grayInput(
                        controller: majorController,
                        hint: "XX",
                      )
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Color
            const Text("Color",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),

            Row(
              children: [
                // Circle color preview
                CircleAvatar(
                  radius: 14,
                  backgroundColor: selectedColor,
                ),
                const SizedBox(width: 10),

                // Hex label
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    selectedColor.value
                        .toRadixString(16)
                        .toUpperCase()
                        .substring(2),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),

                const Spacer(),

                // Botón cambiar color
                TextButton(
                  onPressed: () {
                    // Aquí puedes abrir un selector de color más adelante
                    setState(() {
                      selectedColor = const Color(0xFFAF79F2);
                    });
                  },
                  child: const Text("Cambiar"),
                )
              ],
            ),

            const SizedBox(height: 30),

            // Botones Guardar y Cancelar
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 6, 
                        shadowColor: Colors.black,   
                        backgroundColor: const Color(0xFFAF79F2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // Aquí en backend
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Guardar",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 6, 
                        shadowColor: Color.fromARGB(255, 180, 15, 15), 
                        backgroundColor: const Color(0xFFFF0967),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // Reusable UI widgets
  // -------------------------------------------------------------------

  Widget _grayInput({required TextEditingController controller, required String hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4), // hacia abajo
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }

  Widget _grayButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}

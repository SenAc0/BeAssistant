import 'package:flutter/material.dart';

class NoHechoPage extends StatelessWidget {
  final String title;
  const NoHechoPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        elevation: 0,
        automaticallyImplyLeading: false, // Evita el botón de "volver"
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.build_rounded, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                'Estamos trabajando en ello',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Text(
                'Pronto podrás acceder a esta sección de "$title".',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

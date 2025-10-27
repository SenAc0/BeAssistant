import 'package:flutter/material.dart';

class noHechoScreen extends StatelessWidget {
  const noHechoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('En desarrollo'),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFE5E5E5),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.build_rounded,
              size: 80,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'Estamos trabajando en ello',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Volver',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

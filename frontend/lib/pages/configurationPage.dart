import 'package:flutter/material.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  bool notificacionesActivadas = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Configuración"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PERFIL ---
              const SizedBox(height: 15),

              // --- OPCIÓN: INFORMACIÓN PERSONAL ---
              _buildOptionCard(
                icon: Icons.person,
                title: 'Información personal',
                subtitle: 'Editar perfil',
                onTap: () {
                  Navigator.pushNamed(context, "/perfil");
                },
              ),
              const SizedBox(height: 10),

              // --- OPCIÓN: SEGURIDAD ---
              _buildOptionCard(
                icon: Icons.security,
                title: 'Seguridad',
                subtitle: 'Cambiar contraseña',
                onTap: () {
                  // Aquí también puedes navegar a otra vista
                },
              ),

              const SizedBox(height: 30),

              // --- NOTIFICACIONES ---
              const Text(
                'Notificaciones',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.black),
                  title: const Text('General'),
                  subtitle: const Text('Activar/desactivar'),
                  trailing: Switch(
                    value: notificacionesActivadas,
                    onChanged: (value) {
                      setState(() {
                        notificacionesActivadas = value;
                      });
                    },
                    activeColor: Colors.purple,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- BOTÓN DE CERRAR SESIÓN ---
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'CERRAR SESIÓN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}

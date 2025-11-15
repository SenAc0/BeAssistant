import 'package:flutter/material.dart';
import 'package:myapp/pages/configurationPage.dart';
import 'package:myapp/pages/listaReunionesPage.dart';
import 'package:myapp/pages/loginPage.dart';
import 'package:myapp/pages/profilePage.dart';
import 'package:myapp/pages/crearReunion1.dart';
import 'package:myapp/scaffold.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reuniones',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFE5E5E5),
      ),

      // Ruta inicial → pantalla de login
      initialRoute: '/login',

      // Mapa de rutas
      routes: {
        '/login': (context) =>
            const LoginScreen(), // pantalla de inicio de sesión
        '/main': (context) =>
            const MainScaffold(), // pantalla principal con bottom nav
        '/crearReunion1': (context) =>
            const CrearReunion1(), // creación de reunión
        '/perfil': (context) => const PerfilPage(), // perfil de usuario
        '/listaReunion': (context) =>
            const ListaReunionesScreen(), // lista de reuniones
        '/configuracion': (context) =>
            const ConfigurationPage(), // configuración de usuario
      },
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

import 'package:flutter/material.dart';
import 'package:myapp/pages/configurationPage.dart';
import 'package:myapp/pages/listaReunionesPage.dart';
import 'package:myapp/pages/loginPage.dart';
import 'package:myapp/pages/profilePage.dart';
import 'package:myapp/pages/crearReunion1.dart';
import 'package:myapp/scaffold.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/pages/infoBeacon.dart';
import 'package:myapp/pages/addBeacon.dart';
//import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fail-fast: load the .env in the Flutter project root ('.env').
  // When running the app, the current project root is the Flutter package
  // (the `frontend` folder). Using 'frontend/.env' caused the loader to
  // look for 'frontend/frontend/.env' and fail. Load '.env' instead.
  await dotenv.load(fileName: '.env');
  print('BASE_URL: ${dotenv.env['BASE_URL']}');
  tzdata.initializeTimeZones();
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA159FF), 
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFA159FF),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.25),
          foregroundColor: const Color(0xFFF6F7FB),
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFFF6F7FB),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ),
      ),


      // Ruta inicial → pantalla de login
      initialRoute: '/login',

      // Mapa de rutas
      routes: {
        '/login': (context) => const LoginScreen(), // pantalla de inicio de sesión
        '/main': (context) => MainScaffold(), // pantalla principal con bottom nav
        '/crearReunion1': (context) => const CrearReunion1(), // creación de reunión
        '/perfil': (context) => const PerfilPage(), // perfil de usuario
        '/listaReunion': (context) => const ListaReunionesScreen(), // lista de reuniones
        '/configuracion': (context) => const ConfigurationPage(), // configuración de usuario
        '/infoBeacon': (context) => const InfoBeacon(), // info beacon
        '/addBeacon': (context) => const AddBeaconPage(), // add beacon
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

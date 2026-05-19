import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'weather_screen.dart';
import 'report_screen.dart'; // <--- El nuevo archivo
import 'places_screen.dart';
import 'records_screen.dart';
import 'login_screen.dart';

const color = Colors.orange;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("🔥 FIREBASE HA ARRANCADO CORRECTAMENTE");
  } catch (e) {
    debugPrint("❌ ERROR DE FIREBASE: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter MAD",
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: color),
        useMaterial3: true,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // AQUÍ ESTÁN TUS 6 PESTAÑAS EN ORDEN
  final List<Widget> _screens = [
    HomeScreen(),
    const MapScreen(),
    const WeatherScreen(),
    const ReportScreen(),
    PlacesScreen(),
    RecordsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _screens.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Permite tener más de 3 iconos sin que se oculten
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Weather'),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Places'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Records'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: color,
        unselectedItemColor: const Color.fromARGB(255, 100, 30, 0),
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
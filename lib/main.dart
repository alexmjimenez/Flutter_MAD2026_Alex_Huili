import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'home_screen.dart';
import 'map_screen.dart';
import 'places_screen.dart';
import 'records_screen.dart';

const color = Colors.orange;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    var logger = Logger();
    logger.d("Debug message");
    logger.w("Warning message!");
    logger.e("Error message!!");
    return MaterialApp(
      title: "Flutter MAD",
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: color),
        useMaterial3: true,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    MapScreen(),
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
        child: _screens.elementAt(_selectedIndex)
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.place),
              label: 'Places',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Records',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: color,
          unselectedItemColor: Color.fromARGB(255, 100, 30, 0),
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        ),
      );
  }
}
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<Position>? _positionStreamSubscription;
  final logger = Logger();
  final _uidController = TextEditingController();
  final _tokenController = TextEditingController();
  String _currentName = "User";
  String _currentUid = "";
  int _totalPoints = 0;
  int _reportPoints = 0;
  int _binPoints = 0;
  StreamSubscription<DatabaseEvent>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    String? token = prefs.getString('token');
    String? name = prefs.getString('name');

    setState(() {
      _currentName = name ?? "User";
      _currentUid = uid ?? "";
    });

    if (uid == null || token == null) {
      _showInputDialog();
    } else {
      _listenToPoints(uid);
    }
  }

  void _listenToPoints(String uid) {
    _userSubscription = FirebaseDatabase.instance.ref('users/$uid').onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _totalPoints = data['totalPoints'] ?? 0;
          _reportPoints = data['reportPoints'] ?? 0;
          _binPoints = data['binPoints'] ?? 0;
        });
      }
    });
  }

  Future<void> _showInputDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter UID and Token'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _uidController,
                  decoration: InputDecoration(hintText: "UID"),
                ),
                TextField(
                  controller: _tokenController,
                  decoration: InputDecoration(hintText: "Token"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('uid', _uidController.text);
                await prefs.setString('token', _tokenController.text);
                Navigator.of(context).pop();
                _loadPrefs();
              },
            ),
          ],
        );
      },
    );
  }

  void _showWelcomeDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Welcome"),
          content: const Text("This application allows you to track your routes, check the local weather, view public bins, and report maintenance issues in real time."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, {String? text}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text ?? "Text"),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RankingScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              ).then((_) => _loadPrefs());
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, $_currentName", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Your score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [Text("Total"), Text("$_totalPoints", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange))]),
                        Column(children: [Text("Reports"), Text("$_reportPoints", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                        Column(children: [Text("Bins"), Text("$_binPoints", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Location tracking"),
                Switch(
                  value: _positionStreamSubscription != null,
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        startTracking();
                      } else {
                        stopTracking();
                      }
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _showWelcomeDialog,
              child: Text("App info"),
            ),
          ],
        ),
      ),
    );
  }

  void startTracking() async {
    _showSnackBar(context, text: "The location is on");
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
        writePositionToFile(position);
        _showSnackBar(context, text: position.toString());
      },
    );
  }

  void stopTracking() {
    _showSnackBar(context, text: "The location is off");
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  Future<void> writePositionToFile(Position position) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gps_coordinates.csv');
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await file.writeAsString('$timestamp;${position.latitude};${position.longitude}\n', mode: FileMode.append);
  }

  @override
  void dispose() {
    _uidController.dispose();
    _tokenController.dispose();
    _userSubscription?.cancel();
    super.dispose();
  }
}

class RankingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Leaderboard ranking")),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref('users').orderByChild('totalPoints').onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(child: Text("No ranking data found"));
          }
          Map<dynamic, dynamic> usersMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<MapEntry<dynamic, dynamic>> sortedList = usersMap.entries.toList();
          sortedList.sort((a, b) => (b.value['totalPoints'] ?? 0).compareTo(a.value['totalPoints'] ?? 0));

          return ListView.builder(
            itemCount: sortedList.length,
            itemBuilder: (context, index) {
              var user = sortedList[index].value;
              return ListTile(
                leading: CircleAvatar(child: Text("${index + 1}")),
                title: Text("${user['name'] ?? 'User'} (${user['role'] ?? 'citizen'})"),
                subtitle: Text("Reports: ${user['reportPoints'] ?? 0} | Bins: ${user['binPoints'] ?? 0}"),
                trailing: Text("${user['totalPoints'] ?? 0} pts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
              );
            },
          );
        },
      ),
    );
  }
}

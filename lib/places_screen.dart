import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  bool _isAdding = false;
  String _binStatus = "Empty / Clean";
  bool _isTownHall = false;
  String _userUid = "";
  String _userName = "User";
  String _userRole = "citizen";

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? "";
    _userUid = prefs.getString('uid') ?? "";
    _userName = prefs.getString('name') ?? "User";

    setState(() {
      _isTownHall = (token == "AYUNTAMIENTO2026");
      _userRole = _isTownHall ? "ayuntamiento" : "citizen";
    });
  }

  Future<void> _updateUserPoints() async {
    if (_userUid.isEmpty) return;
    final userRef = _dbRef.child('users/$_userUid');
    final snapshot = await userRef.get();
    int binPoints = 0;
    int totalPoints = 0;
    if (snapshot.exists) {
      Map data = snapshot.value as Map;
      binPoints = data['binPoints'] ?? 0;
      totalPoints = data['totalPoints'] ?? 0;
    }
    await userRef.update({
      'name': _userName,
      'role': _userRole,
      'binPoints': binPoints + 10,
      'totalPoints': totalPoints + 10,
    });
  }

  Future<void> _addBinCurrentLocation() async {
    setState(() => _isAdding = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String newBinKey = _dbRef.child('bins').push().key ?? '';

      await _dbRef.child('bins/$newBinKey').set({
        'id': newBinKey,
        'lat': position.latitude,
        'lon': position.longitude,
        'status': _binStatus,
        'completedCount': 0,
        'scorePoints': 10,
      }).timeout(const Duration(seconds: 10));

      await _updateUserPoints();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bin added successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding bin: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isAdding = false);
    }
  }

  Future<void> _addBinCustomLocation() async {
    if (_latController.text.trim().isEmpty || _lonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill coordinates fields"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isAdding = true);
    try {
      double lat = double.parse(_latController.text.trim());
      double lon = double.parse(_lonController.text.trim());
      String newBinKey = _dbRef.child('bins').push().key ?? '';

      await _dbRef.child('bins/$newBinKey').set({
        'id': newBinKey,
        'lat': lat,
        'lon': lon,
        'status': _binStatus,
        'completedCount': 0,
        'scorePoints': 10,
      }).timeout(const Duration(seconds: 10));
      await _updateUserPoints();
      _latController.clear();
      _lonController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Custom bin added successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding bin: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isAdding = false);
    }
  }

  Future<void> _resolveReport(String key) async {
    try {
      await _dbRef.child('reports/$key').remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report marked as resolved")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating report: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage bins & Reports"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add new bin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isAdding
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addBinCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text("Use current location"),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _latController,
                                decoration: const InputDecoration(hintText: "Latitude"),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                              TextField(
                                controller: _lonController,
                                decoration: const InputDecoration(hintText: "Longitude"),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _addBinCustomLocation,
                                icon: const Icon(Icons.map),
                                label: const Text("Use custom coordinates"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
            const Text("Active user reports", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder(
                stream: _dbRef.child('reports').onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    return const Text("No active reports found");
                  }

                  Map<dynamic, dynamic> reportsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<MapEntry<dynamic, dynamic>> reportsList = reportsMap.entries.toList();

                  return ListView.builder(
                    itemCount: reportsList.length,
                    itemBuilder: (context, index) {
                      var key = reportsList[index].key;
                      var value = reportsList[index].value;

                      return Card(
                        child: ListTile(
                          title: Text("${value['status']} - ${value['name'] ?? 'User'}"),
                          subtitle: Text("Lat: ${value['lat']}, Lon: ${value['lon']}"),
                          trailing: _isTownHall
                              ? IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _resolveReport(key),
                          )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }
}

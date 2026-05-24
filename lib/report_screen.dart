import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String? _userEmail;
  double? _currentLat;
  double? _currentLon;
  String _selectedStatus = "Full Bin";
  bool _isLoadingData = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadAutomaticData();
  }

  Future<void> _loadAutomaticData() async {
    try {
      _userEmail = FirebaseAuth.instance.currentUser?.email;
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      setState(() {
        _currentLat = position.latitude;
        _currentLon = position.longitude;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching location: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submitReport() async {
    if (_currentLat == null || _currentLon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot submit without location"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      String? newReportKey = _dbRef.child('reports').push().key;

      await _dbRef.child('reports/$newReportKey').set({
        'email': _userEmail ?? 'Anonymous',
        'status': _selectedStatus,
        'lat': _currentLat,
        'lon': _currentLon,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }).timeout(const Duration(seconds: 10));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Report '$_selectedStatus' sent to Realtime Firebase!")),
      );
      
      setState(() {
        _selectedStatus = "Full bin";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving to Firebase: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _cancelReport() {
    setState(() {
      _selectedStatus = "Full bin";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report cancelled")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Loading API data (Auto-filling)...")
          ],
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Report issue")),
      body: _isSending
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Report", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  Card(
                    color: Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("API Data (Auto-filled):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          const Divider(),
                          Text("Email: ${_userEmail ?? 'Not detected'}"),
                          const SizedBox(height: 5),
                          Text("Latitude: ${_currentLat ?? 'Searching...'}"),
                          const SizedBox(height: 5),
                          Text("Longitude: ${_currentLon ?? 'Searching...'}"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  const Text("Select the issue status:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  Expanded(
                    child: ListView(
                      children: [
                        _buildStatusRadio("Full bin", Icons.delete, Colors.brown),
                        _buildStatusRadio("Dirty bin", Icons.cleaning_services, Colors.orange),
                        _buildStatusRadio("Broken bin", Icons.build, Colors.red),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                          onPressed: _cancelReport,
                          child: const Text("CANCEL", style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _submitReport,
                          child: const Text("SUBMIT"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildStatusRadio(String status, IconData icon, Color color) {
    bool isSelected = _selectedStatus == status;
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? color : Colors.transparent, width: 2),
      ),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 15),
            Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        value: status,
        groupValue: _selectedStatus,
        onChanged: (value) {
          setState(() {
            _selectedStatus = value!;
          });
        },
      ),
    );
  }
}

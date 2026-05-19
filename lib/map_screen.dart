import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> _routePoints = [];
  bool _isLoadingCSV = true;

  @override
  void initState() {
    super.initState();
    _loadCoordinatesFromCSV();
  }

  Future<void> _loadCoordinatesFromCSV() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/gps_coordinates.csv');

      if (await file.exists()) {
        List<String> lines = await file.readAsLines();
        List<LatLng> points = [];

        for (String line in lines) {
          var data = line.split(';');
          if (data.length >= 3) {
            double lat = double.parse(data[1]);
            double lon = double.parse(data[2]);
            points.add(LatLng(lat, lon));
          }
        }

        setState(() {
          _routePoints = points;
          _isLoadingCSV = false;
        });
      } else {
        setState(() => _isLoadingCSV = false);
      }
    } catch (e) {
      setState(() => _isLoadingCSV = false);
      debugPrint("Error loading local CSV routes: $e");
    }
  }

  Widget _getIconForStatus(String status) {
    switch (status) {
      case "Broken Bin":
        return const Icon(Icons.build, color: Colors.red, size: 28);
      case "Full Bin":
        return const Icon(Icons.delete, color: Colors.brown, size: 28);
      case "Dirty Bin":
        return const Icon(Icons.cleaning_services, color: Colors.orange, size: 28);
      default:
        return const Icon(Icons.warning, color: Colors.amber, size: 28);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCSV) {
      return const Center(child: CircularProgressIndicator());
    }

    LatLng defaultCenter = const LatLng(40.4168, -3.7038);
    LatLng center = _routePoints.isNotEmpty ? _routePoints.last : defaultCenter;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Incidents & Route Map"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reports').snapshots(),
        builder: (context, snapshot) {
          List<Marker> allMarkers = [];

          if (_routePoints.isNotEmpty) {
            for (int i = 0; i < _routePoints.length; i++) {
              bool isFirst = i == 0;
              bool isLast = i == _routePoints.length - 1;

              allMarkers.add(
                Marker(
                  point: _routePoints[i],
                  width: 50,
                  height: 50,
                  child: Column(
                    children: [
                      if (isFirst)
                        Container(color: Colors.white, child: const Text("Start", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))),
                      if (isLast)
                        Container(color: Colors.white, child: const Text("Here", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold))),
                      Icon(
                        Icons.location_on,
                        color: isLast ? Colors.blue : (isFirst ? Colors.green : Colors.red.withOpacity(0.5)),
                        size: isLast ? 32.0 : 24.0,
                      ),
                    ],
                  ),
                ),
              );
            }
          }

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              if (data['lat'] != null && data['lon'] != null) {
                allMarkers.add(
                  Marker(
                    point: LatLng(data['lat'], data['lon']),
                    width: 90,
                    height: 65,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _getIconForStatus(data['status'] ?? ''),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey, width: 0.5)
                          ),
                          child: Text(
                            data['status'] ?? 'Unknown',
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
          }

          return FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'es.upm.etsisi.mad.huili_alex',
              ),

              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue.withOpacity(0.6),
                      strokeWidth: 4.0,
                    ),
                  ],
                ),

              MarkerLayer(markers: allMarkers),
            ],
          );
        },
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> _routePoints = [];
  bool _isLoadingCSV = true;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

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
    }
  }

  Widget _getIconForStatus(String status) {
    switch (status) {
      case "Empty / Clean":
        return const Icon(Icons.delete_outline, color: Colors.green, size: 30);
      case "Full bin":
        return const Icon(Icons.delete, color: Colors.brown, size: 30);
      case "Dirty bin":
      case "Dirty bin":
        return const Icon(Icons.cleaning_services, color: Colors.orange, size: 30);
      case "Broken bin":
        return const Icon(Icons.build, color: Colors.red, size: 30);
      default:
        return const Icon(Icons.location_on, color: Colors.blue, size: 30);
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
        title: const Text("Map"),
      ),
      body: StreamBuilder(
        stream: _dbRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
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

          if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
            Map<dynamic, dynamic> rootMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            if (rootMap['bins'] != null) {
              Map<dynamic, dynamic> bins = rootMap['bins'] as Map<dynamic, dynamic>;
              bins.forEach((key, value) {
                if (value['lat'] != null && value['lon'] != null) {
                  allMarkers.add(
                    Marker(
                      point: LatLng(value['lat'], value['lon']),
                      width: 90,
                      height: 65,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _getIconForStatus(value['status'] ?? 'Empty / Clean'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey, width: 0.5),
                            ),
                            child: Text(
                              value['status'] ?? 'Clean',
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
              });
            }

            if (rootMap['reports'] != null) {
              Map<dynamic, dynamic> reports = rootMap['reports'] as Map<dynamic, dynamic>;
              reports.forEach((key, value) {
                if (value['lat'] != null && value['lon'] != null) {
                  allMarkers.add(
                    Marker(
                      point: LatLng(value['lat'], value['lon']),
                      width: 90,
                      height: 65,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _getIconForStatus(value['status'] ?? ''),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey, width: 0.5),
                            ),
                            child: Text(
                              value['status'] ?? 'Report',
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
              });
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> _routePoints = [];
  bool _isLoading = true;

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
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error loading CSV: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    LatLng center = const LatLng(40.4168, -3.7038);

    LatLngBounds? mapBounds;
    if (_routePoints.isNotEmpty) {
      mapBounds = LatLngBounds.fromPoints(_routePoints);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("OpenStreetMaps Tracking"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCameraFit: mapBounds != null
              ? CameraFit.bounds(
            bounds: mapBounds,
            padding: const EdgeInsets.all(50.0),
          )
              : null,
          initialCenter: center,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.upm.mad2026.huili_alex',
          ),

          if (_routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints,
                  color: Colors.blue.withOpacity(0.5),
                  strokeWidth: 4.0,
                ),
              ],
            ),

          MarkerLayer(
            markers: _buildMarkers(),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    for (int i = 0; i < _routePoints.length; i++) {
      bool isLastMarker = i == _routePoints.length - 1;

      markers.add(
        Marker(
          point: _routePoints[i],
          width: 40,
          height: 40,
          child: Icon(
            Icons.location_on,
            color: isLastMarker ? Colors.blue : Colors.red,
            size: isLastMarker ? 40.0 : 30.0,
          ),
        ),
      );
    }

    return markers;
  }
}

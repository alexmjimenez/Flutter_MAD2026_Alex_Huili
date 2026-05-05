import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
      ),
      body: Center(
        child: Text("Map Activity"),
      ),
    );
  }
}
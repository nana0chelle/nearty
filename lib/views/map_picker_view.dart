import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';

class MapPickerView extends StatefulWidget {
  final String title;
  final LatLng initialPosition;

  const MapPickerView({Key? key, required this.title, required this.initialPosition}) : super(key: key);

  @override
  _MapPickerViewState createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  late LatLng _selectedPosition;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: _selectedPosition);
            },
            child: const Text('Pilih', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _selectedPosition,
          initialZoom: 15.0,
          onTap: (tapPosition, point) {
            setState(() {
              _selectedPosition = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.nearty',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedPosition,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, size: 40, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

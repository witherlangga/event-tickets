import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initial;
  const MapPickerPage({super.key, this.initial});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng _marker;

  @override
  void initState() {
    super.initState();
    _marker = widget.initial ?? LatLng(-6.200000, 106.816666); // default Jakarta
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick location')),
      body: Column(children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              center: _marker,
              zoom: 13,
              onTap: (tapPos, latlng) {
                setState(() {
                  _marker = latlng;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80,
                    height: 80,
                    point: _marker,
                    builder: (ctx) => const Icon(Icons.location_on, size: 48, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Lat: ${_marker.latitude.toStringAsFixed(6)}'),
            Text('Lng: ${_marker.longitude.toStringAsFixed(6)}'),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _marker),
              child: const Text('Select'),
            ),
          ]),
        )
      ]),
    );
  }
}

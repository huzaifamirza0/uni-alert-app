import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RadiusUserList extends StatelessWidget {
  final List<Marker> markers;

  const RadiusUserList({Key? key, required this.markers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markers Within Circle'),
      ),
      body: ListView.builder(
        itemCount: markers.length,
        itemBuilder: (context, index) {
          final marker = markers[index];
          return ListTile(
            title: Text(marker.markerId.value), // Use the marker ID as the title
            subtitle: Text('Location: ${marker.position.latitude}, ${marker.position.longitude}'),
          );
        },
      ),
    );
  }
}

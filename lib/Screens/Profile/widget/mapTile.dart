import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';

class LocationWidget extends StatefulWidget {
  final double latitude;
  final double longitude;

  const LocationWidget({Key? key, required this.latitude, required this.longitude}) : super(key: key);

  @override
  _LocationWidgetState createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  String? _address;
  double? _latitude;
  double? _longitude;
  final GeoCode geoCode = GeoCode();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget.latitude != 0 && widget.longitude != 0) {
      _latitude = widget.latitude;
      _longitude = widget.longitude;
    } else {
      await _getCurrentLocation();
    }

    _getAddress();
  }

  Future<void> _getAddress() async {
    if (_latitude != null && _longitude != null) {
      try {
        Address address = await geoCode.reverseGeocoding(
          latitude: _latitude!,
          longitude: _longitude!,
        );
        setState(() {
          _address = "${address.streetAddress}, ${address.city}, ${address.countryName}";
        });
      } catch (e) {
        setState(() {
          _address = "Unable to get address";
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'My Location',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Address:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(_address ?? 'Loading...'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey), // Add border to mimic an image
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12), // Adjust the radius as needed
                    child: GoogleMapTile(latitude: _latitude ?? 0, longitude: _longitude ?? 0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GoogleMapTile extends StatelessWidget {
  final double latitude;
  final double longitude;

  const GoogleMapTile({Key? key, required this.latitude, required this.longitude}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 12,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('location'),
          position: LatLng(latitude, longitude),
          infoWindow: const InfoWindow(title: 'Location'),
        ),
      },
      gestureRecognizers: Set()..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer())),
      zoomControlsEnabled: false, // Disable zoom controls
      myLocationButtonEnabled: false, // Disable my location button
      scrollGesturesEnabled: false, // Disable scroll gestures
      rotateGesturesEnabled: false, // Disable rotate gestures
      tiltGesturesEnabled: false, // Disable tilt gestures
    );
  }
}

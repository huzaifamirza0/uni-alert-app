import 'package:background_location/background_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal({int interval = 10000}) {
    startLocationService(interval);
  }


  late Function(Map<String, dynamic>) _locationUpdateListener;

  void startLocationService(int interval) {
    BackgroundLocation.startLocationService();
    BackgroundLocation.setAndroidConfiguration(interval);
    BackgroundLocation.getLocationUpdates((location) {
      _updateLocationFirestore(location);
      if (_locationUpdateListener != null) {
        _locationUpdateListener(location.toMap());
      }
    });
    print('Location service started.');
  }

  void setLocationUpdateListener(Function(Map<String, dynamic>) listener) {
    _locationUpdateListener = listener;
  }

  void _updateLocationFirestore(Location location) async {

    final userId = await FirebaseAuth.instance.currentUser!.uid;
    print('userId : ---- $userId');
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
          'latitude': location.latitude,
          'longitude': location.longitude,
      });

      print('Location updated in Firestore: ${location.latitude}, ${location.longitude}');
    } catch (e) {
      print('Error updating location in Firestore: $e');
    }
  }

  void stopLocationService() {
    BackgroundLocation.stopLocationService();
    print('Location service stopped.');
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:notification_app/Screens/Map/service/location_service.dart';
import 'package:provider/provider.dart';
import '../../Components/main_button.dart';
import '../../Database/files_database.dart';
import '../../VideoRecorder/video_file_model.dart';
import '../../VideoRecorder/video_list.dart';
import '../../components/CustomButton.dart';
import 'emergencyIdProvider.dart';
import 'emergency_state.dart';

class GoMap extends StatefulWidget {
  const GoMap({Key? key}) : super(key: key);

  @override
  _GoMapState createState() => _GoMapState();
}

class _GoMapState extends State<GoMap> {
  late GoogleMapController mapController;
  List<Marker> allMarkers = [];
  late LocationService _locationService;
  late double radius = 900.0;
  bool _showCheckInButton = false;
  List<Circle> _circles = [];
  String? _latitude;
  String? _longitude;
  Position? _currentPosition;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String? videoFile;
  late List<CameraDescription> cameras;
  late Timer _recordingTimer;
  late EmergencyStatusProvider _emergencyStatusProvider;
  List<DocumentSnapshot> emergencyUsersWithinRadius = [];

  @override
  void initState() {
    super.initState();

    _locationService = LocationService();
    _locationService.startLocationService(10000);
    _emergencyStatusProvider =
        Provider.of<EmergencyStatusProvider>(context, listen: false);
    LocationService().setLocationUpdateListener((location) {
      setState(() {
        _latitude = location['latitude'].toString();
        _longitude = location['longitude'].toString();
        _currentPosition = Position(
          latitude: double.parse(_latitude!),
          longitude: double.parse(_longitude!),
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          heading: 0.0,
          speedAccuracy: 0.0,
        );
        print(_currentPosition!.latitude);
        print(_currentPosition!.longitude);
        _loadMarkers().then((_) {
          print('Load marker has been printed .....Now update check in');
          _updateCheckInButtonVisibility();
          print('update check in has been executed');
        });
      });
    });

    print('Loading markers...');
    _loadMarkers();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: true,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _recordingTimer.cancel();
    _locationService.stopLocationService();
    super.dispose();
  }

  void setEmergencyStatus(bool status) async {
    final userId  = await FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update(
        {
          'status': status
        });
  }

  Future<void> _loadMarkers() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    List<Marker> markers = [];
    List<Circle> circles = [];
    final currentUserId = await FirebaseAuth.instance.currentUser!.uid;
    print('currentUserId : -------- $currentUserId');
    print(querySnapshot.docs);
    querySnapshot.docs.forEach((doc) {
      print('Doc');
      print(doc.data());
      String userId = doc.id;
      String name = doc['name'];
      double lat = doc['latitude'];
      double lng = doc['longitude'];
      //double radius = double.parse(doc['radius']);
      bool isEmergency = doc['emergency'] ?? false;
      Color markerColor;
      if (userId == currentUserId) {
        markerColor = Colors.green;
      } else if (isEmergency) {
        markerColor = Colors.red;
        circles.add(
          Circle(
            circleId: CircleId(userId),
            center: LatLng(lat, lng),
            radius: 900,
            strokeWidth: 2,
            strokeColor: Colors.red,
            fillColor: Colors.red.withOpacity(0.1),
          ),
        );
      } else {
        markerColor = Colors.blue;
      }

      Marker marker = Marker(
        markerId: MarkerId(userId),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: name,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          markerColor == Colors.green
              ? BitmapDescriptor.hueGreen
              : markerColor == Colors.red
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueAzure,
        ),
      );
      markers.add(marker);
    });
    setState(() {
      allMarkers = markers;
      _circles = circles;
    });
  }

  Future<Map<String, dynamic>> _getMarkersWithinRadius(
      List<Marker> allMarkers, LatLng userLocation, double radius) async {
    List<DocumentSnapshot> emergencyUsersWithinRadius = [];
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    querySnapshot.docs.forEach((doc) {
      double distanceInMeters = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        doc['latitude'],
        doc['longitude'],
      );

      if (distanceInMeters <= radius && (doc['emergency'] ?? false)) {
        emergencyUsersWithinRadius.add(doc);
      }
    });

    return {'emergencyUsersWithinRadius': emergencyUsersWithinRadius};
  }

  void _updateCheckInButtonVisibility() async {
    Map<String, dynamic> result = await _getMarkersWithinRadius(
        allMarkers, _currentPosition!.toLatLng(), radius);
    List<DocumentSnapshot> emergencyUsersWithinRadius = result['emergencyUsersWithinRadius'];
    print('emergencyUsersWithinRadius ---- ');
    print(emergencyUsersWithinRadius);
    bool isCurrentUserInEmergencyRadius = emergencyUsersWithinRadius.isNotEmpty;

    setState(() {
      _showCheckInButton = isCurrentUserInEmergencyRadius;
    });
  }

  void _showEmergencyUsers(BuildContext context) async {
    Map<String, dynamic> result = await _getMarkersWithinRadius(
        allMarkers, _currentPosition!.toLatLng(), radius);
    setState(() {
      emergencyUsersWithinRadius = result['emergencyUsersWithinRadius'];
    });
  }

  void _popupEmergencyUsers(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Check In'),
          content: const Text(
              'Are you sure you want to check in and view emergency users near you?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Build: _showCheckInButton: $_showCheckInButton');
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
            },
            initialCameraPosition: _currentPosition != null
                ? CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 15,
                  )
                : const CameraPosition(
                    target: LatLng(32.1002312, 74.8706735),
                    zoom: 13,
                  ),
            markers: Set<Marker>.of(allMarkers),
            circles: Set<Circle>.of(_circles),
            myLocationEnabled: true,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.2,
              maxChildSize: 0.8,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: SizedBox(
                              height: 200, // Adjust the height as needed
                              child: GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                children: [
                                  Consumer<EmergencyStatusProvider>(
                                    builder: (context, emergencyStatus, _) {
                                      return SquareButton(
                                        buttonColor: emergencyStatus.isEmergency ? Colors.red : Colors.white,
                                        icon: emergencyStatus.isEmergency ? Icons.flag : Icons.emergency,
                                        iconColor: emergencyStatus.isEmergency ? Colors.white : Colors.red.shade300,
                                        text: emergencyStatus.isEmergency ? 'Stop Emergency' : 'Start Emergency',
                                        textStyle: TextStyle(
                                          color: emergencyStatus.isEmergency ? Colors.white : Colors.red.shade300,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        onPressed: () {
                                          _toggleRecording();
                                        },
                                      );
                                    },
                                  ),
                                  SquareButton(
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red.shade300,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    buttonColor: Colors.white,
                                    icon: Icons.video_library,
                                    iconColor: Colors.red.shade300,
                                    text: 'Videos',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const VideoListScreen()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_showCheckInButton)
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: CustomButton(
                                onPressed: () {
                                  _showEmergencyUsers(context);
                                },
                                text: 'Check In',
                              ),
                            ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              title: const Text(
                                'Emergency Users Near You',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                              ),
                              tileColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                itemCount: emergencyUsersWithinRadius.length,
                                itemBuilder: (BuildContext context, int index) {
                                  DocumentSnapshot user = emergencyUsersWithinRadius[index];
                                  double distance = Geolocator.distanceBetween(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                    user['latitude'],
                                    user['longitude'],
                                  );
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.grey[100],
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        _popupEmergencyUsers(context);
                                      },
                                      title: Text(
                                        user['name'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Distance: ${distance.toStringAsFixed(2)} meters',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      trailing: const Icon(Icons.arrow_forward_ios),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRecording() {
    if (_emergencyStatusProvider.isEmergency) {
      _stopEmergency();
    } else {
      _startEmergency();
    }
  }

  void _startEmergency() async {
    setState(() {
      _emergencyStatusProvider.setEmergencyStatus(true);
      setEmergencyStatus(true);
    });

    while (_latitude == null || _longitude == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (_latitude != null || _longitude != null) {
      await _initializeCamera();
      await _initializeControllerFuture;

      XFile photo = await _controller.takePicture();
      await _controller.startVideoRecording();
      _recordingTimer = Timer(const Duration(minutes: 1), () {
        _stopRecording();
      });
      print(photo.path);
      File photoFile = File(photo.path);
      await _startEmergencyApi(photoFile, _latitude!, _longitude!);
      final usersIds = await _getUserIdsInRadius();
      await sendNotification(usersIds);
    }
  }

  void _stopRecording() async {
    try {
      final dateTime = DateTime.now();
      XFile video = await _controller.stopVideoRecording();
      setState(() {
        videoFile = video.path;
      });
      final dbHelper = DatabaseHelper();
      dbHelper.insertVideoFile(VideoFile(
        path: video.path,
        dateTime: dateTime.toString(),
      ));
      _controller.dispose();
      print('Video recorded: ${video.path}');
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  void _stopEmergency() async {
    setState(() {
      _emergencyStatusProvider.setEmergencyStatus(false);
      setEmergencyStatus(false);
    });
    _stopRecording();
    if (_recordingTimer.isActive) {
      _recordingTimer.cancel();
    }
    await _endEmergencyApi(_latitude!, _longitude!);
    _locationService.stopLocationService();
  }

  Future<void> _startEmergencyApi(
      File file, String latitude, String longitude) async {
    try {
      var emergencyIdProvider =
          Provider.of<EmergencyIdProvider>(context, listen: false);
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://test.hibalogics.com/api/start/emergency'));
      String bearerToken = '3|Lg6Sal0SJG6JqxMyHzShOyqg2zIT0orSR3OkbSCo987dff9f';
      request.headers['Authorization'] = 'Bearer $bearerToken';
      request.files.add(http.MultipartFile(
          'file', file.readAsBytes().asStream(), file.lengthSync(),
          filename: file.path.split('/').last));
      request.fields['lat'] = latitude.toString();
      request.fields['lan'] = longitude.toString();

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var decodedResponse = jsonDecode(responseBody);
      final message = decodedResponse['message'];
      final statusCode = decodedResponse['status'];
      var emergencyId = decodedResponse['file']['id'];

      emergencyIdProvider.setEmergencyId(emergencyId);

      if (statusCode == 'success') {
        print('File uploaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Failed to upload file. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API failed .'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> _endEmergencyApi(String latitude, String longitude) async {
    try {
      var emergencyIdProvider =
          Provider.of<EmergencyIdProvider>(context, listen: false);
      String emergencyId = emergencyIdProvider.emergencyId.toString();

      var uri = Uri.parse('https://test.hibalogics.com/api/end/emergency');
      String bearerToken = '3|Lg6Sal0SJG6JqxMyHzShOyqg2zIT0orSR3OkbSCo987dff9f';
      var response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $bearerToken',
        },
        body: {
          'emergency_id': emergencyId,
          'end_lat': latitude.toString(),
          'end_lan': longitude.toString(),
        },
      );
      var decodedResponse = jsonDecode(response.body);
      final message = decodedResponse['message'];
      final statusCode = decodedResponse['status'];
      if (statusCode == 'success') {
        print('Message Response: $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Failed to end emergency. Status code: $message');
      }
    } catch (e) {
      print('Error ending emergency: $e');
    }
  }

  Future<List> _getUserIdsInRadius() async {
    final currentUserId = await FirebaseAuth.instance.currentUser!.uid;
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    final currentUserData = currentUserDoc.data();
    if (currentUserData == null) {
      print('Current user data not found!');
      return [];
    }

    final double currentUserLat = currentUserData['latitude'];
    final double currentUserLng = currentUserData['longitude'];
    final double currentUserRadius = currentUserData['radius'];

    final querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    final List userIdsInRadius = [];

    querySnapshot.docs.forEach((doc) {
      final userId = doc['uuid'];
      final lat = doc['lat'];
      final lng = doc['lan'];
      // Calculate distance between current user and this user
      final distanceInMeters = Geolocator.distanceBetween(
        currentUserLat,
        currentUserLng,
        lat,
        lng,
      );
      if (distanceInMeters <= currentUserRadius) {
        // User is within the radius
        userIdsInRadius.add(userId);
      }
    });
    print(userIdsInRadius);
    return userIdsInRadius;
  }

  Future<void> sendNotification(List userIds) async {
    print('user IDs List -------');
    print(userIds.join(','));
    final url = Uri.parse('https://test.hibalogics.com/api/send-notification');
    //final token = await AuthService.getAccessToken();
    print('token -------');
    //print(token);
    final response = await http.post(
      url,
      // headers: {
      //   'Authorization': 'Bearer $token',
      // },
      body: {
        'userIds': userIds.join(','),
      },
    );

    try {
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      var dataResponse = decodedResponse['data'];
      // Check response status code
      if (dataResponse == 'notification sent') {
        print("Notification sent successfully");
      } else {
        print(
            "Failed to send notification. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error sending notification: $error");
    }
  }
}

extension PositionExtension on Position {
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}

// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
//
// class LocationWidget extends StatelessWidget {
//   final double latitude;
//   final double longitude;
//
//   const LocationWidget({Key? key, required this.latitude, required this.longitude}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//
//       margin: EdgeInsets.symmetric(vertical: 16),
//       padding: EdgeInsets.symmetric(horizontal: 54, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8),
//             child: Text(
//               'My Location',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Latitude:',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 4),
//                     Text(latitude.toString()),
//                     SizedBox(height: 16),
//                     Text(
//                       'Longitude:',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 4),
//                     Text(longitude.toString()),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 16),
//               Expanded(
//                 child: Container(
//                   height: 150,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey), // Add border to mimic an image
//                   ),
//                   child: GoogleMapTile(latitude: latitude, longitude: longitude),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
// class GoogleMapTile extends StatelessWidget {
//   final double latitude;
//   final double longitude;
//
//   const GoogleMapTile({Key? key, required this.latitude, required this.longitude}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GoogleMap(
//       initialCameraPosition: CameraPosition(
//         target: LatLng(latitude, longitude),
//         zoom: 12,
//       ),
//       markers: {
//         Marker(
//           markerId: MarkerId('location'),
//           position: LatLng(latitude, longitude),
//           infoWindow: InfoWindow(title: 'Location'),
//         ),
//       },
//       gestureRecognizers: Set()..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer())),
//       zoomControlsEnabled: false, // Disable zoom controls
//       myLocationButtonEnabled: false, // Disable my location button
//       scrollGesturesEnabled: false, // Disable scroll gestures
//       rotateGesturesEnabled: false, // Disable rotate gestures
//       tiltGesturesEnabled: false, // Disable tilt gestures
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:location_chat/Database/files_database.dart';
// import 'package:location_chat/Screens/VideoRecorder/video_player.dart';
//
// class VideoRecorderScreen extends StatefulWidget {
//   final List<CameraDescription> cameras;
//
//   VideoRecorderScreen(this.cameras);
//
//   @override
//   _VideoRecorderScreenState createState() => _VideoRecorderScreenState();
// }
//
// class _VideoRecorderScreenState extends State<VideoRecorderScreen> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   bool _isRecording = false;
//   String? videoFile;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = CameraController(
//       widget.cameras.first,
//       ResolutionPreset.high,
//       enableAudio: true,
//     );
//     _initializeControllerFuture = _controller.initialize();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video Recorder'),
//       ),
//       body: Stack(
//         children: [
//           FutureBuilder<void>(
//             future: _initializeControllerFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 return CameraPreview(_controller);
//               } else {
//                 return const Center(child: CircularProgressIndicator());
//               }
//             },
//           ),
//           if (_isRecording)
//             Container(color: Colors.white),
//         ],
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             heroTag: 'record_button',
//             child: _isRecording ? const Icon(Icons.stop) : const Icon(Icons.videocam),
//             onPressed: () {
//               if (_isRecording) {
//                 _stopRecording();
//               } else {
//                 _startRecording();
//               }
//             },
//           ),
//           const SizedBox(height: 16),
//           FloatingActionButton(
//             heroTag: 'play_button',
//             child: Icon(Icons.play_arrow),
//             onPressed: videoFile != null ? () => _navigateToVideoPlayer(videoFile!) : null,
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _startRecording() async {
//     try {
//       await _initializeControllerFuture;
//       await _controller.startVideoRecording();
//       setState(() {
//         _isRecording = true;
//       });
//     } catch (e) {
//       print('Error starting recording: $e');
//     }
//   }
//
//   void _stopRecording() async {
//     try {
//       XFile video = await _controller.stopVideoRecording();
//       setState(() {
//         _isRecording = false;
//         videoFile = video.path;
//       });
//       // Do something with the recorded video
//       final dbHelper = DatabaseHelper();
//       dbHelper.insertVideoFile(video.path);
//       print('Video recorded: ${video.path}');
//     } catch (e) {
//       print('Error stopping recording: $e');
//     }
//   }
//
//   void _navigateToVideoPlayer(String videoFile) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => VideoPlayerScreen(videoFile: videoFile),
//       ),
//     );
//   }
// }

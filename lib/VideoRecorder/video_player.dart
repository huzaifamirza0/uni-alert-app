import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoFile;

  const VideoPlayerScreen({Key? key, required this.videoFile}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  bool _isPlaying = false;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
    print(widget.videoFile);
    _videoController = VideoPlayerController.file(File(widget.videoFile));
    _initializeVideoPlayerFuture = _initializeVideoPlayer();

  }

  Future<void> _initializeVideoPlayer() async {
    try {
      await _videoController.initialize();
      _videoController.addListener(() {
        setState(() {
          _isPlaying = _videoController.value.isPlaying;
        });
      });
    } catch (error) {
      print('Error initializing video player: $error');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 15),
              const Text('Video Title'),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_isPlaying) {
                          _videoController.pause();
                        } else {
                          _videoController.play();
                        }
                      });
                    },
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 36,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _videoController.seekTo(Duration.zero);
                    },
                    icon: const Icon(
                      Icons.replay,
                      size: 36,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 60,),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom), // Adjusts for keyboard
            ],
          ),
        ),
      ),
    );
  }

}

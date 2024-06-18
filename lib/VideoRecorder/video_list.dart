import 'dart:io';
import 'package:notification_app/VideoRecorder/video_file_model.dart';
import 'package:notification_app/VideoRecorder/video_player.dart';
import 'package:flutter/material.dart';
import '../../Database/files_database.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../Components/video_card.dart';
class VideoListScreen extends StatefulWidget {
  const VideoListScreen({Key? key}) : super(key: key);

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<VideoFile> _videoFiles = [];
  final DatabaseHelper dbHelper = DatabaseHelper();
  int? compressSizeString;
  
  @override
  void initState() {
    super.initState();
    _refreshVideoFiles();
  }

  Future<void> _refreshVideoFiles() async {
    List<VideoFile> videoFile = await dbHelper.getVideoFiles();
    setState(() {
      _videoFiles = videoFile;
    });
  }

  Future<Image> _videoThumbnail(String path) async {
    final thumbnailData = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.PNG,
      maxWidth: 128,
      quality: 50,
    );
    final image = Image.memory(thumbnailData!, fit: BoxFit.cover,);
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordings'),
      ),
      body: _videoFiles.isEmpty
          ?  const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.red,),
            SizedBox(height: 10),
            Text(
              'Oops! There is no data available',
              style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ) : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            itemCount: _videoFiles.length,
            itemBuilder: (context, index) {
              final path = _videoFiles[index].path;
              final date = _videoFiles[index].dateTime.substring(0,9);
              final time = _videoFiles[index].dateTime.substring(10,19);
              final title = 'VID${_videoFiles[index].dateTime}';
              final file = File(path);
              final fileSize = file.existsSync() ? file.lengthSync() : 0;
              final fileSizeString = _formatFileSize(fileSize);
              final thumbnail = _videoThumbnail(path);
              return FutureBuilder<Image>(
                future: thumbnail,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else {
                    if (snapshot.hasError) {
                      return const Text('Error loading thumbnail');
                    } else {
                      return VideoCard(
                        thumbnailPath: snapshot.data!,
                        title: title,
                        date: date,
                        time: time,
                        fileSize: fileSizeString,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoFile: path)));
                        },
                      );
                    }
                  }
                },
              );
            }
        ),
      )
    );
  }

  String _formatFileSize(int fileSize) {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
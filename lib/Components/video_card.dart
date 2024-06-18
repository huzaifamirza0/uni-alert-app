import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {
  final Image? thumbnailPath;
  final String title;
  final String date;
  final String time;
  final String fileSize;
  final VoidCallback onPressed;

  const VideoCard({
    Key? key,
    required this.thumbnailPath,
    required this.title,
    required this.date,
    required this.time,
    required this.fileSize,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 100,
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: thumbnailPath,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.date_range),
                        SizedBox(width: 6),
                        Text(date),
                        SizedBox(width: 20),
                        Icon(Icons.access_time),
                        SizedBox(width: 6),
                        Text(time),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(fileSize),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

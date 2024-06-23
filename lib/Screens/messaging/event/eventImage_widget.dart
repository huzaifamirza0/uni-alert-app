import 'dart:io';
import 'package:flutter/material.dart';

class EventImageWidget extends StatefulWidget {
  final String imagePath;
  final VoidCallback onClicked;

  const EventImageWidget({
    Key? key,
    required this.imagePath,
    required this.onClicked,
  }) : super(key: key);

  @override
  _EventImageWidgetState createState() => _EventImageWidgetState();
}

class _EventImageWidgetState extends State<EventImageWidget> {

  @override
  Widget build(BuildContext context) {
    bool isFile = widget.imagePath.startsWith('/');

    return InkWell(
      onTap: widget.onClicked,
      child: Container(
        width: 300,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: isFile
                ? FileImage(File(widget.imagePath))
                : AssetImage(widget.imagePath) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Icon(
                Icons.add_a_photo,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'eventImage_widget.dart';

class EventDialog extends StatefulWidget {
  final String userRole;

  EventDialog({required this.userRole});

  @override
  _EventDialogState createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventDateController = TextEditingController();
  String _eventImagePath = ''; // Holds the path of the event image
  DateTime? _selectedDate; // Holds the selected date
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _eventDateController.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      String imageUrl = 'assets/welcome.jpg'; // Default image path
      File? imageFile;

      if (_eventImagePath.isNotEmpty) {
        if (_eventImagePath.startsWith('/')) {
          // Local file path
          imageFile = File(_eventImagePath);
        } else {
          // Asset image path
          ByteData byteData = await rootBundle.load(_eventImagePath);
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = '${tempDir.path}/temp_asset_image.jpg';
          imageFile = File(tempPath);
          await imageFile.writeAsBytes(byteData.buffer.asUint8List());
        }

        if (imageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('event_images')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          await storageRef.putFile(imageFile);
          imageUrl = await storageRef.getDownloadURL();
        }
      }

      Map<String, dynamic> eventData = {
        'creatorId': _auth.currentUser?.uid,
        'name': _eventNameController.text,
        'description': _eventDescriptionController.text,
        'date': Timestamp.fromDate(_selectedDate ?? DateTime.now()),
        'image': imageUrl,
        'createdBy': widget.userRole,
      };

      await FirebaseFirestore.instance.collection('events').add(eventData);
      Navigator.of(context).pop();
    }
  }
  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take Photo'),
              onTap: () {
                _getImageFromCamera(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                _getImageFromGallery(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getImageFromCamera(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _eventImagePath = image.path;
      });
    }
  }

  Future<void> _getImageFromGallery(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _eventImagePath = image.path;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _eventDateController.text = "${picked.toLocal()}".split(' ')[0]; // Formatting date to YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create an Event', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EventImageWidget(
                imagePath: _eventImagePath.isNotEmpty ? _eventImagePath : 'assets/welcome.jpg',
                onClicked: () {
                  _showUploadOptions(context);
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _eventDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Event Description',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _eventDateController,
                decoration: const InputDecoration(
                  labelText: 'Event Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                ),
                onTap: () async {
                  // Prevents the keyboard from showing up
                  FocusScope.of(context).requestFocus(new FocusNode());
                  await _selectDate(context);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event date';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createEvent,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Create', style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}

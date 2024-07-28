import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:notification_app/Screens/chat_rooms/message_widgget.dart';
import 'package:notification_app/Screens/department/data_model.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BatchChatRoom extends StatefulWidget {
  final String departmentId;
  final Batch batch;
  final String userRole;

  BatchChatRoom({
    required this.departmentId,
    required this.batch,
    required this.userRole,
  }) {
    assert(departmentId.isNotEmpty, 'Department ID must not be empty');
    assert(batch.batchId.isNotEmpty, 'Batch ID must not be empty');
  }

  @override
  _BatchChatRoomState createState() => _BatchChatRoomState();
}

class _BatchChatRoomState extends State<BatchChatRoom> {
  TextEditingController messageController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  void onSendMessage(String? imageUrl, String? fileUrl, String? fileName) async {
    if (messageController.text.isNotEmpty || imageUrl != null || fileUrl != null) {
      Map<String, dynamic> messages = {
        'senderId': _auth.currentUser!.uid,
        'content': messageController.text,
        'imageUrl': imageUrl ?? '',
        'fileUrl': fileUrl ?? '',
        'fileName': fileName ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('departments')
          .doc(widget.departmentId)
          .collection('batches')
          .doc(widget.batch.batchId)
          .collection('messages')
          .add(messages);
      messageController.clear();
    } else {
      print('Write something or upload a file');
    }
  }

  Future<void> selectAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = path.basename(file.path);
        String fileExtension = path.extension(file.path).toLowerCase();
        String storagePath = 'uploads/${DateTime.now().millisecondsSinceEpoch}$fileExtension';
        UploadTask task = _storage.ref(storagePath).putFile(file);

        TaskSnapshot snapshot = await task;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        onSendMessage(null, downloadUrl, fileName);
      }
    } catch (e) {
      print('File upload error: $e');
    }
  }

  Future<void> selectAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        UploadTask task = _storage.ref('uploads/$fileName').putFile(file);

        TaskSnapshot snapshot = await task;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        onSendMessage(downloadUrl, null, null);
      }
    } catch (e) {
      print('Image upload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.batch.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('departments')
                  .doc(widget.departmentId)
                  .collection('batches')
                  .doc(widget.batch.batchId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> map = document.data() as Map<String, dynamic>;
                    return MessageWidget(size: size, map: map);
                  }).toList(),
                );
              },
            ),
          ),
          if (widget.userRole == 'student') ...{
            Container(
              height: size.height / 14,
              width: size.width,
              color: Colors.grey.withOpacity(0.8),
              alignment: Alignment.center,
              child: SizedBox(
                height: size.height / 12,
                width: size.width / 1.1,
                child: const Center(
                  child: Text(
                    'Only HOD and faculty members can post messages.',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
          } else ...{
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: SizedBox(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo),
                      onPressed: selectAndUploadImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: selectAndUploadFile,
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => onSendMessage(null, null, null),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.lightGreen,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          }
        ],
      ),
    );
  }
}

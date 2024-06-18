import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chat_message_timestamp/chat_message_timestamp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DepartmentMessages extends StatelessWidget {
  final String departmentId;

  DepartmentMessages({required this.departmentId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('departments')
          .doc(departmentId)
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

        var messages = snapshot.data!.docs;

        if (messages.isEmpty) {
          return const Center(
              child: Text('There are no messages for this department'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            return _messageItem(context, message);
          },
        );
      },
    );
  }

  Widget _messageItem(BuildContext context, DocumentSnapshot message) {
    Map<String, dynamic> map = message.data() as Map<String, dynamic>;
    Timestamp? timestamp = map['timestamp'] as Timestamp?;
    String time =
        timestamp != null ? _formatTime(timestamp.toDate()) : 'Unknown';
    String fileName = map['fileName'] ?? 'Unknown file';
    String fileUrl = map['fileUrl'] ?? '';
    String imageUrl = map['imageUrl'] ?? '';
    String senderId = map['senderId'] ?? 'Unknown sender';

    return FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(senderId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading sender info'));
          }

          String senderName = snapshot.data != null
              ? (snapshot.data!.data() as Map<String, dynamic>)['name'] ??
                  'Unknown sender'
              : 'Unknown sender';
          print(snapshot.data!.data());

          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.lightGreen,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senderName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (map['content'] != null && map['content'].isNotEmpty)
                  TimestampedChatMessage(
                    sendingStatusIcon: Icon(Icons.check),
                    text: map['content'],
                    sentAt: time,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    sentAtStyle:
                        const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 3,
                    delimiter: '\u2026',
                    viewMoreText: 'showMore',
                    showMoreTextStyle: const TextStyle(color: Colors.blue),
                  ),
                if (imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(imageUrl),
                        Text(
                          time,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (fileUrl.isNotEmpty)
                  GestureDetector(
                    onTap: () => _openFile(fileUrl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.insert_drive_file,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              fileName,
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        });
  }

  String _formatTime(DateTime time) {
    String period = time.hour < 12 ? 'AM' : 'PM';
    int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> _openFile(String url) async {
    final file = await _downloadFile(url);
    if (file != null) {
      OpenFile.open(file.path);
    }
  }

  Future<File?> _downloadFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/${path.basename(url)}');
      file.writeAsBytesSync(response.bodyBytes);
      return file;
    } catch (e) {
      print('File download error: $e');
      return null;
    }
  }
}

import 'dart:io';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chat_message_timestamp/chat_message_timestamp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../chat_rooms/message_widgget.dart';

class DepartmentMessages extends StatelessWidget {
  final String departmentId;

  DepartmentMessages({required this.departmentId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('departments')
          .doc(departmentId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(5)
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
    String time = timestamp != null ? _formatTime(timestamp.toDate()) : 'Unknown';
    String fileName = map['fileName'] ?? 'Unknown file';
    String fileUrl = map['fileUrl'] ?? '';
    String imageUrl = map['imageUrl'] ?? '';
    String senderId = map['senderId'] ?? 'Unknown sender';
    String messageContent = map['content'] ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(senderId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading sender info'));
        }

        String senderName = 'Unknown sender';
        if (snapshot.data != null && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            senderName = data['displayName'] ?? 'Unknown sender';
          }
        }

        Widget messageWidget;
        if (_containsUrl(messageContent)) {
          // Content has URLs, show Linkify
          messageWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Linkify(
                onOpen: (link) async {
                  final Uri uri = Uri.parse(link.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    throw 'Could not launch ${link.url}';
                  }
                },
                text: messageContent,
                style: const TextStyle(color: Colors.black),
                linkStyle: const TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ],
          );
        } else {
          // No URLs, show TimestampedChatMessage
          messageWidget = TimestampedChatMessage(
            sendingStatusIcon: const Icon(Icons.check, color: Colors.black),
            text: messageContent,
            sentAt: time,
            style: const TextStyle(color: Colors.black, fontSize: 16),
            sentAtStyle: const TextStyle(color: Colors.black, fontSize: 12),
            maxLines: 3,
            delimiter: '\u2026',
            viewMoreText: 'showMore',
            showMoreTextStyle: const TextStyle(color: Colors.blue),
          );
        }
        return Container(
          width: MediaQuery.of(context).size.width * 0.68,
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ]),
          child: Row(
            mainAxisAlignment: map['senderId'] == _auth.currentUser!.uid
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 15,
                child: Text(senderName[0]),
              ),
              const SizedBox(width: 10),
              Flexible(
                // constraints: BoxConstraints(maxWidth: size.width * 0.75),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      senderName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    messageWidget,
                    if (fileUrl.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          await _handleFileOrUrl(
                              messageContent, fileUrl, fileName);
                        },
                        child: Text(
                          'File: $fileName',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                    if (imageUrl.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FullScreenImage(imageUrl: imageUrl),
                            ),
                          );
                        },
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleFileOrUrl(String content, String fileUrl, String fileName) async {
    if (content.contains('http')) {
      Uri uri = Uri.parse(content);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        print('Could not launch $content');
      }
    } else if (fileUrl.isNotEmpty) {
      await _downloadAndOpenFile(fileUrl, fileName);
    } else {
      print('No valid URL or file URL provided');
    }
  }

  Future<void> _downloadAndOpenFile(String url, String fileName) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String filePath = path.join(tempPath, fileName);

      var response = await http.get(Uri.parse(url));
      var file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      await OpenFile.open(filePath);
    } catch (e) {
      print('Error downloading or opening file: $e');
    }
  }

  String _formatTime(DateTime time) {
    String period = time.hour < 12 ? 'AM' : 'PM';
    int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  bool _containsUrl(String text) {
    // Regular expression to match URLs
    RegExp regex = RegExp(
        r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
        caseSensitive: false);
    return regex.hasMatch(text);
  }

}

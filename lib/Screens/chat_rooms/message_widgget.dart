import 'dart:io';
import 'package:chat_message_timestamp/chat_message_timestamp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageWidget extends StatelessWidget {
  final Size size;
  final Map<String, dynamic> map;

  MessageWidget({required this.size, required this.map});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Timestamp? timestamp = map['timestamp'] as Timestamp?;
    String time = timestamp != null ? _formatTime(timestamp.toDate()) : 'Unknown';
    String fileName = map['fileName'] ?? 'Unknown file';
    String fileUrl = map['fileUrl'] ?? '';
    String imageUrl = map['imageUrl'] ?? '';
    String senderId = map['senderId'] ?? 'Unknown sender';
    String content = map['content'] ?? '';

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
        if (_containsUrl(content)) {
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
                text: content,
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
            text: content,
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
          width: MediaQuery.of(context).size.width * 0.75,
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: map['senderId'] == _auth.currentUser!.uid
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (map['senderId'] != _auth.currentUser!.uid) ...[
                CircleAvatar(
                  radius: 15,
                  child: Text(senderName[0]),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  // constraints: BoxConstraints(maxWidth: size.width * 0.75),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: senderId == _auth.currentUser?.uid
                        ? Colors.lightGreen[300]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: senderId == _auth.currentUser?.uid
                          ? const Radius.circular(12)
                          : const Radius.circular(0),
                      bottomRight: senderId != _auth.currentUser?.uid
                          ? const Radius.circular(12)
                          : const Radius.circular(0),
                    ),
                  ),
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
                            await _handleFileOrUrl(content, fileUrl, fileName);
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
                                builder: (_) => FullScreenImage(imageUrl: imageUrl),
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
              ),
              if (map['senderId'] == _auth.currentUser!.uid) ...[
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 15,
                  child: Text(senderName[0]),
                ),
              ],
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

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained * 1.0,
          maxScale: PhotoViewComputedScale.covered * 2.0,
        ),
      ),
    );
  }
}
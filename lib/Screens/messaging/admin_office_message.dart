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
import 'package:rxdart/rxdart.dart';

class SubscribedMessagesGrid extends StatefulWidget {
  @override
  _SubscribedMessagesGridState createState() => _SubscribedMessagesGridState();
}

class _SubscribedMessagesGridState extends State<SubscribedMessagesGrid> {
  Stream<List<QuerySnapshot>>? _messageStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchSubscribedMessages();
  }

  void _fetchSubscribedMessages() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('No current user found.');
      return;
    }

    var userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (!userDoc.exists) {
      print('User document does not exist.');
      return;
    }

    List<String> subscribedAdminOffices = List<String>.from(userDoc['subscribedAdminOffices']);

    // Fetch all admin offices where the current user is the admin
    var adminOfficesQuery = await _firestore.collection('adminOffices')
        .where('adminId', isEqualTo: currentUser.uid).get();
    List<String> adminOfficeIds = adminOfficesQuery.docs.map((doc) => doc.id).toList();

    // Combine both lists without duplicates
    List<String> officeIds = [
      ...subscribedAdminOffices,
      ...adminOfficeIds.where((id) => !subscribedAdminOffices.contains(id))
    ];

    if (officeIds.isEmpty) {
      print('No subscribed or admin offices.');
      setState(() {
        _messageStream = null;
      });
      return;
    }

    List<Stream<QuerySnapshot>> messageStreams = officeIds.map((officeId) {
      return _firestore.collection('adminOffices').doc(officeId).collection('messages')
          .orderBy('timestamp', descending: true).limit(8).snapshots();
    }).toList();

    if (mounted) {
      setState(() {
        _messageStream = CombineLatestStream.list(messageStreams);
      });
    }
  }

  Widget _messageItem(BuildContext context, DocumentSnapshot message) {
    Map<String, dynamic> map = message.data() as Map<String, dynamic>;
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

        String senderName = 'Anonymous';
        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            senderName = data['displayName'] ?? 'Anonymous';
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
                text: _truncateMessage(content),
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
          messageWidget = TimestampedChatMessage(
            sendingStatusIcon: const Icon(Icons.check, color: Colors.black),
            text: _truncateMessage(content),
            sentAt: time,
            style: const TextStyle(color: Colors.black, fontSize: 16),
            sentAtStyle: const TextStyle(color: Colors.black, fontSize: 12),
            maxLines: 3,
            delimiter: '\u2026',
            viewMoreText: 'showMore',
            showMoreTextStyle: const TextStyle(color: Colors.blue),
          );
        }
        return GestureDetector(
          onTap: (){
            _showMessageDialog(context, senderName, content, time, fileUrl, fileName, imageUrl);
            },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: map['senderId'] == _auth.currentUser!.uid
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    // constraints: BoxConstraints(maxWidth: size.width * 0.75),
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          senderName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                              width: 70,
                              height: 70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

  String _truncateMessage(String message, {int maxLength = 50}) {
    if (message.length <= maxLength) {
      return message;
    } else {
      return '${message.substring(0, maxLength)}... see more';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_messageStream == null) {
      return const Center(child: Text('Subscribe to an admin office to see messages.'));
    }

    return StreamBuilder<List<QuerySnapshot>>(
      stream: _messageStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var messages = snapshot.data!.expand((qs) => qs.docs).toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.lightGreen)
              ),
                child: _messageItem(context, message));
          },
        );
      },
    );
  }

  void _showMessageDialog(BuildContext context, String senderName, String messageContent, String time, String fileUrl, String fileName, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(senderName),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 10),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                if (fileUrl.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      await _downloadAndOpenFile(fileUrl, fileName);
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
                  const SizedBox(height: 10),
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
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
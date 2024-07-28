import 'dart:io';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:chat_message_timestamp/chat_message_timestamp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Services/logOutDialog.dart';
import '../Profile/page/profile_page.dart';
import '../messaging/admin_office_message.dart';
import '../messaging/event/event_dialog.dart';
import '../messaging/event/event_model.dart';
import '../messaging/event/event_widget.dart';
import 'drawer.dart';
import '../department/search_office.dart';
import '../messaging/department_message.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final appBarTitleFontSize = mediaQuery.size.width > 600 ? 28.0 : 24.0;

    return FutureBuilder<DocumentSnapshot>(
        future:
            _firestore.collection('users').doc(_auth.currentUser!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading sender info'));
          }
          String userRole = snapshot.data != null
              ? (snapshot.data!.data() as Map<String, dynamic>)['role'] ??
                  'Unknown role'
              : 'Unknown role';
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              toolbarHeight: 76,
              toolbarOpacity: 0.7,
              backgroundColor: Colors.lightGreen.shade300,
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    tooltip:
                        MaterialLocalizations.of(context).openAppDrawerTooltip,
                  );
                },
              ),
              title: Text(
                'UniAlert',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: appBarTitleFontSize,
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubscribeScreen()));
                    },
                    icon: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                    )),
                const SizedBox(width: 12),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()));
                    },
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                    )),
                const SizedBox(width: 10),
              ],
            ),
            drawer: CustomDrawer(
              onLogout: () {
                showDeleteUserDialog(context);
              },
              userRole: userRole,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Public Messages', Icons.public),
                  _buildHorizontalSlider(context, _fetchMessages('messages')),
                  const Divider(),
                  _buildSectionTitle(
                      context, 'Department Messages', Icons.school),
                  const SizedBox(height: 16.0),
                  _buildDepartmentMessages(context),
                  const Divider(),
                  _buildSectionTitle(
                      context, 'Office Messages', Icons.local_post_office),
                  const SizedBox(height: 16.0),
                  SubscribedMessagesGrid(),
                  const Divider(),
                  _buildSectionTitle(
                      context, 'Events and Alerts', Icons.auto_awesome),
                  const SizedBox(height: 16.0),
                  _buildHorizontalSliderEvents(context, _fetchMessages('events')),
                  const SizedBox(height: 92.0),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.lightGreen,
        ),
        const SizedBox(
          width: 12,
        ),
        Text(
          title,
          style: const TextStyle(
              color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildHorizontalSlider(
      BuildContext context, Stream<QuerySnapshot> messageStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading messages'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages available'));
        }

        var messages = snapshot.data!.docs;
        return SizedBox(
          height: 200.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: messageWidget(context, message),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHorizontalSliderEvents(BuildContext context, Stream<QuerySnapshot> eventStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: eventStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var events = snapshot.data!.docs
            .map((doc) => Event.fromDocumentSnapshot(doc))
            .toList();
        return SizedBox(
          height: 250.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            itemBuilder: (context, index) {
              var event = events[index];
              return EventCard(
                event: event,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return EventDetailDialog(event: event);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDepartmentMessages(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        if (userData == null || userData['departmentCode'] == null) {
          return const Center(child: Text('No department messages available'));
        }
        String departmentCode = userData['departmentCode'];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('departments')
              .where('code', isEqualTo: departmentCode)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data?.docs.isEmpty ?? true) {
              return const Center(
                  child: Text('No department messages available'));
            }

            var department = snapshot.data!.docs.first;
            return DepartmentMessages(departmentId: department.id);
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _fetchMessages(String collection) {
    return FirebaseFirestore.instance.collection(collection).snapshots();
  }

  Widget messageWidget(BuildContext context, DocumentSnapshot map) {
    Timestamp? timestamp = map['timestamp'] as Timestamp?;
    String time =
        timestamp != null ? _formatTime(timestamp.toDate()) : 'Unknown';
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
                text: _truncateMessage(messageContent),
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
            text: _truncateMessage(messageContent),
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
            _showMessageDialog(context, senderName, messageContent, time);
          },
          child: Container(
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
          ),
        );
      },
    );
  }

  Future<void> _handleFileOrUrl(
      String content, String fileUrl, String fileName) async {
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
    RegExp regex = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
        caseSensitive: false);
    return regex.hasMatch(text);
  }

  void _showMessageDialog(BuildContext context, String senderName,
      String messageContent, String time) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(senderName),
          content: Text(messageContent),
          actions: <Widget>[
            Text(time, style: const TextStyle(fontSize: 10)),
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

  String _truncateMessage(String message, {int maxLength = 90}) {
    return message.length > maxLength
        ? message.substring(0, maxLength) + '...'
        : message;
  }
}

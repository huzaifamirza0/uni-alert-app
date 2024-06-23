import 'package:chat_message_timestamp/chat_message_timestamp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class SubscribedMessagesGrid extends StatefulWidget {
  @override
  _SubscribedMessagesGridState createState() => _SubscribedMessagesGridState();
}

class _SubscribedMessagesGridState extends State<SubscribedMessagesGrid> {
  Stream<List<QuerySnapshot>>? _messageStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchSubscribedMessages();
  }

  void _fetchSubscribedMessages() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    var userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    List<String> subscribedAdminOffices = List<String>.from(userDoc['subscribedAdminOffices']);

    List<Stream<QuerySnapshot>> messageStreams = subscribedAdminOffices.map((officeId) {
      return _firestore.collection('adminOffices').doc(officeId).collection('messages').snapshots();
    }).toList();

    if(mounted){
      setState(() {
        _messageStream = CombineLatestStream.list(messageStreams);
      });
    }
  }

  Widget _messageItem(BuildContext context, DocumentSnapshot message) {
    Map<String, dynamic> map = message.data() as Map<String, dynamic>;
    Timestamp? timestamp = map['timestamp'] as Timestamp?;
    String time = timestamp != null ? _formatTime(timestamp.toDate()) : 'Unknown';
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

        String senderName = snapshot.data != null
            ? (snapshot.data!.data() as Map<String, dynamic>)['name'] ?? 'Unknown sender'
            : 'Unknown sender';

        return GestureDetector(
          onLongPress: () {
            _showMessageDialog(context, senderName, messageContent, time);
          },
          child: Container(
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
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senderName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (map['content'] != null && map['content'].isNotEmpty)
                  GestureDetector(
                    onTap: () => _showMessageDialog(context, senderName, map['message'], time),
                    child: TimestampedChatMessage(
                      sendingStatusIcon: const Icon(
                        Icons.check,
                        color: Colors.lightGreen,
                      ),
                      text: _truncateMessage(messageContent),
                      sentAt: time,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      sentAtStyle: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    String period = time.hour < 12 ? 'AM' : 'PM';
    int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _truncateMessage(String message, {int maxLength = 30}) {
    if (message.length <= maxLength) {
      return message;
    } else {
      return '${message.substring(0, maxLength)}... see more';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_messageStream == null) {
      return const Center(child: CircularProgressIndicator());
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
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            return _messageItem(context, message);
          },
        );
      },
    );
  }

  void _showMessageDialog(BuildContext context, String senderName, String messageContent, String time) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(senderName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(messageContent),
              SizedBox(height: 10),
              Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

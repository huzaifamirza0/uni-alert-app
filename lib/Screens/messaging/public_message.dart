import 'package:chat_message_timestamp/chat_message_timestamp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublicMessages extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var messages = snapshot.data!.docs;

        if (messages.isEmpty) {
          return const Center(child: Text('There are no public messages'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
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
    String senderName = map['sender'] ?? 'Unknown sender';

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
              if (map['message'] != null && map['message'].isNotEmpty)
                TimestampedChatMessage(
                  sendingStatusIcon: const Icon(Icons.check),
                  text: map['message'],
                  sentAt: time,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  sentAtStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 3,
                  delimiter: '\u2026',
                  viewMoreText: 'showMore',
                  showMoreTextStyle: const TextStyle(color: Colors.blue),
                ),
            ],
          ),
        );
  }

  String _formatTime(DateTime time) {
    String period = time.hour < 12 ? 'AM' : 'PM';
    int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

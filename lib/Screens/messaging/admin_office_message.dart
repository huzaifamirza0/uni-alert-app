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

    var userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    List<String> subscribedAdminOffices = List<String>.from(userDoc['subscribedAdminOffices']);

    List<Stream<QuerySnapshot>> messageStreams = subscribedAdminOffices.map((officeId) {
      return FirebaseFirestore.instance.collection('adminOffices').doc(officeId).collection('messages').snapshots();
    }).toList();

    setState(() {
      _messageStream = CombineLatestStream.list(messageStreams);
    });
  }

  Future<String?> _fetchSenderName(String senderId) async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(senderId).get();
    if (userDoc.exists) {
      return userDoc['name'];
    } else {
      return null;
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
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            var senderId = message['senderId'];

            return FutureBuilder<String?>(
              future: _fetchSenderName(senderId),
              builder: (context, senderSnapshot) {
                if (senderSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!senderSnapshot.hasData) {
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.red,
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
                    child: const Center(child: Text("Error loading sender name")),
                  );
                }

                var senderName = senderSnapshot.data;

                return Container(
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
                      if (senderName != null)
                        Text(senderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8.0),
                      Text(message['content']),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

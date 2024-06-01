import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendMessageScreen extends StatelessWidget {
  SendMessageScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String selectedBatchId = '';

  Future<void> _sendMessage(BuildContext context, String departmentId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('messages').add({
        'title': titleController.text,
        'message': messageController.text,
        'senderId': user.uid,
        'recipients': selectedBatchId.isNotEmpty ? [selectedBatchId] : [],
        'departmentId': departmentId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Send Message'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('departments').where('hodId', isEqualTo: user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data?.docs.isEmpty ?? true) {
            return Center(child: Text('No departments found'));
          }

          var department = snapshot.data!.docs.first;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: 'Enter title'),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(hintText: 'Enter message'),
                ),
                SizedBox(height: 16.0),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('departments').doc(department.id).collection('batches').snapshots(),
                  builder: (context, batchSnapshot) {
                    if (batchSnapshot.hasError) {
                      return Center(child: Text('Something went wrong'));
                    }

                    if (batchSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return DropdownButton<String>(
                      value: selectedBatchId,
                      hint: Text('Select batch (optional)'),
                      isExpanded: true,
                      items: batchSnapshot.data!.docs.map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                          value: document.id,
                          child: Text(document['name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        selectedBatchId = newValue ?? '';
                      },
                    );
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _sendMessage(context, department.id),
                  child: Text('Send Message'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

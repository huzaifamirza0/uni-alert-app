import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagingScreen extends StatefulWidget {
  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController messageController = TextEditingController();
  String? selectedDepartmentId;
  String? selectedSemesterId;
  List<DocumentSnapshot> semesters = [];
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> _fetchDepartments() async {
    QuerySnapshot departmentSnapshot = await FirebaseFirestore.instance
        .collection('departments')
        .where('hodId', isEqualTo: user?.uid)
        .get();

    if (departmentSnapshot.docs.isNotEmpty) {
      var department = departmentSnapshot.docs.first;
      var semesterSnapshot = await FirebaseFirestore.instance
          .collection('departments')
          .doc(department.id)
          .collection('semesters')
          .get();

      setState(() {
        selectedDepartmentId = department.id;
        semesters = semesterSnapshot.docs;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageData = {
        'content': messageController.text,
        'senderId': user?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (selectedSemesterId != null) {
        messageData['semesterId'] = selectedSemesterId;
      } else if (selectedDepartmentId != null) {
        messageData['departmentId'] = selectedDepartmentId;
      }

      await FirebaseFirestore.instance.collection('messages').add(messageData);
      messageController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Message'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (semesters.isNotEmpty)
              DropdownButton<String>(
                hint: const Text('Select Semester (Optional)'),
                value: selectedSemesterId,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSemesterId = newValue;
                  });
                },
                items: semesters.map((DocumentSnapshot document) {
                  return DropdownMenuItem<String>(
                    value: document.id,
                    child: Text(document['name']),
                  );
                }).toList(),
              ),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Enter your message'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

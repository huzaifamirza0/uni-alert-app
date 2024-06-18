import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinDepartmentScreen extends StatefulWidget {
  JoinDepartmentScreen({super.key});

  @override
  _JoinDepartmentScreenState createState() => _JoinDepartmentScreenState();
}

class _JoinDepartmentScreenState extends State<JoinDepartmentScreen> {
  final TextEditingController codeController = TextEditingController();
  String? departmentId;
  List<DocumentSnapshot> batches = [];

  void _onCodeChanged(String code) async {
    if (code.isEmpty) {
      setState(() {
        departmentId = null;
        batches = [];
      });
      return;
    }

    QuerySnapshot departmentSnapshot = await FirebaseFirestore.instance
        .collection('departments')
        .where('code', isEqualTo: code)
        .get();

    if (departmentSnapshot.docs.isNotEmpty) {
      var department = departmentSnapshot.docs.first;
      setState(() {
        departmentId = department.id;
      });

      // Fetch batches for the matched department
      QuerySnapshot batchSnapshot = await FirebaseFirestore.instance
          .collection('departments')
          .doc(departmentId)
          .collection('batches')
          .get();

      setState(() {
        batches = batchSnapshot.docs;
      });
    } else {
      setState(() {
        departmentId = null;
        batches = [];
      });
    }
  }

  void _joinBatch(DocumentSnapshot batch) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'departmentCode': codeController.text,
        'batchId': batch.id,
      });

      await FirebaseFirestore.instance
          .collection('departments')
          .doc(departmentId)
          .update({
        'userCount': FieldValue.increment(1),
      });

      await FirebaseFirestore.instance
          .collection('departments')
          .doc(departmentId)
          .collection('batches')
          .doc(batch.id)
          .update({
        'userCount': FieldValue.increment(1),
        'userIds': FieldValue.arrayUnion([user.uid]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined batch successfully')),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    codeController.addListener(() {
      _onCodeChanged(codeController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Department'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(hintText: 'Enter department code'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: batches.isEmpty
                  ? Center(child: Text('Enter a valid department code'))
                  : ListView.builder(
                itemCount: batches.length,
                itemBuilder: (context, index) {
                  var batch = batches[index];
                  return ListTile(
                    title: Text(batch['batch']),
                    onTap: () => _joinBatch(batch),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

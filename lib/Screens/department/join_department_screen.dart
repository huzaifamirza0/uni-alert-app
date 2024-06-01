import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinDepartmentScreen extends StatelessWidget {
   JoinDepartmentScreen({super.key});

  final TextEditingController codeController = TextEditingController();

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
            ElevatedButton(
              onPressed: () async {
                String code = codeController.text;
                QuerySnapshot departmentSnapshot = await FirebaseFirestore.instance.collection('departments').where('code', isEqualTo: code).get();
                if (departmentSnapshot.docs.isNotEmpty) {
                  var department = departmentSnapshot.docs.first;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectBatchScreen(departmentId: department.id)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid department code')));
                }
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectBatchScreen extends StatelessWidget {
  final String departmentId;

  SelectBatchScreen({required this.departmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Batch'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('departments').doc(departmentId).collection('batches').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var batches = snapshot.data!.docs;

          return ListView(
            children: batches.map((batch) {
              return ListTile(
                title: Text(batch['name']),
                onTap: () async {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance.collection('students').doc(user.uid).set({
                      'name': user.displayName,
                      'email': user.email,
                      'phoneNumber': user.phoneNumber,
                      'batchId': batch.id,
                      'departmentId': departmentId,
                    });
                    await FirebaseFirestore.instance.collection('departments').doc(departmentId).update({
                      'userCount': FieldValue.increment(1),
                    });
                    await FirebaseFirestore.instance.collection('departments').doc(departmentId).collection('batches').doc(batch.id).update({
                      'userCount': FieldValue.increment(1),
                    });
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DepartmentDetailScreen extends StatelessWidget {
  final String departmentId;

  DepartmentDetailScreen({required this.departmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Department Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('departments').doc(departmentId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var department = snapshot.data!;

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              ListTile(
                title: Text('Department: ${department['name']}'),
                subtitle: Text('Code: ${department['code']} (visible to HOD)'),
                trailing: Text('Users: ${department['userCount']}'),
              ),
              ListTile(
                title: Text('HOD Name: ${FirebaseAuth.instance.currentUser?.displayName ?? 'HOD'}'),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('departments').doc(departmentId).collection('users').snapshots(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var users = userSnapshot.data!.docs;

                  return ListView(
                    shrinkWrap: true,
                    children: users.map((user) {
                      var userData = user.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(userData['name']),
                        subtitle: Text(userData['email']),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
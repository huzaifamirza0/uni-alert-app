import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class DepartmentScreen extends StatelessWidget {
  const DepartmentScreen({super.key});

  String _generateDepartmentCode() {
    const length = 6;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghiijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> _createDepartment(BuildContext context) async {
    final TextEditingController departmentController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Department'),
          content: TextField(
            controller: departmentController,
            decoration: const InputDecoration(
                hintText: 'Enter department name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                if (departmentController.text.isNotEmpty) {
                  User? user = FirebaseAuth.instance.currentUser;
                  String departmentCode = Random().nextInt(999999).toString();
                  if (user != null) {
                    await FirebaseFirestore.instance.collection('departments')
                        .add({
                      'name': departmentController.text,
                      'hodId': user.uid,
                      'code': departmentCode,
                      'userCount': 0,
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createBatch(BuildContext context, String departmentId) async {
    final TextEditingController batchController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Batch'),
          content: TextField(
            controller: batchController,
            decoration: const InputDecoration(hintText: 'Enter batch name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                if (batchController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('departments')
                      .doc(departmentId)
                      .collection('batches')
                      .add({
                    'name': batchController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                    'userCount': 0,
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createSemester(BuildContext context,
      String departmentId) async {
    final TextEditingController semesterController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Semester'),
          content: TextField(
            controller: semesterController,
            decoration: const InputDecoration(hintText: 'Enter semester name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                if (semesterController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('departments')
                      .doc(departmentId)
                      .collection('semesters')
                      .add({
                    'name': semesterController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Management'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError) {
            return const Center(child: Text('Error loading user data'));
          }

          var userData = userSnapshot.data?.data() as Map<String, dynamic>?;

          if (userData == null) {
            return const Center(child: Text('User data is null'));
          }

          String role = userData['role'];


          if (role == 'hod') {
            return _buildHODView(context, userId);
          } else if (role == 'student') {
            return _buildStudentView(context, userId);
          } else {
            return const Center(child: Text('Invalid user role'));
          }
        },
      ),
    );
  }

  Widget _buildHODView(BuildContext context, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('departments').where(
          'hodId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return Center(
            child: ElevatedButton(
              onPressed: () => _createDepartment(context),
              child: const Text('Create Department'),
            ),
          );
        }

        var department = snapshot.data!.docs.first;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              title: Text('Department: ${department['name']}'),
              subtitle: Text('Code: ${department['code']}'),
            ),
            ElevatedButton(
              onPressed: () => _createBatch(context, department.id),
              child: const Text('Create Batch'),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('departments').doc(
                  department.id).collection('batches').snapshots(),
              builder: (context, semesterSnapshot) {
                if (semesterSnapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (semesterSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: semesterSnapshot.data!.docs.map((
                      DocumentSnapshot document) {
                    return ListTile(
                      title: Text(document['name']),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStudentView(BuildContext context, String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError) {
          return const Center(child: Text('Error loading user data'));
        }

        var userData = userSnapshot.data?.data() as Map<String, dynamic>?;

        if (userData == null) {
          return const Center(child: Text('User data is null'));
        }

        String departmentCode = userData['departmentCode'];

        if (departmentCode.isEmpty) {
          return const Center(child: Text('You are not part of any department.'));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('departments').where('code', isEqualTo: departmentCode).snapshots(),
          builder: (context, departmentSnapshot) {
            if (!departmentSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (departmentSnapshot.hasError) {
              return const Center(child: Text('Error loading department data'));
            }

            var departmentDocs = departmentSnapshot.data?.docs;

            if (departmentDocs == null || departmentDocs.isEmpty) {
              return const Center(child: Text('Department data is null or empty'));
            }

            var departmentData = departmentDocs.first.data() as Map<String, dynamic>;

            String departmentId = departmentDocs.first.id;

            if (departmentData == null) {
              return const Center(child: Text('Department data is null'));
            }

            // Build your UI using departmentData here

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ListTile(
                  title: Text('Department: ${departmentData['name']}'),
                  subtitle: Text('Code: ${departmentData['code']}'),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('departments').doc(departmentId).collection('batches').snapshots(),
                  builder: (context, semesterSnapshot) {
                    if (semesterSnapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }

                    if (semesterSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: semesterSnapshot.data!.docs.map((DocumentSnapshot document) {
                        return ListTile(
                          title: Text(document['name']),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

}

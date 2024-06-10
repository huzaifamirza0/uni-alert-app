import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:notification_app/Screens/department/widgets/batch_widget.dart';
import 'package:notification_app/Screens/department/department_detail_screen.dart';
import 'package:notification_app/Screens/department/widgets/batch_page_view.dart';
import 'data_model.dart';
import 'department_created_view.dart';
import 'dart:math';
import '../../Components/auth_button.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  _DepartmentScreenState createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final TextEditingController messageController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  String _generateDepartmentCode() {
    const length = 6;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
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
            decoration: const InputDecoration(hintText: 'Enter department name'),
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
                  String departmentCode = _generateDepartmentCode();
                  if (user != null) {
                    await FirebaseFirestore.instance.collection('departments').add({
                      'name': departmentController.text,
                      'hodId': user.uid,
                      'code': departmentCode,
                      'userCount': 0,
                      'creationDate': Timestamp.now(),
                      'picture': 'assets/logo.png',
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
    final TextEditingController batchNameController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Batch'),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.17,
            child: Column(
              children: [
                TextField(
                  controller: batchNameController,
                  decoration: const InputDecoration(hintText: 'Enter batch name'),
                ),
                TextField(
                  controller: batchController,
                  decoration: const InputDecoration(hintText: 'Enter batch'),
                ),
              ],
            ),
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
                    'name': batchNameController.text,
                    'batch': batchController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                    'userCount': 0,
                    'picture': 'assets/logo.png'
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

  Future<void> _sendMessage(String departmentId) async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageData = {
        'content': messageController.text,
        'senderId': user?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'departmentId': departmentId,
      };

      await FirebaseFirestore.instance.collection('departments').doc(departmentId).collection('messages')
          .add(messageData);
      messageController.clear();
    }
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

          String role = userData['role'];
          print("User role: $role"); // Debugging print to check user role

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
      stream: FirebaseFirestore.instance.collection('departments').where('hodId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You have not created any department yet.',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  AuthButton(
                    onPressed: () {
                      _createDepartment(context);
                    },
                    icon: Icons.add,
                    text: 'Create Department',
                    textColor: Colors.white,
                    color: Colors.lightGreen,
                    borderColor: Colors.transparent,
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
          );
        }

        var department = snapshot.data!.docs.first;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('departments')
              .doc(department.id)
              .collection('batches')
              .snapshots(),
          builder: (context, batchSnapshot) {
            if (batchSnapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (batchSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Batch> batches = batchSnapshot.data?.docs.map((doc) {
              return Batch(
                batch: doc['batch'] ?? '',
                createdAt: (doc['createdAt'] as Timestamp).toDate(),
                name: doc['name'] ?? '',
                userCount: doc['userCount'] ?? 0,
                picture: doc['picture'],
              );
            }).toList() ?? [];

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: GestureDetector(
                    onTap: (){
                      Get.to(DepartmentDetailScreen(departmentId: department.id));
                    },
                    child: DepartmentView(
                      department: Department(
                        name: department['name'] ?? '',
                        userCount: department['userCount'] ?? 0,
                        code: department['code'] ?? '',
                        creationDate: department['creationDate'] != null
                            ? (department['creationDate'] as Timestamp).toDate().toString()
                            : '',
                        picture: department['picture'] ?? '',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Batches',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (batches.isEmpty)
                  const Center(
                    child: Text(
                      'No batches created for this department.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  BatchPageView(batches: batches),
                const SizedBox(height: 10),
                AuthButton(
                  onPressed: () => _createBatch(context, department.id),
                  icon: Icons.add,
                  text: 'Create Batch',
                  textColor: Colors.white,
                  color: Colors.lightGreen,
                  borderColor: Colors.transparent,
                  iconColor: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: messageController,
                        decoration: const InputDecoration(labelText: 'Enter your message'),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () => _sendMessage(department.id),
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                ),
                // Chat view for all users
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('departments').doc(department.id).collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, messageSnapshot) {
                    if (messageSnapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }
                    if (messageSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: messageSnapshot.data!.docs.map((DocumentSnapshot document) {
                        var messageData = document.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(messageData['content']),
                          subtitle: Text('Sent by ${messageData['senderId']} at ${messageData['timestamp']?.toDate() ?? ''}'),
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

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('departments')
              .where('code', isEqualTo: departmentCode).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data?.docs.isEmpty ?? true) {
              return const Center(child: Text('No department found'));
            }

            var department = snapshot.data!.docs.first;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                DepartmentView(
                  department: Department(
                    name: department['name'],
                    userCount: department['userCount'],
                    code: department['code'],
                    creationDate: (department['creationDate'] as Timestamp).toDate().toString(),
                    picture: department['picture'],
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('messages')
                      .where('departmentId', isEqualTo: department.id)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, messageSnapshot) {
                    if (messageSnapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }
                    if (messageSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: messageSnapshot.data!.docs.map((DocumentSnapshot document) {
                        var messageData = document.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(messageData['content']),
                          subtitle: Text('Sent by ${messageData['senderId']} at ${messageData['timestamp']?.toDate() ?? ''}'),
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

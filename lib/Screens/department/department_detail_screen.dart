import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification_app/Screens/user/user_detail_screen.dart';

import '../../Components/auth_button.dart';
import '../../Components/header_simple.dart';

class DepartmentDetailScreen extends StatelessWidget {
  final String departmentId;

  DepartmentDetailScreen({required this.departmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('departments').doc(departmentId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var department = snapshot.data!;

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      color: Colors.lightGreen,
                      child: ClipRRect(
                        child: department['picture'] != null
                            ? Image.asset(
                          department['picture'],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.broken_image, size: 300),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(),
                  ),
                ],
              ),
              Positioned(
                top: 40,
                left: 20,
                right: 20,
                child: HeaderSimple(
                  leftIcon: const Icon(Icons.arrow_back, color: Colors.black),
                  onLeftIconPressed: () {
                    Navigator.pop(context);
                  },
                  title: 'Detail',
                  rightIcon: const Icon(Icons.filter_list, color: Colors.black),
                  onRightIconPressed: () {},
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.lightGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    department['name'] ?? 'Department Name',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance.collection('users').doc(department['hodId']).snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> hodSnapshot) {
                                      if (hodSnapshot.hasError) {
                                        return const Text('HOD: Error loading HOD information');
                                      }
                                      if (hodSnapshot.connectionState == ConnectionState.waiting) {
                                        return const Text('HOD: Loading...');
                                      }
                                      var hod = hodSnapshot.data!;
                                      return Column(
                                        children: [
                                          const Text(
                                            'Head of Department',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Text(
                                            '${hod['displayName'] ?? 'N/A'}',
                                            style: const TextStyle(
                                                fontSize: 20, fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Created on: ${department['creationDate']?.toDate().toLocal().toString().split(' ')[0] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('departments')
                                .doc(department.id)
                                .collection('batches')
                                .snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> batchSnapshot) {
                              if (batchSnapshot.hasError) {
                                return const Center(child: Text('Something went wrong'));
                              }

                              if (batchSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              var batches = batchSnapshot.data!.docs;

                              return Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.lightGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Batches',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${batches.length}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    ListView(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      children: batches.map((batchDoc) {
                                        var batch = batchDoc.data() as Map<String, dynamic>;
                                        return ListTile(
                                          title: Text(batch['name'] ?? 'Batch Name', style: const TextStyle()),
                                          subtitle: Text('${batch['userCount'] ?? 0} students', style: const TextStyle()),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('departmentCode', isEqualTo: department['code'])
                                .snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
                              if (userSnapshot.hasError) {
                                return const Center(child: Text('Something went wrong'));
                              }

                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              var users = userSnapshot.data!.docs;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.group),
                                    title: Text('${users.length} members', style: const TextStyle()),
                                    trailing: const Icon(Icons.search),
                                  ),
                                  const Divider(),
                                  ListView(
                                    shrinkWrap: true, // Added to avoid infinite height error
                                    physics: const NeverScrollableScrollPhysics(), // Disable inner scroll
                                    children: users.map((userDoc) {
                                      var user = userDoc.data() as Map<String, dynamic>;
                                      return ListTile(
                                        onTap: () {
                                          Get.to(() => UserDetailScreen(userId: userDoc.id));
                                        },
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(user['picture'] ?? 'https://via.placeholder.com/150'),
                                        ),
                                        title: Text(user['displayName'] ?? 'User Name', style: const TextStyle()),
                                        subtitle: Text(user['email'] ?? 'user@example.com', style: const TextStyle()),
                                      );
                                    }).toList(),
                                  ),
                                  AuthButton(
                                    onPressed: () {
                                      _deleteDepartment(context, departmentId, userSnapshot);
                                    },
                                    icon: Icons.delete,
                                    text: 'Delete Department',
                                    textColor: Colors.white,
                                    color: Colors.red,
                                    borderColor: Colors.transparent,
                                    iconColor: Colors.white,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteDepartment(BuildContext context, String departmentId, AsyncSnapshot<QuerySnapshot> userSnapshot) async {
    DocumentSnapshot departmentDoc = await FirebaseFirestore.instance.collection('departments').doc(departmentId).get();
    final FirebaseAuth _auth = FirebaseAuth.instance;

    if (departmentDoc['hodId'] == _auth.currentUser!.uid) {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete this department?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        try {
          // Delete the department document
          await FirebaseFirestore.instance.collection('departments').doc(departmentId).delete();

          // Remove the departmentCode field from all users in this department
          List<Future<void>> updateOperations = [];

          userSnapshot.data!.docs.forEach((userDoc) {
            updateOperations.add(userDoc.reference.update({'departmentCode': FieldValue.delete()}));
          });

          await Future.wait(updateOperations);

          Get.snackbar('Success', 'Department deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          Navigator.of(context).pop();
        } catch (e) {
          Get.snackbar('Error', 'Failed to delete department: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } else {
      Get.snackbar('Error', 'You are not authorized to delete this department',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

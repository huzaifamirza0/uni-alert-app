import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:notification_app/Screens/department/admin_office_view.dart';
import 'package:notification_app/Screens/department/department_detail_screen.dart';
import 'package:notification_app/Screens/department/join_department_screen.dart';
import 'package:notification_app/Screens/department/search_office.dart';
import 'package:notification_app/Screens/department/widgets/batch_page_view.dart';
import 'package:notification_app/Screens/chat_rooms/department_chatRoom.dart';
import '../chat_rooms/admin_office_chat.dart';
import 'admin_office_detail.dart';
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
  String selectedBatchId = '';
  final TextEditingController messageController = TextEditingController();
  final TextEditingController departmentCodeController = TextEditingController();
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
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                      'departmentCode': departmentCode,
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

  Future<void> _createAdminOffice(BuildContext context) async {
    final TextEditingController officeNameController = TextEditingController();
    final TextEditingController officeDescriptionController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Admin Office'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: officeNameController,
                decoration: const InputDecoration(hintText: 'Enter office name'),
              ),
              TextField(
                controller: officeDescriptionController,
                decoration: const InputDecoration(hintText: 'Enter office description'),
              ),
            ],
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
                if (officeNameController.text.isNotEmpty &&
                    officeDescriptionController.text.isNotEmpty) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance.collection('adminOffices').add({
                      'picture': 'assets/splash/slide2.jpg',
                      'name': officeNameController.text,
                      'description': officeDescriptionController.text,
                      'creationDate': Timestamp.now(),
                      'userCount': 0,
                      'adminId': user.uid,
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

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: true,
        title: const Text('My Department', style: TextStyle(color: Colors.green),),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => SubscribeScreen()));
          }, icon: const Icon(Icons.search_rounded))
        ],
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
            return _buildHODView(context, userId, role);
          } else if (role == 'student') {
            return _buildStudentView(context, userId, role);
          } else if (role == 'faculty') {
            return _buildFacultyView(context, userId, role);
          } else if (role == 'adminOfficer') {
            return _buildAdminOfficeView(context, userId, role);
          } else {
            return const Center(child: Text('Invalid user role'));
          }
        },
      ),
    );
  }

  Widget _buildHODView(BuildContext context, String userId, String role) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                batchId: doc.id,
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
                  BatchPageView(batches: batches, departmentId: '', userRole: role,),
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

                // Chat view for all users
                const SizedBox(height: 20,),
                AuthButton(
                  onPressed: () => Get.to(DepartmentChatRoom(departmentId: department.id,
                      departmentName: department['name'], userRole: role,)),
                  icon: Icons.chat,
                  text: 'Open Chat',
                  textColor: Colors.white,
                  color: Colors.lightGreen,
                  borderColor: Colors.transparent,
                  iconColor: Colors.white,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStudentView(BuildContext context, String userId, String role) {
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

        String departmentCode = userData['departmentCode'] ?? '';

        if (departmentCode.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You have not joined any department yet.',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  AuthButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => JoinDepartmentScreen()));
                    },
                    text: 'Join Department',
                    color: Colors.lightGreen,
                    icon: Icons.add,
                    borderColor: Colors.transparent,
                    textColor: Colors.white,
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('departments').where('code', isEqualTo: departmentCode).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data?.docs.isEmpty ?? true) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No department found with the provided code.'),
                    const SizedBox(height: 20),
                    AuthButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => JoinDepartmentScreen()));
                      },
                      text: 'Join Department',
                      color: Colors.lightGreen,
                      icon: Icons.add,
                      borderColor: Colors.transparent,
                      textColor: Colors.white,
                      iconColor: Colors.white,
                    ),
                  ],
                ),
              );
            }

            var departmentData = snapshot.data?.docs.first.data() as Map<String, dynamic>;
            String departmentId = snapshot.data?.docs.first.id ?? '';

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                GestureDetector(
                  onTap: (){
                    Get.to(() => DepartmentDetailScreen(departmentId: departmentId));
                  },
                  child: DepartmentView(
                    department: Department(
                      name: departmentData['name'] ?? '',
                      userCount: departmentData['userCount'] ?? 0,
                      code: departmentData['code'] ?? '',
                      creationDate: departmentData['creationDate'] != null
                          ? (departmentData['creationDate'] as Timestamp).toDate().toString()
                          : '',
                      picture: departmentData['picture'] ?? '',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('departments')
                      .doc(departmentId)
                      .collection('batches')
                      .where('userIds', arrayContains: userId)
                      .snapshots(),
                  builder: (context, batchSnapshot) {
                    if (!batchSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (batchSnapshot.hasError) {
                      return const Center(child: Text('Error loading batch data'));
                    }

                    if (batchSnapshot.data?.docs.isEmpty ?? true) {
                      return const Center(child: Text('No batches found'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: batchSnapshot.data?.docs.length,
                      itemBuilder: (context, batchIndex) {
                        var batch = batchSnapshot.data?.docs[batchIndex];
                        Map<String, dynamic>? batchData = batch?.data() as Map<String, dynamic>?;

                        if (batchData == null) {
                          return const Center(child: Text('Batch data is null'));
                        }

                        List<Batch> batches = batchSnapshot.data?.docs.map((doc) {
                          return Batch(
                            batchId: doc.id,
                            batch: doc['batch'] ?? '',
                            createdAt: (doc['createdAt'] as Timestamp).toDate(),
                            name: doc['name'] ?? '',
                            userCount: doc['userCount'] ?? 0,
                            picture: doc['picture'],
                          );
                        }).toList() ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              BatchPageView(batches: batches, departmentId: departmentId, userRole: role,),
                            const SizedBox(height: 10),
                            AuthButton(

                              onPressed: () => Get.to(DepartmentChatRoom(departmentId: departmentId,
                                  departmentName: departmentData['name'], userRole: role,)),
                              icon: Icons.chat,
                              text: 'Open Chat',
                              textColor: Colors.white,
                              color: Colors.lightGreen,
                              borderColor: Colors.transparent,
                              iconColor: Colors.white,
                            ),
                          ],
                        );
                      },
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

  Widget _buildFacultyView(BuildContext context, String userId, String role) {
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

        var departmentCodesRaw = userData['departmentCode'];
        List<String> departmentCodes;
        if (departmentCodesRaw is String) {
          departmentCodes = [departmentCodesRaw];
        } else if (departmentCodesRaw is List) {
          departmentCodes = List<String>.from(departmentCodesRaw);
        } else {
          return const Center(child: Text('Invalid data format for departmentCode'));
        }

        return ListView.builder(
          itemCount: departmentCodes.length,
          itemBuilder: (context, index) {
            String departmentCode = departmentCodes[index];

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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No department found with the provided code.'),
                        const SizedBox(height: 20),
                        AuthButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => JoinDepartmentScreen()));
                          },
                          text: 'Join Department',
                          color: Colors.lightGreen,
                          icon: Icons.add,
                          borderColor: Colors.transparent,
                          textColor: Colors.white,
                          iconColor: Colors.white,
                        ),
                      ],
                    ),
                  );
                }

                var department = snapshot.data!.docs.first;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        stream: FirebaseFirestore.instance
                            .collection('departments')
                            .doc(department.id)
                            .collection('batches')
                            .where('userIds', arrayContains: user!.uid)
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
                              batchId: doc.id,
                              batch: doc['batch'] ?? '',
                              createdAt: (doc['createdAt'] as Timestamp).toDate(),
                              name: doc['name'] ?? '',
                              userCount: doc['userCount'] ?? 0,
                              picture: doc['picture'],
                            );
                          }).toList() ?? [];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                BatchPageView(batches: batches, userRole: role, departmentId: department.id,),
                              const SizedBox(height: 10),
                              AuthButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => JoinDepartmentScreen()));
                                },
                                text: 'Join Department',
                                color: Colors.lightGreen,
                                icon: Icons.add,
                                borderColor: Colors.transparent,
                                textColor: Colors.white,
                                iconColor: Colors.white,
                              ),
                              const SizedBox(height: 16,),
                              AuthButton(
                                onPressed: () => Get.to(DepartmentChatRoom(departmentId: department.id,
                                    departmentName: department['name'], userRole: role,)),
                                icon: Icons.chat,
                                text: 'Open Chat',
                                textColor: Colors.white,
                                color: Colors.lightGreen,
                                borderColor: Colors.transparent,
                                iconColor: Colors.white,
                              ),
                            ],
                          );
                        },
                      ),
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

  Widget _buildAdminOfficeView(BuildContext context, String userId, String role) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('adminOffices').where('adminId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You have not created an admin office yet.',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _createAdminOffice(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.lightGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Create Admin Office'),
                  ),
                ],
              ),
            ),
          );
        }

        var adminOfficeData = snapshot.data!.docs.first;

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminOfficeDetailScreen(adminOfficeId: adminOfficeData.id),
                      ),
                    );
                  },
                  child: AdminOfficeView(
                    adminOffice: AdminOffice(
                      name: adminOfficeData['name'] ?? '',
                      userCount: adminOfficeData['userCount'] ?? 0,
                      description: adminOfficeData['description'] ?? '',
                      creationDate: adminOfficeData['creationDate'] != null
                          ? (adminOfficeData['creationDate'] as Timestamp).toDate().toString()
                          : '',
                      picture: adminOfficeData['picture'] ?? '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              AuthButton(
                onPressed: () {
                  Get.to(() => AdminOfficeChatRoom(
                        adminOfficeId: adminOfficeData.id,
                        adminOfficeName: adminOfficeData['name'] ?? 'Chat Room',
                      ),
                    );
                },
                text: 'Go to Chat Room',
                icon: Icons.chat,
                color: Colors.lightGreen,
                borderColor: Colors.transparent,
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }

}

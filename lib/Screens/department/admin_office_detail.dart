import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:notification_app/Screens/user/user_detail_screen.dart';
import '../../Components/header_simple.dart';

class AdminOfficeDetailScreen extends StatelessWidget {
  final String adminOfficeId;

  AdminOfficeDetailScreen({required this.adminOfficeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('adminOffices').doc(adminOfficeId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var adminOffice = snapshot.data!;

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
                        child: adminOffice['picture'] != null
                            ? Image.asset(
                          adminOffice['picture'],
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
                            child: Column(
                              children: [
                                Text(
                                  adminOffice['name'] ?? 'Admin Office Name',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(adminOffice['adminId'])
                                      .snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> adminSnapshot) {
                                    if (adminSnapshot.hasError) {
                                      return const Text('Admin: Error loading Admin information');
                                    }
                                    if (adminSnapshot.connectionState == ConnectionState.waiting) {
                                      return const Text('Admin: Loading...');
                                    }
                                    var admin = adminSnapshot.data!;
                                    return Text(
                                      'Admin: ${admin['name'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Created on: ${adminOffice['creationDate']?.toDate().toLocal().toString().split(' ')[0] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('subscribedAdminOffices', arrayContains: adminOfficeId)
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
                                        onTap: (){
                                          Get.to(() => UserDetailScreen(userId: userDoc.id));
                                        },
                                        leading: CircleAvatar(
                                          backgroundImage: user['picture'] != null
                                              ? NetworkImage(user['picture'])
                                              : null,
                                        ),
                                        title: Text(user['name'] ?? 'User Name', style: const TextStyle()),
                                        subtitle: Text(user['email'] ?? 'user@example.com', style: const TextStyle()),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
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
}

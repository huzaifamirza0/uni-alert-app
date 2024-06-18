import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Profile/model/user.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;

  UserDetailScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!;
          var userType = userData['role'];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(userData['picture'] ?? 'https://via.placeholder.com/150'),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      userData['name'] ?? 'N/A',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userData['email'] ?? 'N/A',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Divider(height: 32.0),
                  ],
                ),
              ),
              ListTile(
                title: Text('Role: ${userData['role'] ?? 'N/A'}'),
              ),
              const Divider(),
              _buildUserDetailsByType(userType, userData),

            ],
          );
        },
      ),
    );
  }

  Widget _buildUserDetailsByType(String userType, DocumentSnapshot userData) {
    switch (userType) {
      case 'student':
        return _buildStudentDetails(userData);
      case 'faculty':
        return _buildFacultyDetails(userData);
      case 'hod':
        return _buildHodDetails(userData);
      case 'adminOfficer':
        return _buildAdminOfficerDetails(userData);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStudentDetails(DocumentSnapshot userData) {
    String departmentCode = userData['departmentCode'] ?? 'N/A';
    String batchId = userData['batchId'] ?? 'N/A';

    // Casting data to Map<String, dynamic>
    Map<String, dynamic>? userDataMap = userData.data() as Map<String, dynamic>?;

    List<String>? subscribedAdminOffices;
    if (userDataMap != null && userDataMap.containsKey('subscribedAdminOffices')) {
      subscribedAdminOffices = List<String>.from(userDataMap['subscribedAdminOffices']);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('departments')
              .where('code', isEqualTo: departmentCode)
              .snapshots(),
          builder: (context, departmentSnapshot) {
            if (!departmentSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (departmentSnapshot.hasError) {
              return const Center(child: Text('Error loading department data'));
            }

            if (departmentSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No department found'));
            }

            var departmentDoc = departmentSnapshot.data!.docs.first;
            var departmentData = departmentDoc.data() as Map<String, dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.lightGreen.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text('${departmentData['name'] ?? 'N/A'}'),
                    subtitle: Text('${departmentData['userCount'] ?? 'N/A'}'),
                  ),
                ),
                const Divider(),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('departments')
                      .doc(departmentDoc.id)
                      .collection('batches')
                      .doc(batchId)
                      .snapshots(),
                  builder: (context, batchSnapshot) {
                    if (!batchSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (batchSnapshot.hasError) {
                      return const Center(child: Text('Error loading batch data'));
                    }

                    var batchData = batchSnapshot.data?.data() as Map<String, dynamic>?;
                    if (batchData == null) {
                      return const Center(child: Text('Batch data is null'));
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.lightGreen.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text('Batch: ${batchData['batch'] ?? 'N/A'}'),
                        subtitle: Text('${batchData['name'] ?? 'N/A'}'),
                      ),
                    );
                  },
                ),
                const Divider(),
              ],
            );
          },
        ),
        if (subscribedAdminOffices == null || subscribedAdminOffices.isEmpty)
          const Text('No office subscribed'),
        if (subscribedAdminOffices != null)
          ...subscribedAdminOffices.map((officeId) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('adminOffices').doc(officeId).get(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                var officeData = snapshot.data?.data() as Map<String, dynamic>?;
                if (officeData == null) {
                  return const Text('Office data is null');
                }

                String shortDescription = officeData['description'] ?? 'No description available';
                if (shortDescription.length > 40) {
                  shortDescription = '${shortDescription.substring(0, 40)}...';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.lightGreen.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          officeData['name'] ?? 'Admin Office',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(shortDescription),
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
      ],
    );
  }



  Widget _buildFacultyDetails(DocumentSnapshot userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text('Department: ${userData['department'] ?? 'N/A'}'),
        ),
        const Divider(),
        ListTile(
          title: Text('Office Joined: ${userData['joinedOffice'] ?? 'N/A'}'),
        ),
      ],
    );
  }

  Widget _buildHodDetails(DocumentSnapshot userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text('Department: ${userData['department'] ?? 'N/A'}'),
        ),
        const Divider(),
        ListTile(
          title: Text('Batch Created: ${userData['batchCreated'] ?? 'N/A'}'),
        ),
        const Divider(),
        ListTile(
          title: Text('Office Joined: ${userData['joinedOffice'] ?? 'N/A'}'),
        ),
      ],
    );
  }

  Widget _buildAdminOfficerDetails(DocumentSnapshot userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        userData['subscribedAdminOffices'].length,
            (index) {
          String officeId = userData['subscribedAdminOffices'][index];
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('adminOffices').doc(officeId).get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              var officeData = snapshot.data!.data() as Map<String, dynamic>;
              String shortDescription =
                  officeData['description'] ?? 'No description available';
              if (shortDescription.length > 40) {
                shortDescription =
                '${shortDescription.substring(0, 40)}...';
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        officeData['name'] ?? 'Admin Office',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(shortDescription),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget buildAbout(User user) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          user.about??'',
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
      ],
    ),
  );
}

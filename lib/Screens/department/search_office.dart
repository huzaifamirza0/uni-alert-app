import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SubscribeScreen extends StatefulWidget {
  @override
  _SubscribeScreenState createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _allAdminOffices = [];
  List<DocumentSnapshot> _filteredAdminOffices = [];
  List<DocumentSnapshot> _allDepartments = [];
  List<DocumentSnapshot> _filteredDepartments = [];
  String _searchText = "";
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot? myOffice;
  bool isAdminOfficer = false;
  String? myOfficeId;
  List<String> subscribedAdminOffices = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchUserData();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
        _filterData();
      });
    });
  }

  void _fetchData() async {
    // Fetch all admin offices
    QuerySnapshot adminOfficeSnapshot =
    await FirebaseFirestore.instance.collection('adminOffices').get();
    setState(() {
      _allAdminOffices = adminOfficeSnapshot.docs;
      _filteredAdminOffices = _allAdminOffices;
    });

    // Fetch all departments
    QuerySnapshot departmentSnapshot =
    await FirebaseFirestore.instance.collection('departments').get();
    setState(() {
      _allDepartments = departmentSnapshot.docs;
      _filteredDepartments = _allDepartments;
    });
  }

  void _fetchUserData() async {
    // Fetch current user data
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    setState(() {
      var userData = userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null) {
        isAdminOfficer = userData['role'] == 'adminOfficer';

        // Initialize subscribedAdminOffices if it doesn't exist
        if (userData.containsKey('subscribedAdminOffices')) {
          subscribedAdminOffices =
          List<String>.from(userData['subscribedAdminOffices']);
        } else {
          subscribedAdminOffices = [];
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .update({'subscribedAdminOffices': []});
        }

        if (isAdminOfficer) {
          // Fetch all admin offices
          FirebaseFirestore.instance
              .collection('adminOffices')
              .get()
              .then((querySnapshot) {
            querySnapshot.docs.forEach((doc) {
              // Check if the office belongs to the current user
              if (doc['adminId'] == currentUserId) {
                setState(() {
                  myOffice = doc;
                  myOfficeId = doc.id;
                });
                return; // Exit forEach loop once my office is found
              }
            });
          }).catchError((error) {
            print("Error fetching admin offices: $error");
          });
        }
      }
    });
  }

  void _filterData() {
    if (_searchText.isEmpty) {
      _filteredAdminOffices = _allAdminOffices;
      _filteredDepartments = _allDepartments;
    } else {
      _filteredAdminOffices = _allAdminOffices
          .where((doc) =>
      (doc['name'] ?? '')
          .toString()
          .toLowerCase()
          .contains(_searchText.toLowerCase()) ||
          (doc.data().toString().toLowerCase().contains(_searchText.toLowerCase())))
          .toList();

      _filteredDepartments = _allDepartments
          .where((doc) =>
      (doc['name'] ?? '')
          .toString()
          .toLowerCase()
          .contains(_searchText.toLowerCase()) ||
          (doc.data().toString().toLowerCase().contains(_searchText.toLowerCase())))
          .toList();
    }
  }

  void _toggleSubscribe(DocumentSnapshot adminOffice) async {
    DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(currentUserId);

    // Check if user is already subscribed
    if (subscribedAdminOffices.contains(adminOffice.id)) {
      // Unsubscribe user
      await userRef.update({
        'subscribedAdminOffices': FieldValue.arrayRemove([adminOffice.id])
      });
      setState(() {
        subscribedAdminOffices.remove(adminOffice.id);
      });
    } else {
      // Subscribe user
      await userRef.update({
        'subscribedAdminOffices': FieldValue.arrayUnion([adminOffice.id])
      });
      setState(() {
        subscribedAdminOffices.add(adminOffice.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Offices & Departments'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Admin Offices or Departments',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18)
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Admin Offices',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._filteredAdminOffices.map((doc) {
                  bool isMyOffice = isAdminOfficer && myOfficeId == doc.id;
                  bool isSubscribed = subscribedAdminOffices.contains(doc.id);
                  String shortDescription =
                      doc['description'] ?? 'No description available';
                  if (shortDescription.length > 40) {
                    shortDescription =
                    '${shortDescription.substring(0, 40)}...';
                  }
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(12.0),
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
                      title: Text(doc['name'] ?? 'Admin Office', style: const TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Text(shortDescription),
                      trailing: isMyOffice
                          ? const Text(
                        'My Office',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      )
                          : ElevatedButton(
                        onPressed: () {
                          _toggleSubscribe(doc);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: isSubscribed ? Colors.black : Colors.white,
                          backgroundColor: isSubscribed ? Colors.grey[300] : Colors.red,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.0),
                          ),
                          elevation: isSubscribed ? 0 : 5,
                          side: BorderSide(
                            color: isSubscribed ? Colors.grey : Colors.red,
                          ),
                        ),
                        child: Text(isSubscribed ? 'Subscribed' : 'Subscribe'),
                      ),
                    ),
                  );
                }).toList(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Departments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._filteredDepartments.map((doc) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(12.0),
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
                      title: Text(doc['name'] ?? 'Department'),
                      subtitle: Text(doc['userCount'].toString() ?? ''),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

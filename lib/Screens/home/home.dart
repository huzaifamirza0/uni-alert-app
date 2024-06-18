import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Services/logOutDialog.dart';
import '../Profile/page/profile_page.dart';
import '../Profile/widget/drawer.dart';
import '../department/search_office.dart';
import '../messaging/department_message.dart'; // Import the new widget

class HomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final appBarTitleFontSize = mediaQuery.size.width > 600 ? 28.0 : 24.0;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 76,
        toolbarOpacity: 0.7,
        backgroundColor: Colors.lightGreen.shade300,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white,),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        title: Text(
          'UniAlert', style: TextStyle(color: Colors.white, fontSize: appBarTitleFontSize,),),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => SubscribeScreen()));
          }, icon: const Icon(Icons.search_rounded, color: Colors.white,)),

          const SizedBox(width: 12),
          GestureDetector(
              onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              },
              child: const Icon(Icons.person, color: Colors.white,)),
          const SizedBox(width: 10),
        ],
      ),
      drawer: CustomDrawer(profileImageUrl: 'https://www.shareicon.net/data/512x512/2016/09/15/829459_man_512x512.png',
          name: 'Name', email: 'name@gmail.com',
          onLogout: (){
            showDeleteUserDialog(context);
          }),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Public Messages'),
            _buildHorizontalSlider(context, _fetchMessages('public')),
            const SizedBox(height: 16.0),
            _buildSectionTitle(context, 'Department Messages'),
            _buildDepartmentMessages(context),
            const SizedBox(height: 16.0),
            _buildSectionTitle(context, 'Office Messages'),
            _buildGrid(context, _fetchMessages('office')),
            const SizedBox(height: 16.0),
            _buildSectionTitle(context, 'Events and Alerts'),
            _buildHorizontalSliderWithImages(context, _fetchMessages('events')),
            const SizedBox(height: 16.0),
            _buildSectionTitle(context, 'Personal Messages'),
            _buildVerticalList(context, _fetchPersonalMessages()),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headline6,
    );
  }

  Widget _buildHorizontalSlider(BuildContext context, Stream<QuerySnapshot> messageStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var messages = snapshot.data!.docs;
        return Container(
          height: 150.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              return Container(
                width: 300.0,
                margin: const EdgeInsets.only(right: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    Text(message['content']),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVerticalList(BuildContext context, Stream<QuerySnapshot> messageStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var messages = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Text(message['content']),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, Stream<QuerySnapshot> messageStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var messages = snapshot.data!.docs;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Text(message['content']),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHorizontalSliderWithImages(BuildContext context, Stream<QuerySnapshot> messageStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var messages = snapshot.data!.docs;
        return Container(
          height: 200.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              return Container(
                width: 250.0,
                margin: const EdgeInsets.only(right: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      message['imageUrl'],
                      fit: BoxFit.cover,
                      height: 100.0,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 8.0),
                    Text(message['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    Text(message['content']),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDepartmentMessages(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_auth.currentUser?.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        if (userData == null || userData['departmentCode'] == null) {
          return const Center(child: Text('No department messages available'));
        }

        String departmentCode = userData['departmentCode'];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('departments')
              .where('code', isEqualTo: departmentCode).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data?.docs.isEmpty ?? true) {
              return const Center(child: Text('No department messages available'));
            }

            var department = snapshot.data!.docs.first;
            return DepartmentMessages(departmentId: department.id);
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _fetchMessages(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  Stream<QuerySnapshot> _fetchPersonalMessages() {
    User? user = _auth.currentUser;
    return _firestore
        .collection('personal_messages')
        .where('recipientId', isEqualTo: user?.uid)
        .snapshots();
  }
}

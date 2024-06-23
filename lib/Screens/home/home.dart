import 'package:chat_message_timestamp/chat_message_timestamp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Services/logOutDialog.dart';
import '../Profile/page/profile_page.dart';
import '../messaging/admin_office_message.dart';
import '../messaging/event/event_dialog.dart';
import '../messaging/event/event_model.dart';
import '../messaging/event/event_widget.dart';
import 'drawer.dart';
import '../department/search_office.dart';
import '../messaging/department_message.dart';

class HomePage extends StatelessWidget {
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
          }, userRole: 'hod',),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Public Messages'),
            _buildHorizontalSlider(context, _fetchMessages('messages')),
            const SizedBox(height: 16.0),
            _buildSectionTitle(context, 'Department Messages'),
            _buildDepartmentMessages(context),
            const SizedBox(height: 16.0),
            _buildSectionTitle(context, 'Office Messages'),
            SubscribedMessagesGrid(),
            const SizedBox(height: 16.0),
            _buildSectionTitle(context, 'Events and Alerts'),
            _buildHorizontalSliderEvents(context, _fetchMessages('events')),
            const SizedBox(height: 92.0),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
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
        return SizedBox(
          height: 170.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: _messageItem(context, message),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHorizontalSliderEvents(BuildContext context, Stream<QuerySnapshot> eventStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: eventStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var events = snapshot.data!.docs.map((doc) => Event.fromDocumentSnapshot(doc)).toList();
        return SizedBox(
          height: 200.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            itemBuilder: (context, index) {
              var event = events[index];
              return EventCard(
                event: event,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return EventDetailDialog(event: event);
                  },
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
    return FirebaseFirestore.instance.collection(collection).snapshots();
  }


  Widget _messageItem(BuildContext context, DocumentSnapshot message) {
    Map<String, dynamic> map = message.data() as Map<String, dynamic>;
    Timestamp? timestamp = map['timestamp'] as Timestamp?;
    String time = timestamp != null ? _formatTime(timestamp.toDate()) : 'Unknown';
    String senderName = map['sender'] ?? 'Unknown sender';
    String messageContent = map['message'] ?? '';

    return GestureDetector(
      onLongPress: (){
        _showMessageDialog(context, senderName, messageContent, time);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.68,
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
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
        child: Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                senderName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (map['message'] != null && map['message'].isNotEmpty)
                GestureDetector(
                  onTap: () => _showMessageDialog(context, senderName, map['message'], time),
                  child: TimestampedChatMessage(
                    sendingStatusIcon: const Icon(Icons.check, color: Colors.lightGreen,),
                    text: _truncateMessage(map['message']),
                    sentAt: time,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    sentAtStyle: const TextStyle(color: Colors.black, fontSize: 12),
                    maxLines: 3,
                    delimiter: '\u2026',
                    viewMoreText: 'showMore',
                    showMoreTextStyle: const TextStyle(color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    String period = time.hour < 12 ? 'AM' : 'PM';
    int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _truncateMessage(String message, {int maxLength = 66}) {
    if (message.length <= maxLength) {
      return message;
    } else {
      return '${message.substring(0, maxLength)}... see more';
    }
  }

  void _showMessageDialog(BuildContext context, String senderName, String messageContent, String time) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(senderName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sent at: $time', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              Text(messageContent),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../chat_rooms/one_to_one.dart';

class UserSearchScreen extends StatefulWidget {
  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> _allUsers = [];
  List<DocumentSnapshot> _filteredUsers = [];
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
        _filterUsers();
      });
    });
  }

  void _fetchUsers() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _allUsers = userSnapshot.docs;
      _filteredUsers = _allUsers;
    });
  }

  void _filterUsers() {
    if (_searchText.isEmpty) {
      _filteredUsers = _allUsers;
    } else {
      _filteredUsers = _allUsers
          .where((doc) => (doc['email'] ?? '').toString().toLowerCase().contains(_searchText.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: _filteredUsers.map((doc) {
                String id = doc['uid'] ?? 'no id';
                String email = doc['email'] ?? 'No user found';
                String name = doc['displayName'] ?? 'No user found';
                return ListTile(
                  onTap: () {
                    createChatRoomAndNavigate(id, email, name);
                  },
                  title: Text(name),
                  subtitle: Text(email),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void createChatRoomAndNavigate(String id, String userEmail, String name) async {
    // Check if chatroom already exists
    QuerySnapshot chatRoomSnapshot = await _firestore
        .collection('chatroom')
        .where('users', arrayContains: _auth.currentUser!.email)
        .get();

    String chatRoomId = '';
    Map<String, dynamic> userMap = {};

    // Check if chat room with the same user already exists
    bool chatRoomExists = false;
    for (var doc in chatRoomSnapshot.docs) {
      dynamic users = doc.get('users');
      if (users != null && users.contains(userEmail)) {
        chatRoomExists = true;
        chatRoomId = doc.id;
        userMap = {
          'id': doc.get('chatRoomId') ?? '',
        };
        break;
      }
    }

    if (!chatRoomExists) {
      // Create new chat room
      chatRoomId = _firestore.collection('chatroom').doc().id;
      userMap = {
        'id': id,
        'name': name,
      };
      await _firestore.collection('chatroom').doc(chatRoomId).set({
        'users': [_auth.currentUser!.email, userEmail],
        'chatRoomId': chatRoomId,
        'name': name, // Optionally set the name if creating a new chat room
      });
    }

    // Navigate to chat room
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatRoom(
        userMap: userMap,
        chatRoomId: chatRoomId,
      ),
    ));
  }

}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'message_widgget.dart';
import 'package:path/path.dart' as path;

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatRoom({
    required this.userMap,
    required this.chatRoomId,
  });

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  late ScrollController _scrollController;
  TextEditingController messageController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String userStatus = '';
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onSendMessage(String? imageUrl, String? fileUrl, String? fileName) async {
    if (messageController.text.isNotEmpty ||
        imageUrl != null ||
        fileUrl != null) {
      Map<String, dynamic> messages = {
        'senderId': _auth.currentUser!.uid,
        'content': messageController.text,
        'imageUrl': imageUrl ?? '',
        'fileUrl': fileUrl ?? '',
        'fileName': fileName ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('chatroom').doc(widget.chatRoomId).collection('chats').add(messages);
      messageController.clear();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      print('Write something');
    }
  }

  Future<void> selectAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = path.basename(file.path);
        String fileExtension = path.extension(file.path).toLowerCase();
        String storagePath =
            'uploads/${DateTime.now().millisecondsSinceEpoch}$fileExtension';
        UploadTask task = _storage.ref(storagePath).putFile(file);

        TaskSnapshot snapshot = await task;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        onSendMessage(null, downloadUrl, fileName);
      }
    } catch (e) {
      print('File upload error: $e');
    }
  }

  Future<void> selectAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        UploadTask task = _storage.ref('uploads/$fileName').putFile(file);

        TaskSnapshot snapshot = await task;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        onSendMessage(downloadUrl, null, null);
      }
    } catch (e) {
      print('Image upload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userMap['name']),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('users').doc(widget.userMap['id']).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  if (userData.containsKey('status')) {
                    var status = userData['status'];
                    return Text(
                      status.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    );
                  }
                }
                return const Text(
                  'Status not available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              reverse: true,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chatroom')
                    .doc(widget.chatRoomId)
                    .collection('chats')
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                    });
                    return Column(
                      children: snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> map = document.data() as Map<String, dynamic>;
                        return MessageWidget(size: size, map: map);
                      }).toList(),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
          Container(
            height: size.height / 10,
            width: size.width,
            alignment: Alignment.center,
            child: SizedBox(
              height: size.height / 12,
              width: size.width / 1.1,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: selectAndUploadImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: selectAndUploadFile,
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => onSendMessage(null, null, null),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.lightGreen,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

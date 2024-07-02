import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageDialog extends StatefulWidget {
  @override
  _MessageDialogState createState() => _MessageDialogState();
}

class _MessageDialogState extends State<MessageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _typeController = TextEditingController(text: 'Public');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String>? _senderNameFuture;

  @override
  void initState() {
    super.initState();
    _senderNameFuture = _fetchSenderName();
  }

  Future<String> _fetchSenderName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userSnapshot['name'];
    }
    return 'Unknown';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _sendMessage(String? imageUrl, String? fileUrl, String? fileName) async {
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> messageData = {
        'senderId': _auth.currentUser!.uid,
        'content': _messageController.text,
        'timestamp': Timestamp.now(),
        'type': _typeController.text,
        'imageUrl': imageUrl ?? '',
        'fileUrl': fileUrl ?? '',
        'fileName': fileName ?? '',
      };

      await FirebaseFirestore.instance.collection('messages').add(messageData);
      Navigator.of(context).pop();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width * 0.8,
        child: FutureBuilder<String>(
          future: _senderNameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching sender name'));
            } else {
              final senderName = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Public Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Divider(thickness: 1.5,),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: senderName,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Your Name',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.green),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _typeController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Message Type',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.green),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.green),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a message';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                      ),
                      ElevatedButton(
                        onPressed: () => _sendMessage(null, null, null),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Send', style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math';

class ChatListPage extends StatelessWidget {
  final Random _random = Random();

  Color _getRandomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniAlert'),
        backgroundColor: Colors.lightGreen,
      ),
      body: ListView(
        children: [
          ChatListItem(
            profilePicText: '560',
            profilePicColor: _getRandomColor(),
            name: 'Ayesha Khan',
            message: 'I will call you later.',
            time: '10:30 AM',
          ),
          ChatListItem(
            profilePicText: '561',
            profilePicColor: _getRandomColor(),
            name: 'Ahmed Ali',
            message: 'Please check the document I sent you.',
            time: '9:15 AM',
          ),
          ChatListItem(
            profilePicText: '562',
            profilePicColor: _getRandomColor(),
            name: 'Fatima Sheikh',
            message: 'Meeting has been rescheduled to 3 PM.',
            time: '8:45 AM',
          ),
          ChatListItem(
            profilePicText: '563',
            profilePicColor: _getRandomColor(),
            name: 'Bilal Ahmad',
            message: 'Thanks for your help!',
            time: '7:20 AM',
          ),
          ChatListItem(
            profilePicText: '564',
            profilePicColor: _getRandomColor(),
            name: 'Hina Malik',
            message: 'Can you send me the notes?',
            time: '6:00 AM',
          ),
          ChatListItem(
            profilePicText: '565',
            profilePicColor: _getRandomColor(),
            name: 'Zainab Qureshi',
            message: 'Let’s meet at the cafe.',
            time: '5:30 AM',
          ),
          ChatListItem(
            profilePicText: '566',
            profilePicColor: _getRandomColor(),
            name: 'Usman Javed',
            message: 'I have submitted the report.',
            time: '4:50 AM',
          ),
        ],
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final String profilePicText;
  final Color profilePicColor;
  final String name;
  final String message;
  final String time;

  ChatListItem({
    required this.profilePicText,
    required this.profilePicColor,
    required this.name,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: profilePicColor,
        child: Text(
          profilePicText,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(name),
      subtitle: Text(message),
      trailing: Text(time),
      onTap: () {
        // Handle tap
      },
    );
  }
}

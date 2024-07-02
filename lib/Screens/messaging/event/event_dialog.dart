import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_model.dart';

class EventDetailDialog extends StatelessWidget {
  final Event event;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  EventDetailDialog({required this.event});

  String getCountdown(DateTime eventDate) {
    final now = DateTime.now().toLocal();
    final eventDateLocal = eventDate.toLocal();

    final nowDate = DateTime(now.year, now.month, now.day);
    final eventDateOnly = DateTime(eventDateLocal.year, eventDateLocal.month, eventDateLocal.day);

    final difference = eventDateOnly.difference(nowDate);

    if (difference.inDays > 1) {
      return '${difference.inDays} days to go';
    } else if (difference.inDays == 1) {
      return '1 day to go';
    } else if (difference.inDays == 0) {
      return 'Today is the event!';
    } else {
      return 'Event has passed';
    }
  }

  Future<void> _deleteEvent(BuildContext context) async {
    await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
    Navigator.of(context).pop(); // Close the detail dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Text(
        event.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: IntrinsicHeight(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.grey[200], // Placeholder color
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: event.imageUrl.isNotEmpty
                      ? event.imageUrl.startsWith('http')
                      ? Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    event.imageUrl,
                    fit: BoxFit.cover,
                  )
                      : const Center(child: Text('No Image')),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                DateFormat.yMMMd().format(event.date),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                getCountdown(event.date),
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                event.description,
                style: const TextStyle(fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (_auth.currentUser?.uid == event.creatorId) ...[
          TextButton(
            onPressed: () => _deleteEvent(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
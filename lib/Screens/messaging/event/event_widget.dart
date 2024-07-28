import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event_model.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  EventCard({required this.event, required this.onTap});

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 290.0,
        margin: const EdgeInsets.only(right: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.lightGreen),
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: _buildEventImage(event.imageUrl),
            ),
            const SizedBox(height: 8.0),
            Text(
              event.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey, size: 14.0),
                const SizedBox(width: 4.0),
                Text(
                  DateFormat.yMMMd().format(event.date),
                  style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                ),
                const Spacer(),
                Text(
                  getCountdown(event.date),
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Expanded(
              child: Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        imageUrl,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }
}
import 'package:flutter/material.dart';

import '../data_model.dart';

class BatchDetailsPage extends StatelessWidget {
  final Batch batch;

  const BatchDetailsPage({Key? key, required this.batch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(batch.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              batch.picture,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            Text('Batch Name: ${batch.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Batch: ${batch.batch}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Created At: ${batch.createdAt}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('User Count: ${batch.userCount}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            // You can add more details here such as a list of students or other relevant information
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'data_model.dart';

class AdminOfficeView extends StatelessWidget {
  final AdminOffice adminOffice;

  AdminOfficeView({required this.adminOffice});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: AspectRatio( // Use AspectRatio to ensure the Container gets proper constraints
          aspectRatio: 16 / 9, // Adjust the aspect ratio as needed
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (adminOffice.picture.isNotEmpty) // Null check for department.picture
                Image.asset(
                  adminOffice.picture,
                  fit: BoxFit.cover,
                ),
              Positioned(
                top: 8.0,
                left: 8.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Text(
                    'Admin-Office',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12.0),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.grey.withOpacity(0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Ensure the column takes minimum space needed
                        children: <Widget>[
                          Text(
                            adminOffice.name,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${adminOffice.userCount} users',
                            style: const TextStyle(fontSize: 14.0, color: Colors.white),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Created on ${adminOffice.creationDate}',
                            style: const TextStyle(fontSize: 14.0, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

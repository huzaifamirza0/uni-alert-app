import 'package:flutter/material.dart';

import '../Screens/Auth/AuthServices/auth_service.dart';
import '../Screens/splash/splash_slides.dart';


void showDeleteUserDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: const Text("Are you sure you want to log out?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              AuthService.clearLoggedIn();
              Navigator.push(context, MaterialPageRoute(builder: (context) => SliderScreen()));
            },
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

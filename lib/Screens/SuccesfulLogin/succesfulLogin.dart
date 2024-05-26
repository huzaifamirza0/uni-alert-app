
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Components/CustomButton.dart';
import '../../MainNavBar/main_navbar.dart';



class SuccessfulLogin extends StatelessWidget {
  const SuccessfulLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80.0,
            ),
            SizedBox(height: 20.0),
            Text(
              "Successful!",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Text(
              "You successfully registered in our",
              style: TextStyle(fontSize: 17.0, color: Colors.black54 ,fontWeight: FontWeight.normal),
            ),
            Text(
              "app and start working in it",
              style: TextStyle(fontSize: 17.0, color: Colors.black54 ,fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(36.0),
        child: SizedBox(
          height: 50,
          child: CustomButton(
            text: "Start Your App",
            onPressed: () {
             Get.to(() => NavBar());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select Categories of your choice!')),
                );
            },
          ),
        ),
      ),
    );
  }
}

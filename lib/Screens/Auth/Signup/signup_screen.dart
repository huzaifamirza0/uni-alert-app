import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notification_app/MainNavBar/main_navbar.dart';
import '../../../Components/auth_button.dart';
import '../../../Services/notification_services.dart';
import '../AuthServices/auth_service.dart';
import '../Login/login_screen.dart';

class SignUpScreen extends StatelessWidget {
  final UserRole role;
  final AuthService _authService = AuthService();

  SignUpScreen({required this.role});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    String roleDescription = '';
    switch (role) {
      case UserRole.student:
        roleDescription =
        'As a Student, you can:\n- Join departments\n- Subscribe to office notifications';
        break;
      case UserRole.hod:
        roleDescription =
        'As a Head of Department, you can:\n- Create departments\n- Create batches\n- Subscribe to office notifications\n- Manage faculty';
        break;
      case UserRole.adminOfficer:
        roleDescription =
        'As an Admin Officer, you can:\n- Create offices\n- Send notifications to subscribers\n- Manage office activities';
        break;
      case UserRole.faculty:
        roleDescription =
        'As a Faculty, you can:\n- Join offices\n- Send notifications to students\n- Join Departments and Batches';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        centerTitle: true,
        title: Text('Sign up as ${role.toString().split('.').last}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60,),
            const Text(
              'Sign Up with University Email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 34),
            Text(
              roleDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 65),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: AuthButton(
                iconColor: Colors.lightGreen,
                borderColor: Colors.black,
                textColor: Colors.black,
                text: 'Sign Up with Google',
                iconAsset: 'assets/google.svg',
                color: Colors.white,
                onPressed: () async {
                  User? user = await _authService.signUpWithGoogle(
                    role,
                    false,
                    0.0,
                    0.0,
                    NotificationServices(),
                    Timestamp.fromDate(DateTime.now()),
                  );
                  if (user != null) {
                    Get.offAll(NavBar());
                  } else {
                    Get.snackbar('Error', 'Failed to sign up with Google.');
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 20,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'OR',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?", style: TextStyle(fontSize: 16),),
                GestureDetector(
                  onTap: () {
                    Get.to(() => SignInScreen());
                  },
                  child: const Text(
                    " Sign In",
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

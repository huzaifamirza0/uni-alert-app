import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification_app/Screens/Auth/Login/login_screen.dart';

import '../../Components/CustomButton.dart';



class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Placeholder(
              fallbackHeight: 100, // Adjust the height as needed
              fallbackWidth: 100, // Adjust the width as needed
            ),
            const SizedBox(height: 100),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: CustomButton(
                color: Colors.lightGreen,
                  text: 'Sign Up',
                  onPressed: (){
                    //Get.to(() => SignUpPage());
                  }
              ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: CustomButton(
                  color: Colors.lightGreen,
                  text: 'Sign In',
                  onPressed: (){
                    //Get.to(() => LoginPage());
                  }
              ),
            )
          ],
        ),
      ),
    );
  }
}

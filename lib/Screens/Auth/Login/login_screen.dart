import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification_app/Screens/Auth/role_select.dart';

import '../../../Components/CustomButton.dart';
import '../../../Components/auth_button.dart';
import '../../../Components/text_fields.dart';
import '../AuthServices/adminOffice_controllers_auth.dart';

class SignInScreen extends StatelessWidget {
  final SignInController signInController = Get.put(SignInController());
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.lightGreen,
              child: const Center(
                child: Text('Welcome to UniAlert',
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Obx(() => CustomTextField(
                        controller: signInController.emailController,
                        labelText: 'Email',
                        preIcon: const Icon(Icons.person, color: Colors.lightGreen,),
                        errorText: signInController.emailTouched.value
                            ? signInController.emailError.value.isNotEmpty
                            ? signInController.emailError.value
                            : null
                            : null,
                        onChanged: (_) => signInController.setEmailTouched(true),
                      )),
                      const SizedBox(height: 12),
                      Obx(() => CustomTextField(
                        controller: signInController.passwordController,
                        labelText: 'Password',
                        preIcon: const Icon(Icons.lock, color: Colors.lightGreen,),
                        errorText: signInController.passwordTouched.value
                            ? signInController.passwordError.value.isNotEmpty
                            ? signInController.passwordError.value
                            : null
                            : null,
                        obscureText: signInController.obscurePassword.value,
                        onPressed: signInController.togglePasswordVisibility,
                        onChanged: (_) => signInController.setPasswordTouched(true),
                      )),
                      const SizedBox(height: 5,),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(onTap: (){},
                            child: Text('Forgot Password', style: TextStyle(color: Colors.red),)),
                      ),
                      const SizedBox(height: 24),
                      Obx(() => SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: CustomButton(
                          color: Colors.lightGreen,
                          onPressed: signInController.isSignInFormValid.value
                              ? signInController.signIn
                              : null,
                          text: 'Sign In',
                        ),
                      )),
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
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                            child: Text('Or continue with'),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AuthButton(
                            text: 'Continue with Google',
                            icon: Icons.g_translate,
                            color: Colors.white,
                            onPressed: () {
                              // Handle the button press
                            },
                            iconColor: Colors.black, textColor: Colors.black, borderColor: Colors.black,
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.09,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          GestureDetector(
                              onTap: (){Get.to(RoleSelectionScreen());},
                              child: const Text("Sign Up", style: TextStyle(color: Colors.blue, fontSize: 16),)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Components/CustomButton.dart';
import '../../../Components/text_fields.dart';
import '../AuthServices/get_controllers_auth.dart';
import '../Signup/signup_screen.dart';

class SignInScreen extends StatelessWidget {
  final SignInController signInController = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png',
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.6,
              ),
              const SizedBox(height: 26,),
              const Text(
                'Welcome to Employee App',
                style: TextStyle(
                  fontSize: 21, color: Colors.lightGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please log in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 50,),
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
                width: MediaQuery.of(context).size.width * 0.7,
                child: CustomButton(
                  color: Colors.lightGreen,
                  onPressed: signInController.isSignInFormValid.value
                      ? signInController.signIn
                      : null,
                  text: 'Sign In',
                ),
              )),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have any account?", style: TextStyle(fontWeight: FontWeight.bold),),
                  const SizedBox(width: 4,),
                  GestureDetector(onTap: (){Get.to(SignUpPage());}, child: const Text('Sign Up',
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 16),))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

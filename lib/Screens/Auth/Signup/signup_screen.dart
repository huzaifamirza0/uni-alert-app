import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Components/CustomButton.dart';
import '../../../Components/text_fields.dart';
import '../AuthServices/get_controllers_auth.dart';

class SignUpPage extends StatelessWidget {
  final SignUpController signUpController = Get.put(SignUpController());

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
              const SizedBox(height: 20),
              const Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6,),
              const Text(
                'Employee Manage',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Obx(() => CustomTextField(
                controller: signUpController.emailController,
                labelText: 'Email',
                preIcon: const Icon(Icons.person, color: Colors.lightGreen,),
                errorText: signUpController.emailTouched.value
                    ? signUpController.emailError.value.isNotEmpty
                    ? signUpController.emailError.value
                    : null
                    : null,
                onChanged: (_) => signUpController.setEmailTouched(true),
              )),
              const SizedBox(height: 12),
              Obx(() => CustomTextField(
                controller: signUpController.phoneController,
                labelText: 'Phone Number',
                preIcon: const Icon(Icons.phone, color: Colors.lightGreen,),
                errorText: signUpController.phoneTouched.value
                    ? signUpController.phoneError.value.isNotEmpty
                    ? signUpController.phoneError.value
                    : null
                    : null,
                onChanged: (_) => signUpController.setPhoneTouched(true),
              )),
              const SizedBox(height: 12),
              Obx(() => CustomTextField(
                controller: signUpController.passwordController,
                labelText: 'Password',
                preIcon: const Icon(Icons.lock, color: Colors.lightGreen,),
                errorText: signUpController.passwordTouched.value
                    ? signUpController.passwordError.value.isNotEmpty
                    ? signUpController.passwordError.value
                    : null
                    : null,
                obscureText: signUpController.obscurePassword.value,
                onPressed: signUpController.togglePasswordVisibility,
                onChanged: (_) => signUpController.setPasswordTouched(true),
              )),
              const SizedBox(height: 12),
              Obx(() => CustomTextField(
                controller: signUpController.confirmPasswordController,
                labelText: 'Confirm Password',
                preIcon: const Icon(Icons.lock, color: Colors.lightGreen,),
                errorText: signUpController.confirmPasswordTouched.value
                    ? signUpController.confirmPasswordError.value.isNotEmpty
                    ? signUpController.confirmPasswordError.value
                    : null
                    : null,
                obscureText: signUpController.obscureConfirmPassword.value,
                onPressed: signUpController.toggleConfirmPasswordVisibility,
                onChanged: (_) => signUpController.setConfirmPasswordTouched(true),
              )),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.7,
                child: CustomButton(
                  color: Colors.lightGreen,
                  onPressed: signUpController.isSignUpFormValid.value
                      ? signUpController.signUp
                      : null,
                  text: 'Sign Up',
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

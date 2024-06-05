import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Components/CustomButton.dart';
import '../../../Components/text_fields.dart';
import '../../../Services/notification_services.dart';
import '../AuthServices/student_auth_controller.dart';

class StudentSignUpScreen extends StatelessWidget {
  final StudentSignUpController signUpController = Get.put(StudentSignUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextField(
                controller: signUpController.nameController,
                labelText: 'Name',
                preIcon: const Icon(Icons.person, color: Colors.lightGreen,),
                errorText: signUpController.nameTouched.value
                    ? signUpController.nameError.value.isNotEmpty
                    ? signUpController.nameError.value
                    : null
                    : null,
                onChanged: (value) => signUpController.setNameTouched(true),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: signUpController.rollNoController,
                labelText: 'Roll Number',
                preIcon: const Icon(Icons.assignment_ind, color: Colors.lightGreen,),
                errorText: signUpController.rollNoTouched.value
                    ? signUpController.rollNoError.value.isNotEmpty
                    ? signUpController.rollNoError.value
                    : null
                    : null,
                onChanged: (value) => signUpController.setRollNoTouched(true),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: signUpController.emailController,
                labelText: 'Email',
                preIcon: const Icon(Icons.email, color: Colors.lightGreen,),
                errorText: signUpController.emailTouched.value
                    ? signUpController.emailError.value.isNotEmpty
                    ? signUpController.emailError.value
                    : null
                    : null,
                onChanged: (_) => signUpController.setEmailTouched(true),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: signUpController.contactController,
                labelText: 'Contact Number',
                preIcon: const Icon(Icons.phone, color: Colors.lightGreen,),
                errorText: signUpController.contactTouched.value
                    ? signUpController.contactError.value.isNotEmpty
                    ? signUpController.contactError.value
                    : null
                    : null,
                onChanged: (value) => signUpController.setContactTouched(true),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: signUpController.departmentController,
                labelText: 'Department',
                preIcon: const Icon(Icons.school, color: Colors.lightGreen,),
                errorText: signUpController.departmentTouched.value
                    ? signUpController.departmentError.value.isNotEmpty
                    ? signUpController.departmentError.value
                    : null
                    : null,
                onChanged: (value) => signUpController.setDepartmentTouched(true),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: signUpController.batchController,
                labelText: 'Batch',
                preIcon: const Icon(Icons.date_range, color: Colors.lightGreen,),
                errorText: signUpController.batchTouched.value
                    ? signUpController.batchError.value.isNotEmpty
                    ? signUpController.batchError.value
                    : null
                    : null,
                onChanged: (value) => signUpController.setBatchTouched(true),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: signUpController.semesterController,
                labelText: 'Semester',
                preIcon: const Icon(Icons.book, color: Colors.lightGreen,),
                errorText: signUpController.semesterTouched.value
                    ? signUpController.semesterError.value.isNotEmpty
                    ? signUpController.semesterError.value
                    : null
                    : null,
                onChanged: (value) => signUpController.setSemesterTouched(true),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: signUpController.passwordController,
                obscureText: signUpController.obscurePassword.value,
                labelText: 'Password',
                preIcon: const Icon(Icons.lock, color: Colors.lightGreen,),
                errorText: signUpController.passwordTouched.value
                    ? signUpController.passwordError.value.isNotEmpty
                    ? signUpController.passwordError.value
                    : null
                    : null,
                onPressed: signUpController.togglePasswordVisibility,
                onChanged: (value) => signUpController.setPasswordTouched(true),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: signUpController.confirmPasswordController,
                obscureText: signUpController.obscureConfirmPassword.value,
                labelText: 'Confirm Password',
                preIcon: const Icon(Icons.lock, color: Colors.lightGreen,),
                errorText: signUpController.confirmPasswordTouched.value
                    ? signUpController.confirmPasswordError.value.isNotEmpty
                    ? signUpController.confirmPasswordError.value
                    : null
                    : null,
                onPressed: signUpController.toggleConfirmPasswordVisibility,
                onChanged: (value) => signUpController.setConfirmPasswordTouched(true),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.7,
                child: CustomButton(
                  color: Colors.lightGreen,
                  onPressed: signUpController.isSignUpFormValid.value
                      ? () => signUpController.signUp(NotificationServices())
                      : null,
                  text: 'Sign Up',
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Services/notification_services.dart';
import 'auth_service.dart';

class StudentSignUpController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isSignUpFormValid = false.obs;

  final RxBool nameTouched = false.obs;
  final RxBool rollNoTouched = false.obs;
  final RxBool emailTouched = false.obs;
  final RxBool contactTouched = false.obs;
  final RxBool departmentTouched = false.obs;
  final RxBool batchTouched = false.obs;
  final RxBool semesterTouched = false.obs;
  final RxBool passwordTouched = false.obs;
  final RxBool confirmPasswordTouched = false.obs;

  final RxString nameError = ''.obs;
  final RxString rollNoError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString contactError = ''.obs;
  final RxString departmentError = ''.obs;
  final RxString batchError = ''.obs;
  final RxString semesterError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;

  bool isValidUonEmail(String email) {
    final regex = RegExp(r'^\d{2}uon\d{4}@uon\.edu\.pk$');
    return regex.hasMatch(email);
  }

  bool isValidRollNo(String rollNo) {
    final regex = RegExp(r'^\d{2}-UON-\d{4}$');
    return regex.hasMatch(rollNo);
  }

  bool isValidContact(String contact) {
    final regex = RegExp(r'^\+923\d{9}$');
    return regex.hasMatch(contact);
  }


  void validateForm() {
    // Validate name
    if (nameTouched.value) {
      if (nameController.text.length > 2) {
        nameError.value = '';
      } else {
        nameError.value = 'Please enter your name';
      }
    }

    // Validate roll number
    if (rollNoTouched.value) {
      if (isValidRollNo(rollNoController.text)) {
        rollNoError.value = '';
      } else {
        rollNoError.value = 'Please enter your valid roll number';
      }
    }

    // Validate email
    if (emailTouched.value) {
      if (isValidUonEmail(emailController.text)) {
        emailError.value = '';
      } else {
        emailError.value = 'Please enter a valid email (e.g., 20uon0567@uon.edu.pk)';
      }
    }

    // Validate contact
    if (contactTouched.value) {
      if (isValidContact(contactController.text)) {
        contactError.value = '';
      } else {
        contactError.value = 'Please enter a valid contact number';
      }
    }


    // Validate password
    if (passwordTouched.value) {
      if (passwordController.text.length < 6) {
        passwordError.value = 'Password must be at least 6 characters long';
      } else {
        passwordError.value = '';
      }
    }

    // Validate confirm password
    if (confirmPasswordTouched.value) {
      if (confirmPasswordController.text != passwordController.text) {
        confirmPasswordError.value = 'Passwords do not match';
      } else {
        confirmPasswordError.value = '';
      }
    }

    // Check if all fields are valid
    isSignUpFormValid.value = nameTouched.value &&
        rollNoTouched.value &&
        emailTouched.value &&
        contactTouched.value &&
        passwordTouched.value &&
        confirmPasswordTouched.value &&
        nameError.value.isEmpty &&
        rollNoError.value.isEmpty &&
        emailError.value.isEmpty &&
        contactError.value.isEmpty &&
        passwordError.value.isEmpty &&
        confirmPasswordError.value.isEmpty;
  }

  void signUp(NotificationServices notificationServices) async {
    if (isSignUpFormValid.value) {
      User? user = await AuthService().signUp(
        UserRole.student,
        nameController.text,
        emailController.text,
        passwordController.text,
        'https://www.shareicon.net/data/512x512/2016/09/15/829459_man_512x512.png',
        false,
        0.0,
        0.0,
        notificationServices,
        rollNo: rollNoController.text,
        contact: contactController.text,
      );
      if (user != null) {
        Get.snackbar('Success','Created an account successfully', snackPosition: SnackPosition.BOTTOM);
        Get.back();
        print('Student sign-up successful!');
      } else {
        // Handle sign-up failure
        print('Student sign-up failed');
      }
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }

  void setNameTouched(bool touched) {
    nameTouched.value = touched;
    validateForm();
  }

  void setRollNoTouched(bool touched) {
    rollNoTouched.value = touched;
    validateForm();
  }

  void setEmailTouched(bool touched) {
    emailTouched.value = touched;
    validateForm();
  }

  void setContactTouched(bool touched) {
    contactTouched.value = touched;
    validateForm();
  }

  void setDepartmentTouched(bool touched) {
    departmentTouched.value = touched;
    validateForm();
  }

  void setBatchTouched(bool touched) {
    batchTouched.value = touched;
    validateForm();
  }

  void setSemesterTouched(bool touched) {
    semesterTouched.value = touched;
    validateForm();
  }

  void setPasswordTouched(bool touched) {
    passwordTouched.value = touched;
    validateForm();
  }

  void setConfirmPasswordTouched(bool touched) {
    confirmPasswordTouched.value = touched;
    validateForm();
  }
}

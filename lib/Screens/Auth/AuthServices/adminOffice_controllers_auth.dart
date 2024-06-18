import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification_app/Screens/Auth/AuthServices/auth_service.dart';
import '../../../MainNavBar/main_navbar.dart';
import '../../../Services/notification_services.dart';
class AdminOfficeSignUpController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController officeDescriptionController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isSignUpFormValid = false.obs;

  final RxBool nameTouched = false.obs;
  final RxBool emailTouched = false.obs;
  final RxBool phoneTouched = false.obs;
  final RxBool passwordTouched = false.obs;
  final RxBool confirmPasswordTouched = false.obs;
  final RxBool officeDescriptionTouched = false.obs;

  final RxString nameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString phoneError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;
  final RxString officeDescriptionError = ''.obs;

  void validateForm() {
    // Validate name if it has been touched
    if (nameTouched.value) {
      if (nameController.text.isEmpty) {
        nameError.value = 'Please enter your name';
      } else {
        nameError.value = '';
      }
    }

    // Validate email if it has been touched
    if (emailTouched.value) {
      if (EmailValidator.validate(emailController.text)) {
        emailError.value = '';
      } else {
        emailError.value = 'Please enter a valid email';
      }
    }

    // Validate phone number if it has been touched
    if (phoneTouched.value) {
      if (phoneController.text.length >= 9) {
        phoneError.value = '';
      } else {
        phoneError.value = 'Please enter a valid phone number';
      }
    }

    // Validate password if it has been touched
    if (passwordTouched.value) {
      if (passwordController.text.length < 6) {
        passwordError.value = 'Password must be at least 6 characters long';
      } else {
        passwordError.value = '';
      }
    }

    // Validate confirm password if it has been touched
    if (confirmPasswordTouched.value) {
      if (confirmPasswordController.text != passwordController.text) {
        confirmPasswordError.value = 'Passwords do not match';
      } else {
        confirmPasswordError.value = '';
      }
    }


    // Validate office description if it has been touched
    if (officeDescriptionTouched.value) {
      if (officeDescriptionController.text.isEmpty) {
        officeDescriptionError.value = 'Please enter the office description';
      } else {
        officeDescriptionError.value = '';
      }
    }

    // Check if all fields are valid
    isSignUpFormValid.value = nameTouched.value &&
        emailTouched.value &&
        phoneTouched.value &&
        passwordTouched.value &&
        confirmPasswordTouched.value &&
        officeDescriptionTouched.value &&
        nameError.value.isEmpty &&
        emailError.value.isEmpty &&
        phoneError.value.isEmpty &&
        passwordError.value.isEmpty &&
        confirmPasswordError.value.isEmpty &&
        officeDescriptionError.value.isEmpty;
  }

  void signUp() async {

    print('Office Description: ${officeDescriptionController.text}');

    if (isSignUpFormValid.value) {

      NotificationServices notificationServices = NotificationServices();
      User? user = await AuthService().signUp(
        UserRole.adminOfficer,
        nameController.text,
        emailController.text,
        passwordController.text,
        'https://www.shareicon.net/data/512x512/2016/09/15/829459_man_512x512.png',
        false,
        0.0,
        0.0,
        notificationServices,
        contact: phoneController.text,
      );

      if (user != null) {
        Get.snackbar('Success', 'Sign-Up successful', snackPosition: SnackPosition.BOTTOM);
        Get.back();
      } else {
        Get.snackbar('Error', 'Sign-Up failed', snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      validateForm();
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

  void setEmailTouched(bool touched) {
    emailTouched.value = touched;
    validateForm();
  }

  void setPhoneTouched(bool touched) {
    phoneTouched.value = touched;
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

  void setOfficeDescriptionTouched(bool touched) {
    officeDescriptionTouched.value = touched;
    validateForm();
  }
}



class SignInController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool isSignInFormValid = false.obs;

  final RxBool emailTouched = false.obs;
  final RxBool passwordTouched = false.obs;

  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;

  void validateForm() {
      // Validate email
    if (emailTouched.value) {
      if (EmailValidator.validate(emailController.text)) {
        emailError.value = '';
      } else {
        emailError.value = 'Please enter a valid email';
      }
    }

    // Validate password if it has been touched
    if (passwordTouched.value) {
      if (passwordController.text.length < 6) {
        passwordError.value = 'Password must be at least 6 characters long';
      } else {
        passwordError.value = '';
      }
    }

    isSignInFormValid.value = emailTouched.value && passwordTouched.value &&
        emailError.value.isEmpty && passwordError.value.isEmpty;
  }

  void signIn() async {
    print('Email: ${emailController.text}');
    print('Password: ${passwordController.text}');

    if (isSignInFormValid.value) {
      User? user = await AuthService().signIn(emailController.text, passwordController.text);
      if (user != null) {
        await AuthService.setLoggedIn(true);
        Get.snackbar('Success','Signed In successfully', snackPosition: SnackPosition.BOTTOM);
        Get.to(() => NavBar());
      } else {
        // Handle sign-up failure
        print('sign-In failed');
      }
    }
    }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void setEmailTouched(bool touched) {
    emailTouched.value = touched;
    validateForm();
  }


  void setPasswordTouched(bool touched) {
    passwordTouched.value = touched;
    validateForm();
  }

}

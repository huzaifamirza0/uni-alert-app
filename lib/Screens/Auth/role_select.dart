import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Components/CustomButton.dart';
import 'Signup/faculty_signup.dart';
import 'Signup/hod_signup.dart';
import 'Signup/student_signup.dart';


enum UserRole { student, faculty, hod, adminOffice }

class RoleSelectionController extends GetxController {
  var selectedRole = UserRole.student.obs;

  void setSelectedRole(UserRole role) {
    selectedRole.value = role;
  }
}

class RoleSelectionScreen extends StatelessWidget {
  final RoleSelectionController roleController = Get.put(RoleSelectionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'I am',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 22,
                  crossAxisSpacing: 24,
                  childAspectRatio: 3 / 3,
                ),
                itemCount: UserRole.values.length,
                itemBuilder: (context, index) {
                  UserRole role = UserRole.values[index];
                  return Obx(() {
                    bool isSelected = roleController.selectedRole.value == role;
                    return GestureDetector(
                      onTap: () => roleController.setSelectedRole(role),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.lightGreen : Colors.white,
                          borderRadius: BorderRadius.circular(26.0),
                          // border: Border.all(
                          //   color: isSelected ? Colors.lightGreen : Colors.grey,
                          // ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            role.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.7,
              child: CustomButton(
                color: Colors.lightGreen,
                  onPressed: () {
                    switch (roleController.selectedRole.value) {
                      case UserRole.student:
                        Get.to(() => StudentSignUpScreen());
                        break;
                      case UserRole.faculty:
                        Get.to(() => FacultySignUpScreen());
                        break;
                      case UserRole.hod:
                        Get.to(() => HodSignUpScreen());
                        break;
                      case UserRole.adminOffice:
                      // Get.to(() => AdminOfficeSignUpScreen());
                        break;
                    }
                  },
                  text: 'Continue',
                )
            ),
          ],
        ),
      ),
    );
  }
}

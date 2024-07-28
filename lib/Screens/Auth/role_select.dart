import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Components/CustomButton.dart';
import 'AuthServices/auth_service.dart';
import 'Signup/signup_screen.dart';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.all(constraints.maxWidth * 0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'I am',
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.04),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth < 600 ? 2 : 3,
                      mainAxisSpacing: constraints.maxHeight * 0.03,
                      crossAxisSpacing: constraints.maxWidth * 0.05,
                      childAspectRatio: 1,
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26.0),
                              border: Border.all(
                                color: isSelected ? Colors.lightGreen : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                role.toString().split('.').last.toUpperCase(),
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.lightGreen : Colors.black,
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
                  height: constraints.maxHeight * 0.08,
                  width: constraints.maxWidth * 0.7,
                  child: CustomButton(
                    color: Colors.lightGreen,
                    onPressed: () {
                      Get.to(() => SignUpScreen(role: roleController.selectedRole.value));
                    },
                    text: 'Continue',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

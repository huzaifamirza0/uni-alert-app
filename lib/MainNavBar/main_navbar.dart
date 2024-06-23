import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification_app/Screens/Map/map.dart';
import 'package:notification_app/Screens/Profile/page/profile_page.dart';
import 'package:notification_app/Screens/department/department_screen.dart';
import 'package:notification_app/Screens/home/home.dart';

import '../Screens/messaging/public_message_dialog.dart';

class NavController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}

class NavBar extends StatelessWidget {
  final NavController navController = Get.put(NavController());

  @override
  Widget build(BuildContext context) {
    double fabHeight = MediaQuery.of(context).size.height * 0.1;
    return Scaffold(
      extendBody: true,
      body: Obx(() {
        switch (navController.selectedIndex.value) {
          case 0:
            return HomePage();
          case 1:
            return DepartmentScreen();
          case 2:
            return GoMap();
          case 3:
            return ProfilePage();
          default:
            return HomePage();
        }
      }),
      bottomNavigationBar: Obx(() {
        return BottomAppBar(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.082,
          shape: const CircularNotchedRectangle(),
          notchMargin: 4.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  navController.selectedIndex.value == 0
                      ? Icons.home
                      : Icons.home_outlined,
                  color: navController.selectedIndex.value == 0
                      ? Colors.lightGreen
                      : Colors.grey,
                ),
                onPressed: () {
                  navController.changeIndex(0);
                },
              ),
              IconButton(
                icon: Icon(
                  navController.selectedIndex.value == 1
                      ? Icons.school
                      : Icons.school_outlined,
                  color: navController.selectedIndex.value == 1
                      ? Colors.lightGreen
                      : Colors.grey,
                ),
                onPressed: () {
                  navController.changeIndex(1);
                },
              ),
              const SizedBox(width: 48), // The dummy child for the floating action button's position
              IconButton(
                icon: Icon(
                  navController.selectedIndex.value == 2
                      ? Icons.emergency
                      : Icons.emergency_outlined,
                  color: navController.selectedIndex.value == 2
                      ? Colors.lightGreen
                      : Colors.grey,
                ),
                onPressed: () {
                  navController.changeIndex(2);
                },
              ),
              IconButton(
                icon: Icon(
                  navController.selectedIndex.value == 3
                      ? Icons.person
                      : Icons.person_outline,
                  color: navController.selectedIndex.value == 3
                      ? Colors.lightGreen
                      : Colors.grey,
                ),
                onPressed: () {
                  navController.changeIndex(3);
                },
              ),
            ],
          ),
        );
      }),
      floatingActionButton: SizedBox(
        width: fabHeight,
        height: fabHeight,
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return MessageDialog();
              },
            );
          },
          backgroundColor: Colors.lightGreen,
          shape: const CircleBorder(),
          child: Icon(Icons.add, size: fabHeight * 0.6),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
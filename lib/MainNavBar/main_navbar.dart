import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../Screens/Profile/page/profile_page.dart';
import '../Screens/department/department_screen.dart';
import '../Screens/home.dart';
import '../Screens/notification.dart';

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
    return Stack(
      children: [
        Obx(() {
          return CupertinoTabScaffold(
            tabBar: CupertinoTabBar(

              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    navController.selectedIndex.value == 0
                        ? Icons.home
                        : Icons.home_outlined,
                    color: navController.selectedIndex.value == 0
                        ? Colors.lightGreen
                        : Colors.grey,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    navController.selectedIndex.value == 1
                        ? Icons.school
                        : Icons.school_outlined,
                    color: navController.selectedIndex.value == 1
                        ? Colors.lightGreen
                        : Colors.grey,
                  ),
                  label: 'Department',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    navController.selectedIndex.value == 2
                        ? Icons.calendar_today
                        : Icons.calendar_today_outlined,
                    color: navController.selectedIndex.value == 2
                        ? Colors.lightGreen
                        : Colors.grey,
                  ),
                  label: 'Calendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    navController.selectedIndex.value == 3
                        ? Icons.person
                        : Icons.person_outline,
                    color: navController.selectedIndex.value == 3
                        ? Colors.lightGreen
                        : Colors.grey,
                  ),
                  label: 'Profile',
                ),
              ],
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.080,
              onTap: navController.changeIndex,
              currentIndex: navController.selectedIndex.value,
            ),
            tabBuilder: (BuildContext context, int index) {
              Widget tabContent;
              switch (index) {
                case 0:
                  tabContent = HomePage();
                case 1:
                  tabContent = DepartmentScreen();
                case 2:
                  tabContent = NotificationScreen();
                case 3:
                  tabContent = ProfilePage();
                default:
                  tabContent = HomePage();
              }
              return CupertinoTabView(
                builder: (BuildContext context) => tabContent,
              );
            },
          );
        }),
      ],
    );
  }
}

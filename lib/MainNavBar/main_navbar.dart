import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Screens/home.dart';

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
      body: Obx(() {
        switch (navController.selectedIndex.value) {
          case 0:
            return HomePage();
          case 1:
            return const Center(child: Text('Wait'));
          case 2:
            return const Center(child: Text('Calendar'));
          case 3:
            return const Center(child: Text('Profile'));
          default:
            return const Center(child: Text('Home Screen'));
        }
      }),
      bottomNavigationBar: Obx(() {
        return BottomAppBar(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.082,
          //shape: const CircularNotchedRectangle(),
          //notchMargin: 4.0,
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
                      ? Icons.grid_view_rounded
                      : Icons.grid_view,
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
                      ? Icons.calendar_today
                      : Icons.calendar_today_outlined,
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
            // Handle the floating action button press
          },
          backgroundColor: Colors.lightGreen,
          shape: CircleBorder(),
          child: Icon(Icons.add, size: fabHeight * 0.6),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
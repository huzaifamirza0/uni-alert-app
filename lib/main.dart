import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification_app/MainNavBar/main_navbar.dart';
import 'Screens/Auth/AuthServices/auth_service.dart';
import 'Screens/splash/splash_slides.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await AuthService.isLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'UniAlert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        useMaterial3: true,
      ),
      home: isLoggedIn ? NavBar() : SliderWidget(),
    );
  }
}
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification_app/MainNavBar/main_navbar.dart';
import 'package:notification_app/Screens/notification.dart';
import 'package:provider/provider.dart';
import 'Screens/Auth/AuthServices/auth_service.dart';
import 'Screens/Map/emergencyIdProvider.dart';
import 'Screens/Map/emergency_state.dart';
import 'Screens/splash/splash_slides.dart';
import 'fake.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  final isLoggedIn = await AuthService.isLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EmergencyStatusProvider()),
        ChangeNotifierProvider(create: (context) => EmergencyIdProvider()),
      ],

      child: GetMaterialApp(
        title: 'UniAlert',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.green,
          useMaterial3: true,
        ),
        home: isLoggedIn ? NavBar() : SliderScreen()
      ),
    );
  }
}

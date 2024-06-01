import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user.dart' as ProfileUser;

class UserPreferences {
  static Future<ProfileUser.User> fetchMyUser() async {

    //final userId = await AuthService.getUserId();

    // final userSnapshot =
    // await FirebaseFirestore.instance.collection('users').doc(userId).get();

    //final userData = userSnapshot.data() as Map<String, dynamic>;

    final user = ProfileUser.User(
      imagePath: 'https://www.shareicon.net/data/512x512/2016/09/15/829459_man_512x512.png',
      name: 'Huzaifa',     //userData['name'],
      email: 'huzaifa@gmail.com',   //userData['email'],
      about: 'Certified Personal Trainer and Nutritionist with years of experience in creating effective diets and training plans focused on achieving individual customers goals in a smooth way.',
      isDarkMode: false,
      emergency: true, //userData['status'],
      latitude: 32.4324,   //userData['lat'],
      longitude: 74.4323   //userData['lan']
    );
    return user;
  }
}

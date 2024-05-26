
import 'package:flutter/material.dart';
import 'package:notification_app/Screens/Profile/profile%20body/person.dart';
import 'package:notification_app/Screens/Profile/profile%20body/profile_items.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 30,),
            onPressed: () {
              // Add your back button functionality here
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.settings, size: 30,),
              onPressed: () {
                // Add your settings button functionality here
              },
            ),
          ),
        ],
        toolbarHeight: 70,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: profileWidget('assets/profile_image.png', 'Huzaifa', 'mirzahuzaifa17@gmail.com')),
            const SizedBox(height: 30,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black45)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    ProfileItem('Personal Details', Icons.person,
                        onTap: (){} ),
                    ProfileItem('My Department', Icons.school,
                        onTap: (){} ),
                    // ProfileItem('My Favorites', Icons.favorite,
                    //     onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => FavoriteItemList()));
                    // } ),
                    // ProfileItem('Shipping Addresses', Icons.location_on),
                    // ProfileItem('My Card', Icons.credit_card),
                    ProfileItem('Settings', Icons.settings),
                  ],
                ),
              ),
            ),
              const SizedBox(height: 30,),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black45)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      ProfileItem('FAQ', Icons.error),
                      ProfileItem('Privacy Policy', Icons.security),
                      ProfileItem('Terms & Conditon', Icons.description),
          
                    ],
                  ),
                ),
              )
            ]
          ),
        ),
      ),
    );
  }
}

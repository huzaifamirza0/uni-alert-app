import 'dart:io';
import 'package:flutter/material.dart';
import '../model/user.dart';
import '../utils/user_preferences.dart';
import '../widget/appbar_widget.dart';
import '../widget/profile_widget.dart';
import '../widget/textfield_widget.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late User user;

  @override
  void initState() {
    super.initState();
    //loadUser(); // Call loadUser method to initialize user field
    user = widget.user;
  }

  // Future<void> loadUser() async {
  //   final fetchedUser = await UserPreferences.fetchMyUser();
  //   setState(() {
  //     user = fetchedUser;
  //   });
  // }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: buildAppBar(context),
      body: user != null ? buildProfileEditor() : buildLoading(),
    );

  Widget buildProfileEditor() => ListView(
    padding: EdgeInsets.symmetric(horizontal: 32),
    physics: BouncingScrollPhysics(),
    children: [
      ProfileWidget(
        imagePath: user.imagePath,
        isEdit: true,
        onClicked: () async {
          // Handle image selection or capture here
        },
      ),
      const SizedBox(height: 24),
      TextFieldWidget(
        label: 'Full Name',
        text: user.name,
        onChanged: (name) {},
      ),
      const SizedBox(height: 24),
      TextFieldWidget(
        label: 'Email',
        text: user.email,
        onChanged: (email) {},
      ),
      const SizedBox(height: 24),
      TextFieldWidget(
        label: 'About',
        text: user.about,
        maxLines: 5,
        onChanged: (about) {},
      ),
    ],
  );

  Widget buildLoading() => Center(child: CircularProgressIndicator());
}

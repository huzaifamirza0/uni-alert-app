import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/user.dart';
import '../widget/mapTile.dart';
import '../widget/profile_items.dart';
import '../utils/user_preferences.dart';
import '../widget/appbar_widget.dart';
import '../widget/button_widget.dart';
import '../widget/numbers_widget.dart';
import '../widget/profile_widget.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = UserPreferences.fetchMyUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          final user = snapshot.data!;
          DateTime dateTime = user.dateofJoin.toDate();
          String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);

          return Scaffold(
            appBar: buildAppBar(context),
            body: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                ProfileWidget(
                  imagePath: user.imagePath,
                  onClicked: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => EditProfilePage(user: user, imageUrl: user.imagePath,)),
                    );
                  },
                ),
                const SizedBox(height: 24),
                buildName(user),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
              Center(
                child: Builder(
                  builder: (context) {
                    String roleText;
                    TextStyle textStyle;

                    switch (user.role) {
                      case 'adminOfficer':
                        roleText = 'Admin Officer';
                        textStyle = const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        );
                        break;
                      case 'hod':
                        roleText = 'Head of Department';
                        textStyle = const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        );
                        break;
                      case 'faculty':
                        roleText = 'Faculty';
                        textStyle = const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        );
                        break;
                      case 'student':
                        roleText = 'Student';
                        textStyle = const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        );
                        break;
                      default:
                        roleText = 'N/A';
                        textStyle = const TextStyle(fontSize: 14);
                        break;
                    }

                    return Text(
                      roleText,
                      style: textStyle,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    print(user.dateofJoin.toString());
                  },
                  child: LocationWidget(latitude: user.latitude, longitude: user.longitude),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phone:',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Department:',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Date of Joining:',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.phone,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  user.departmentCode?? '(Join Department)',
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 10),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                buildAbout(user),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildName(User user) => Column(
    children: [
      Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      const SizedBox(height: 4),
      Text(
        user.email,
        style: const TextStyle(color: Colors.grey),
      )
    ],
  );

  Widget buildAbout(User user) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          user.about??'',
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
      ],
    ),
  );
}

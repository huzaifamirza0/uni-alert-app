import 'package:flutter/material.dart';

import '../Profile/model/user.dart';
import '../Profile/utils/user_preferences.dart';
import '../messaging/event/event_message.dart';

class CustomDrawer extends StatefulWidget {
  final String userRole;
  final VoidCallback onLogout;

  const CustomDrawer({super.key, required this.userRole, required this.onLogout});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {

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
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(user.name),
                    accountEmail: Text(user.email),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(user.imagePath),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.lightGreen.shade300,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      // Navigate to home page
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  if (widget.userRole == 'hod' || widget.userRole == 'adminOfficer')
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: const Text('Create Event'),
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) =>
                              EventDialog(userRole: widget.userRole),
                        );
                      },
                    ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: widget.onLogout,
                  ),
                ],
              ),
            );
          }
        }
    );
  }
}

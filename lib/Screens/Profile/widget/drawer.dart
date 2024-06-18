import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String profileImageUrl;
  final String name;
  final String email;
  final VoidCallback onLogout;

  const CustomDrawer({
    required this.profileImageUrl,
    required this.name,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(name),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

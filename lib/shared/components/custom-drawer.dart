// lib/shared/components/custom_drawer.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invit/features/auth/login_screen.dart';
import 'package:invit/features/profile/profile_screen.dart';
import 'package:invit/features/subscription/getSubscription.dart';

class CustomDrawer extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CustomDrawer({Key? key}) : super(key: key);

  void _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully signed out'),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigoAccent,
            ),
            child: Text(
              'Invit Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.subscriptions),
            title: Text('Subscription'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GetSubscription()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sign Out'),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}

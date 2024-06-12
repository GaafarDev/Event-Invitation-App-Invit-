import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invit/features/auth/login_screen.dart';
import 'package:invit/features/home/home_screen.dart';
import 'package:invit/features/home/home_screen_org.dart';
import 'package:invit/features/profile/profile_screen.dart';
import 'package:invit/features/subscription/getSubscription.dart';

class CustomDrawer extends StatefulWidget {
  final bool isOrganizerView;

  CustomDrawer({Key? key, this.isOrganizerView = false}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late bool _isOrganizerView;

  @override
  void initState() {
    super.initState();
    _isOrganizerView = widget.isOrganizerView;
  }

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

  void _navigateToHomePageOrg(BuildContext context) async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        print('User document does not exist.');
        return;
      }

      DateTime subDateEnd = userDoc['subDateEnd'].toDate();

      if (subDateEnd.isBefore(DateTime.now())) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GetSubscription()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePageOrg(isOrganizerView: true)),
        );
      }
    } catch (e) {
      print('Error retrieving user document: $e');
    }
  }

  void _navigateToHomePage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(isOrganizerView: false)),
    );
  }

  void _toggleView(bool value) {
    setState(() {
      _isOrganizerView = value;
    });

    if (_isOrganizerView) {
      _navigateToHomePageOrg(context);
    } else {
      _navigateToHomePage(context);
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
              Navigator.pop(context);
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
              Navigator.pop(context);
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
          SwitchListTile(
            title: Text('Switch to Organizer View'),
            value: _isOrganizerView,
            onChanged: _toggleView,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invit/features/auth/login_screen.dart';
import 'package:invit/features/events/create_event_screen.dart';
import 'package:invit/features/events/view_organizer_event.dart';
import 'package:invit/features/home/home_screen.dart';
import 'package:invit/features/profile/profile_screen.dart';
import 'package:invit/shared/components/custom-drawer.dart';
import 'package:invit/shared/components/custom_navigationbar.dart';
import 'package:invit/features/subscription/getSubscription.dart';
import 'package:invit/shared/components/custom_navigationbar_org.dart';
import 'package:invit/shared/constants/assets_strings.dart';

class HomePageOrg extends StatefulWidget {
  const HomePageOrg({Key? key}) : super(key: key);

  @override
  State<HomePageOrg> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageOrg> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;
  String searchString = '';
  final List<Widget> _children = [
    Text('Org Home Screen'), // Replace with your actual saved screen widget
    OrganizerViewEventScreen(),
    Text('Map'), // Replace with your actual saved screen widget
    Text('Org Finance'),
  ];

  void _signOut() async {
    try {
      await _auth.signOut();
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully signed out'),
          ),
        );
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } catch (e) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out'),
          ),
        );
      });
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> searchEvents(String searchString) async {
    // Your searchEvents function here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(200.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.indigoAccent,
            title: Row(
              children: [
                Text('Invit Organizer View'),
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  // Your search dialog here
                },
              ),
              TextButton(
                child: Text('Sign Out'),
                onPressed: _signOut,
              ),
            ],
          ),
        ),
      ),
      drawer: CustomDrawer(), // Add this line
      body: _children[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomNavigationBar(
        onTap: onTabTapped,
      ),
    );
  }
}

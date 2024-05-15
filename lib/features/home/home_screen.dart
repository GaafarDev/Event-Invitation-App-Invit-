import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invit/features/auth/login_screen.dart';
import 'package:invit/features/events/create_event_screen.dart';
import 'package:invit/features/events/view_organizer_event.dart';
import 'package:invit/features/profile/profile_screen.dart';
import 'package:invit/shared/components/custom_navigationbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;
  String searchString = '';
  final List<Widget> _children = [
    Text('Home Screen'), // Replace with your actual saved screen widget
    OrganizerViewEventScreen(),
    Text('Map'), // Replace with your actual saved screen widget
    Text('Invitation'),
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
            title: Text('Home'),
            leading: IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
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

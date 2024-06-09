import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invit/features/auth/login_screen.dart';
import 'package:invit/features/events/create_event_screen.dart';
import 'package:invit/features/events/view_organizer_event.dart';
import 'package:invit/features/events/view_participating_event_user.dart';
import 'package:invit/features/home/home_screen_org.dart';
import 'package:invit/features/invitations/view_invitations.dart';
import 'package:invit/features/profile/profile_screen.dart';
import 'package:invit/services/all-events-search-service.dart';
import 'package:invit/shared/components/custom-drawer.dart';
import 'package:invit/shared/components/custom_navigationbar.dart';
import 'package:invit/features/subscription/getSubscription.dart';
import 'package:invit/shared/constants/assets_strings.dart';

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
    // Text('User Event View'),
    UserEventListView(),
    // OrganizerViewEventScreen(),
    Text('Map'), // Replace with your actual saved screen widget
    InvitationPage() // Text('Invitation'),
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
    // Your searchEvents function here boy
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
                Text('Invit User View'),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePageOrg()),
                    );
                  },
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventSearchPage()),
                  );
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
      drawer: CustomDrawer(),
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

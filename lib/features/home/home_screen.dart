import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invit/features/auth/login_screen.dart';
import 'package:invit/features/events/create_event_screen.dart';
import 'package:invit/features/events/view_organizer_event.dart';
import 'package:invit/features/home/home_screen_cont.dart';
import 'package:invit/features/home/home_screen_org.dart';
import 'package:invit/features/invitations/view_invitations.dart';
import 'package:invit/features/profile/profile_screen.dart';
import 'package:invit/shared/components/custom_navigationbar.dart';
import 'package:invit/features/subscription/getSubscription.dart';
import 'package:invit/shared/constants/assets_strings.dart';
import 'package:invit/shared/constants/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;
  String searchString = '';
  String _location = 'Fetching...';
  final List<Widget> _children = [
    // Text('Home Screen'), // Replace with your actual saved screen widget
    HomePageContent(),
    Text('User Event View'),
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
    // Your searchEvents function here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
  preferredSize: Size.fromHeight(180.0),
  child: ClipRRect(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(40),
      bottomRight: Radius.circular(40),
    ),
    child: AppBar(
      backgroundColor: button1,
      flexibleSpace: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                      padding: EdgeInsets.only(left: 8.0), // Add space to the left side
                      child: IconButton(
                        icon: Icon(Icons.person_outline, size: 50, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfileScreen()),
                          );
                        },
                      ),
                    ),
                
             Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Align the text to the start
                  children: <Widget>[
                    Text(
                      'Current Location :', 
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                _location,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
                  ],
                ),

                //Button to access Organiser Page
                // IconButton(
                //   icon: Icon(Icons.add),
                //   onPressed: () {
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(builder: (context) => HomePageOrg()),
                //     );
                //   },
                // ),
                
             Container(
                    width: 60.0, // Set the width as needed
                    height: 40.0, // Set the height as needed
                    child: TextButton(
                      style: TextButton.styleFrom(
                      ),
                      onPressed: _signOut,
                      child: Icon(Icons.logout, color: Colors.white , size: 35,),
                    ),
                  ),
              ],
            ),
              Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "| Search...",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 24),
                prefixIcon: Icon(Icons.search, color: Colors.white, size: 30),

             border: InputBorder.none,
              ),
            ),
          ),
          ],
        ),
      ),
    ),
  ),
),
      body: _children[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePageOrg()),
            (Route<dynamic> route) => false,
          );
          Future.delayed(Duration.zero, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateEventScreen()),
            );
          });
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
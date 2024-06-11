// lib\features\home\home_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invit/features/auth/login_screen.dart';
import 'package:invit/features/events/create_event_screen.dart';
import 'package:invit/features/events/view_participating_event_user.dart';
import 'package:invit/features/home/home_screen_cont.dart';
import 'package:invit/features/home/home_screen_org.dart';
import 'package:invit/features/invitations/view_invitations.dart';
import 'package:invit/features/map/map_screen.dart';
import 'package:invit/features/profile/profile_screen.dart';
import 'package:invit/features/services/all-events-search-service.dart';
import 'package:invit/shared/components/custom-drawer.dart';
import 'package:invit/shared/components/custom_navigationbar.dart';
import 'package:invit/features/subscription/getSubscription.dart';
import 'package:invit/shared/constants/assets_strings.dart';
import 'package:invit/shared/constants/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required bool isOrganizerView}) : super(key: key);
  final bool isOrganizerView = false;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;
  String searchString = '';

  final List<Widget> _children = [
    HomePageContent(),
    UserEventListView(),
    MapPage(),
    InvitationPage(),
  ];

  void _signOut() async {
    try {
      await _auth.signOut();
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          child: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              'Invit User View',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            backgroundColor: button1,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 165.0, top: 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: <Widget>[
                            Center(
                                // child: Text(
                                //   'Invit User View',
                                //   style: TextStyle(
                                //       color: Colors.white, fontSize: 20),
                                // ),
                                ),
                          ],
                        ),

                        //Button to access Organiser Page
                        // IconButton(
                        //   icon: Icon(Icons.add),
                        //   onPressed: () {
                        //     Navigator.pushReplacement(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => HomePageOrg(
                        //                 isOrganizerView: true,
                        //               )),
                        //     );
                        //   },
                        // ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.search, color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EventSearchPage()),
                                );
                              },
                            ),
                            SizedBox(width: 10.0), // Set the height as needed
                            TextButton(
                              style: TextButton.styleFrom(),
                              onPressed: _signOut,
                              child: Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(isOrganizerView: widget.isOrganizerView),
      body: _children[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Get the current user's id
            String uid = FirebaseAuth.instance.currentUser!.uid;

            // Log the value of uid
            print('UID: $uid');

            // Get the user's document
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();

            if (!userDoc.exists) {
              print('User document does not exist.');
              return;
            }

            // Get the subDateEnd field
            DateTime subDateEnd = userDoc['subDateEnd'].toDate();

            // Compare subDateEnd with the current date
            if (subDateEnd.isBefore(DateTime.now())) {
              // If subDateEnd is in the past, navigate to GetSubscription
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GetSubscription()),
              );
            } else {
              // If subDateEnd is in the future, navigate to HomePageOrg
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateEventScreen()),
              );
            }
          } catch (e) {
            print('Error retrieving user document: $e');
          }
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

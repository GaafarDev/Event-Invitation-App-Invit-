import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invit/features/auth/login_screen.dart';
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
    Text('Saved Screen'), // Replace with your actual saved screen widget
    ProfileScreen(),
  ];

  void _signOut() async {
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

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> searchEvents(String searchString) async {
    final nameSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('eventName', isEqualTo: searchString)
        .get();

    final venueSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('venue', isEqualTo: searchString)
        .get();

    final descriptionSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('description', isEqualTo: searchString)
        .get();

    final nameEvents = nameSnapshot.docs.map((doc) => doc.data()).toList();
    final venueEvents = venueSnapshot.docs.map((doc) => doc.data()).toList();
    final descriptionEvents =
        descriptionSnapshot.docs.map((doc) => doc.data()).toList();

    // Combine all the events
    final allEvents = [...nameEvents, ...venueEvents, ...descriptionEvents];

    // Show a message based on whether the search results are found or not
    if (allEvents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No events found for "$searchString"'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${allEvents.length} events found for "$searchString"'),
        ),
      );
    }

    // Do something with the events
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
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Search'),
                        content: TextField(
                          onChanged: (value) {
                            // Store the input value to a variable
                            searchString = value;
                          },
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Search'),
                            onPressed: () {
                              // Call the search function with the input value
                              searchEvents(searchString);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
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
      body: _children[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action here
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}

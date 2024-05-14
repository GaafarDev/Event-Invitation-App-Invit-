import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';

import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late Future<DocumentSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future =
        FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      initPositionSelected: 0,
      backgroundColorMenu: Colors.blue,
      screens: [
        ScreenHiddenDrawer(
          ItemHiddenMenu(
            name: "Profile",
            baseStyle: TextStyle(color: Colors.white, fontSize: 28.0),
            colorLineSelected: Colors.teal,
            selectedStyle: TextStyle(color: Colors.white, fontSize: 30.0),
          ),
          Scaffold(
            body: FutureBuilder<DocumentSnapshot>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  if (snapshot.data?.data() != null) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    Timestamp subDateEnd = data['subDateEnd'];
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(subDateEnd.toDate());
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: <Widget>[
                          // Your widgets here...
                        ],
                      ),
                    );
                  } else {
                    return Center(child: Text('No data'));
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

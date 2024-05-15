import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invit/features/profile/edit_profile.dart';
import 'package:invit/shared/constants/colors.dart';
import 'package:invit/shared/constants/sizes.dart';

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
    return Scaffold(
      backgroundColor: neutralLight4,
      appBar: AppBar(
        title: Text(
          'User Profile',
          style: TextStyle(fontSize: heading1FontSize),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            Timestamp subDateEnd = data['subDateEnd'];
            String formattedDate =
                DateFormat('yyyy-MM-dd').format(subDateEnd.toDate());
            return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Card(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            fillColor: neutralLight5,
                            filled: true,
                            hintText: 'Full Name',
                            prefixIcon: Icon(Icons.person), // Add this line
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: gray1),
                            ),
                          ),
                          controller:
                              TextEditingController(text: data['fullName']),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Card(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            fillColor: neutralLight5,
                            filled: true,
                            hintText: 'Phone No',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: gray1),
                            ),
                          ),
                          controller:
                              TextEditingController(text: data['phoneNo']),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Card(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            fillColor: neutralLight5,
                            filled: true,
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: gray1),
                            ),
                          ),
                          controller: TextEditingController(text: user?.email),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Card(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            fillColor: neutralLight5,
                            filled: true,
                            hintText: 'Gender',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: gray1),
                            ),
                          ),
                          controller:
                              TextEditingController(text: data['gender']),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Card(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            fillColor: neutralLight5,
                            filled: true,
                            hintText: 'Subscription End Date',
                            prefixIcon: Icon(Icons.date_range),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: gray1),
                            ),
                          ),
                          controller:
                              TextEditingController(text: formattedDate),
                        ),
                      ),
                      SizedBox(height: 68.0),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          height: 50, // Change this to your desired height
                          width: 400, // Change this to your desired width
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: button1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(color: neutralLight5),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(Icons.arrow_forward_ios,
                                      color: neutralLight5), // Add this line
                                ),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfileScreen()),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ));
          }
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  return Scaffold(
    appBar: AppBar(
      title: Text('Profile'),
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
            child: ListView(
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Email'),
                    subtitle: Text('${user?.email}'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Full Name'),
                    subtitle: Text('${data['fullName']}'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text('Gender'),
                    subtitle: Text('${data['gender']}'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('Phone No'),
                    subtitle: Text('${data['phoneNo']}'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.date_range),
                    title: Text('Subscription End Date'),
                    subtitle: Text('$formattedDate'),
                  ),
                ),
              ],
            ),
          );
        }
      },
    ),
  );
}}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SendInvitationPage extends StatefulWidget {
  final Map<String, dynamic> eventData;

  SendInvitationPage({required this.eventData});
  @override
  _SendInvitationPageState createState() => _SendInvitationPageState();
}

class _SendInvitationPageState extends State<SendInvitationPage> {
  Map<String, bool> userCheckStatus = {};
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Invitations For: ' + widget.eventData['name']),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search by name or phone number',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            child: Text('Send Invitations'),
            onPressed: () {
              userCheckStatus.forEach((userId, isChecked) {
                if (isChecked) {
                  sendInvitation(userId, widget.eventData['id']);
                }
              });

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Invitations Sent'),
                    content: Text('Invitations have been successfully sent.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Pop the dialog
                          Navigator.of(context).pop(); // Pop the current page
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                snapshot.data?.docs.forEach((doc) {
                  final userId = doc.id;
                  if (userCheckStatus[userId] == null) {
                    userCheckStatus[userId] = false;
                  }
                });

                final filteredUsers = snapshot.data?.docs.where((document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      final fullName = data['fullName'].toLowerCase();
                      final phoneNumber = data['phoneNo'];
                      return fullName.contains(searchQuery.toLowerCase()) ||
                          phoneNumber.contains(searchQuery);
                    }).toList() ??
                    [];

                return ListView(
                  children: filteredUsers.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    final userId = document.id;
                    return CheckboxListTile(
                      title: Text('Full Name: ${data['fullName']}'),
                      subtitle: Text('Phone No: ${data['phoneNo']}'),
                      value: userCheckStatus[userId],
                      onChanged: (bool? value) {
                        setState(() {
                          userCheckStatus[userId] = value!;
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void sendInvitation(String userId, String eventId) {
  // Get a reference to the Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Create a new document in the 'invitations' collection
  firestore.collection('invitations').add({
    'userId': userId,
    'eventId': eventId,
    'status': 'Pending',
  });
}

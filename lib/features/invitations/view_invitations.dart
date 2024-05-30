import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:invit/shared/constants/colors.dart';
import 'package:invit/shared/constants/sizes.dart';

class InvitationPage extends StatefulWidget {
  @override
  _InvitationPageState createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchInvitations(String userId) async {
    final invitationSnapshots = await FirebaseFirestore.instance
        .collection('invitations')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: "Pending")
        .get();

    List<Map<String, dynamic>> invitations = [];

    for (var invitation in invitationSnapshots.docs) {
      final eventId = invitation.data()['eventId'];
      final eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      invitations.add({
        'eventData': eventSnapshot.data(),
        'invitationStatus': invitation.data()['status'],
        'invitationId': invitation.id,
      });
    }

    return invitations;
  }

  void acceptInvitation(String invitationId) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      print('No user logged in');
      return;
    }

    // Update the invitation status to "Accepted"
    await FirebaseFirestore.instance
        .collection('invitations')
        .doc(invitationId)
        .update({'status': 'Accepted'});

    // Get the event ID of the invitation
    final invitationSnapshot = await FirebaseFirestore.instance
        .collection('invitations')
        .doc(invitationId)
        .get();
    final eventId = invitationSnapshot.data()?['eventId'];

    // Add a new document to the participants collection
    await FirebaseFirestore.instance.collection('participants').add({
      'userId': currentUser.uid,
      'eventId': eventId,
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invitation Accepted'),
          content: Text('Invitation has been accepted.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Refresh the page
    setState(() {});
  }

  void rejectInvitation(String invitationId) async {
    // Update the invitation status to "Rejected"
    await FirebaseFirestore.instance
        .collection('invitations')
        .doc(invitationId)
        .update({'status': 'Rejected'});

    // Show a popup message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invitation Rejected'),
          content: Text('Invitation has been rejected.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Refresh the page
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Invitations'),
      ),
      body: currentUser == null
          ? Center(child: Text('No user logged in'))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchInvitations(currentUser.uid),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                final invitations = snapshot.data ?? [];

                return ListView(
                  children: invitations.map((invitation) {
                    final eventData = invitation['eventData'];
                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          '${eventData['name']}',
                          style: TextStyle(
                              fontSize: heading3FontSize,
                              fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '\nStart Date: ${DateFormat('dd MMMM yyyy HH:mm').format(eventData['start_date'].toDate())}\nEnd Date: ${DateFormat('dd MMMM yyyy HH:mm').format(eventData['end_date'].toDate())}\nVenue: ${eventData['venue']}\nTicket Price: RM ${eventData['ticket_price']}\nStatus: ${invitation['invitationStatus']}',
                          style: TextStyle(color: description),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirm Accept Invitation'),
                                      content: Text(
                                          'Accept the invitation? The ticket price of RM ${eventData['ticket_price']} will be charged to your account.'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Yes'),
                                          onPressed: () {
                                            acceptInvitation(
                                                invitation['invitationId']);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('No'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirm Reject Invitation'),
                                      content: Text(
                                          'Are you sure you want to reject the invitation?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Yes'),
                                          onPressed: () {
                                            rejectInvitation(
                                                invitation['invitationId']);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('No'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}

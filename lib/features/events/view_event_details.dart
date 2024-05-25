import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invit/features/events/edit_event_details.dart';
import 'package:invit/features/invitations/send_invitations.dart';

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;

  EventDetailsScreen({required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventData['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Text(
                'Event Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                eventData['description'],
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 8),
                  Text(
                    'Start Date & Time: ${DateFormat('d MMM yyyy HH:mm').format(eventData['start_date'].toDate())}',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 8),
                  Text(
                    'End Date & Time: ${DateFormat('d MMM yyyy HH:mm').format(eventData['end_date'].toDate())}',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on),
                  SizedBox(width: 8),
                  Text(
                    'Venue: ${eventData['venue']}',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_money),
                  SizedBox(width: 8),
                  Text(
                    'Ticket Price: RM ${eventData['ticket_price']}',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people),
                  SizedBox(width: 8),
                  Text(
                    'Max Capacity: ${eventData['max_capacity']}',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock),
                  SizedBox(width: 8),
                  Text(
                    'Type: ${eventData['type']}',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (eventData['user_id'] ==
                  FirebaseAuth.instance.currentUser!.uid)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditEventScreen(eventData: eventData),
                          ),
                        );
                      },
                      child: Text('Edit Event Details'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SendInvitationPage(eventData: eventData),
                          ),
                        );
                      },
                      child: Text('Send Invitation'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

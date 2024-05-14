import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invit/features/events/edit_event_details.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Event Name: ${eventData['name']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Event Description: ${eventData['description']}',
              style: TextStyle(fontSize: 15),
            ),
            Text(
              'Start Date & Time: ${DateFormat('d MMM yyyy HH:mm').format(eventData['start_date'].toDate())}',
              style: TextStyle(fontSize: 15),
            ),
            Text(
              'End Date & Time: ${DateFormat('d MMM yyyy HH:mm').format(eventData['end_date'].toDate())}',
              style: TextStyle(fontSize: 15),
            ),
            Text(
              'Venue: ${eventData['venue']}',
              style: TextStyle(fontSize: 15),
            ),
            Text(
              'Ticket Price: ${eventData['ticket_price']}',
              style: TextStyle(fontSize: 15),
            ),
            Text(
              'Max Capacity: ${eventData['max_capacity']}',
              style: TextStyle(fontSize: 15),
            ),
            Text(
              'Type: ${eventData['type']}',
              style: TextStyle(fontSize: 15),
            ),
            // Text(
            //   'Event User ID: ${eventData['user_id']}',
            //   style: TextStyle(fontSize: 15),
            // ),
            // Text(
            //   'Current User ID: ${FirebaseAuth.instance.currentUser!.uid}',
            //   style: TextStyle(fontSize: 15),
            // ),
            if (eventData['user_id'] == FirebaseAuth.instance.currentUser!.uid)
              ElevatedButton(
                onPressed: () {
                  // Navigate to the edit event details screen
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
          ],
        ),
      ),
    );
  }
}

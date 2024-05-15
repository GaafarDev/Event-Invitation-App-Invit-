import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:invit/features/events/view_event_details.dart';

class OrganizerViewEventScreen extends StatefulWidget {
  @override
  _OrganizerViewEventScreenState createState() =>
      _OrganizerViewEventScreenState();
}

class _OrganizerViewEventScreenState extends State<OrganizerViewEventScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Created Events'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('user_id', isEqualTo: user!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          if (snapshot.data == null || !snapshot.hasData) {
            return Text("No data");
          }
          return ListView(
            children: (snapshot.data!).docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              data['id'] = document.id;
              return Padding(
                  padding: EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EventDetailsScreen(eventData: data),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          if (data['picture_url'] != null)
                            Image.network(
                              data['picture_url'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          else
                            Image.asset(
                              'assets/images/default_image.png',
                              width: 100,
                              height: 100,
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  data['name'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Date & Time: ${DateFormat(' HH:mm, d MMM yyyy').format(data['start_date'].toDate())} - ${DateFormat(' HH:mm, d MMM yyyy').format(data['end_date'].toDate())}',
                                  style: TextStyle(fontSize: 15),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Venue: ${data['venue']}',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            }).toList(),
          );
        },
      ),
    );
  }
}

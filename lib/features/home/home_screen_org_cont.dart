import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invit/features/events/view_event_details.dart';
import 'package:invit/features/subscription/getSubscription.dart';
import 'package:invit/shared/constants/assets_strings.dart';
import 'package:invit/shared/constants/colors.dart';

class HomePageOrgContent extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> getUserEvents() async {
    QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    List<Map<String, dynamic>> futureEvents = eventSnapshot.docs
        .map((QueryDocumentSnapshot doc) {
          // Cast the return value of doc.data() to Map<String, dynamic>
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

          // Check if data is null or doesn't contain the expected structure
          if (data == null || !data.containsKey('start_date')) {
            return null; // Return null if data is invalid
          }

          // Add id to data
          data['id'] = doc.id;

          // Convert start_date to DateTime
          Timestamp timestamp = data['start_date'] as Timestamp;
          DateTime startDate = timestamp.toDate();

          // Return data only if start_date is after current time
          return startDate.isAfter(DateTime.now()) ? data : null;
        })
        .where((data) => data != null) // Remove null elements from the list
        .map((data) => data as Map<String, dynamic>) // Cast null-safe maps
        .toList();

    return futureEvents;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No upcoming events.'));
        } else {
          return Container(
            height: MediaQuery.of(context).size.height,
            color: neutralLight4,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 20, bottom: 20),
                    child: Text(
                      'Upcoming Event',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 255,
                    child: ListView.separated(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final event = snapshot.data![index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailsScreen(
                                  eventData: event,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 237,
                            height: 500,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.only(
                                top: 20, left: 20, right: 20, bottom: 0),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        DefaultImage,
                                        width: 200,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          DateFormat('dd/MM').format(
                                            event['start_date'].toDate(),
                                          ),
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event['name'],
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_pin,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(width: 5),
                                              Flexible(
                                                child: Text(
                                                  event['venue'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => SizedBox(width: 20),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      width: double.infinity,
                      height: 130,
                      decoration: BoxDecoration(
                        color: button5,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text('Get Your Subscription Today!',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Text('Create Your Own Event!'),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            GetSubscription()),
                                  );
                                },
                                child: Text('Subscribe'),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.event_available,
                            size: 70,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invit/features/events/view_event_details.dart';
import 'package:invit/features/subscription/getSubscription.dart';
import 'package:invit/shared/constants/assets_strings.dart';
import 'package:invit/shared/constants/colors.dart';

class HomePageContent extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> getUserEvents() async {
    QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('type', isEqualTo: 'public')
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
        } else {
          return Container(
            height: MediaQuery.of(context).size.height,
            color: neutralLight4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
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
                  height: 255, // adjust height as needed
                  child: ListView.separated(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailsScreen(
                                eventData: snapshot.data![index]
                                    as Map<String, dynamic>, eventId: '',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 237,
                          height: 500, // adjust width as needed
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                20), // adjust radius as needed
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset:
                                    Offset(0, 3), // changes position of shadow
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
                                    borderRadius: BorderRadius.circular(
                                        20), // adjust radius as needed
                                    child: Image.asset(
                                      DefaultImage,
                                      width: 200,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10, // adjust as needed
                                    left: 10, // adjust as needed
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(
                                            10), // adjust radius as needed
                                      ),
                                      child: Text(
                                        DateFormat('dd/MM').format(snapshot
                                            .data?[index]['start_date']
                                            .toDate()),
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
                                          snapshot.data?[index]['name'],
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
                                            ), // this is the location icon
                                            SizedBox(
                                                width:
                                                    5), // add some space between the icon and the text
                                            Flexible(
                                              child: Text(
                                                snapshot.data?[index]['venue'],
                                                overflow: TextOverflow.ellipsis,
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
                  padding: EdgeInsets.all(10), // adjust as needed
                  child: Container(
                    width: double.infinity, // take full width
                    height: 130, // adjust as needed
                    decoration: BoxDecoration(
                      color: button5, // adjust color as needed
                      borderRadius:
                          BorderRadius.circular(10), // adjust radius as needed
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
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Create Your Own Event!'),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GetSubscription()),
                                );
                              },
                              child: Text('Subscribe'),
                            ),
                          ],
                        ),
                        Icon(
                          Icons
                              .event_available, // replace with your desired icon
                          size: 70, // adjust as needed
                          color: Colors.white, // adjust color as needed
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

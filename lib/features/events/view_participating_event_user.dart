import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invit/features/events/view_event_details.dart';
import 'package:invit/shared/constants/assets_strings.dart';
import 'package:invit/shared/constants/colors.dart';

class UserEventListView extends StatefulWidget {
  @override
  _UserEventListViewState createState() => _UserEventListViewState();
}

class _UserEventListViewState extends State<UserEventListView> {
  Future<Map<String, List<DocumentSnapshot>>> getUserEvents() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception('No user is currently logged in.');
    }

    QuerySnapshot participantSnapshot = await FirebaseFirestore.instance
        .collection('participants')
        .where('userId', isEqualTo: userId)
        .get();

    List<DocumentSnapshot> futureEvents = [];
    List<DocumentSnapshot> pastEvents = [];

    for (var participantDoc in participantSnapshot.docs) {
      String eventId = participantDoc['eventId'];
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
      eventData['id'] = eventDoc.id; // Add 'id' attribute to the event data

      Timestamp timestamp = eventDoc['start_date'];
      DateTime startDate = timestamp.toDate();
      if (startDate.isAfter(DateTime.now())) {
        futureEvents.add(eventDoc);
      } else {
        pastEvents.add(eventDoc);
      }
    }

    return {'futureEvents': futureEvents, 'pastEvents': pastEvents};
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
          Map<String, List<DocumentSnapshot<Object?>>>? eventLists =
              snapshot.data;
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0,
                      left: 10.0,
                      bottom: 10.0), // adjust the padding as needed
                  child: Text(
                    'My Participating Events',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Container(
                    height: 40,
                    width: 350,
                    decoration: BoxDecoration(
                      color: gray1,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.all(3.0), // adjust the padding as needed
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.white,
                        ),
                        unselectedLabelColor: Colors.grey,
                        labelColor: Colors.blueAccent,
                        tabs: [
                          Tab(text: 'UPCOMING EVENTS'),
                          Tab(text: 'PAST EVENTS'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              body: TabBarView(
                children: [
                  _buildEventList(eventLists!['futureEvents']),
                  _buildEventList(eventLists['pastEvents']),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildEventList(List<DocumentSnapshot<Object?>>? events) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
      ),
      child: ListView.separated(
        itemCount: events!.length,
        separatorBuilder: (context, index) => SizedBox(height: 20.0),
        itemBuilder: (context, index) {
          DocumentSnapshot event = events![index];
          Map<String, dynamic> eventData = event.data() as Map<String, dynamic>;
          eventData['id'] = event.id; // Add 'id' attribute to the event data
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(
                    eventData: eventData,
                  ),
                ),
              );
            },
            child: Container(
              width: 200,
              height: 300, // adjust width as needed
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20), // adjust radius as needed
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            20), // adjust radius as needed
                        child: Image.asset(
                          DefaultImage,
                          width: 320,
                          height: 170,
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
                            DateFormat('dd/MM')
                                .format(event['start_date'].toDate()),
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['name'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
                                    event['venue'],
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
      ),
    );
  }
}

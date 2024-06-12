import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invit/features/auth/login_screen.dart';
import 'package:invit/features/events/create_event_screen.dart';
import 'package:invit/features/events/view_event_details.dart';
import 'package:invit/features/events/view_org_event.dart';
import 'package:invit/features/finance/finance_screen.dart';
import 'package:invit/features/map/map_screen.dart';
import 'package:invit/shared/components/custom-drawer.dart';
import 'package:invit/shared/components/custom_navigationbar_org.dart';
import 'package:invit/shared/constants/assets_strings.dart';
import 'package:invit/shared/constants/colors.dart';

class HomePageOrg extends StatefulWidget {
  const HomePageOrg({Key? key, required bool isOrganizerView})
      : super(key: key);
  final bool isOrganizerView = true;
  @override
  State<HomePageOrg> createState() => _HomePageOrgState();
}

class _HomePageOrgState extends State<HomePageOrg> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;
  String searchString = '';
  final List<Widget> _children = [
    HomePageOrgContent(), // Replace with your actual saved screen widget
    ViewOrgEvent(),
    MapPage(), // Replace with your actual saved screen widget
    FinancePage(),
  ];

  void _signOut() async {
    try {
      await _auth.signOut();
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully signed out'),
          ),
        );
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } catch (e) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out'),
          ),
        );
      });
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          child: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              'Invit Organizer View',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            backgroundColor: button1,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 150.0, top: 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: <Widget>[
                            Center(
                                // child: Text(
                                //   'Invit Organizer View',
                                //   style: TextStyle(
                                //       color: Colors.white, fontSize: 20),
                                // ),
                                ),
                          ],
                        ),
                        SizedBox(width: 10.0),
                        TextButton(
                          style: TextButton.styleFrom(),
                          onPressed: _signOut,
                          child: Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(isOrganizerView: widget.isOrganizerView),
      body: Column(
        children: [
          Expanded(child: _children[_currentIndex]),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePageOrg(
                      isOrganizerView: true,
                    )),
            (Route<dynamic> route) => false,
          );
          Future.delayed(Duration.zero, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateEventScreen()),
            );
          });
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomNavigationBarOrg(
        onTap: onTabTapped,
      ),
    );
  }
}

class HomePageOrgContent extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> getUserEvents() async {
    QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    List<Map<String, dynamic>> futureEvents = eventSnapshot.docs
        .map((QueryDocumentSnapshot doc) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

          if (data == null || !data.containsKey('start_date')) {
            return null;
          }

          data['id'] = doc.id;
          Timestamp timestamp = data['start_date'] as Timestamp;
          DateTime startDate = timestamp.toDate();

          return startDate.isAfter(DateTime.now()) ? data : null;
        })
        .where((data) => data != null)
        .map((data) => data as Map<String, dynamic>)
        .toList();

    return futureEvents;
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    List<Map<String, dynamic>> allEvents = eventSnapshot.docs
        .map((QueryDocumentSnapshot doc) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

          if (data == null || !data.containsKey('start_date')) {
            return null;
          }

          data['id'] = doc.id;

          return data; // Return all events, regardless of their start date
        })
        .where((data) => data != null)
        .map((data) => data as Map<String, dynamic>)
        .toList();

    return allEvents;
  }

  Future<double> getTotalEarnings() async {
    double totalEarnings = 0.0;
    List<Map<String, dynamic>> events = await getAllEvents();

    for (var event in events) {
      QuerySnapshot participantsSnapshot = await FirebaseFirestore.instance
          .collection('participants')
          .where('eventId', isEqualTo: event['id'])
          .get();

      int participantCount = participantsSnapshot.docs.length;
      double eventEarnings =
          participantCount * (event['ticket_price'] as num).toDouble();
      totalEarnings += eventEarnings;
    }

    return totalEarnings;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: getTotalEarnings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Container(
            height: MediaQuery.of(context).size.height,
            color: neutralLight4,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EarningsCard(
                      totalEarnings:
                          snapshot.data ?? 0.0), // Pass totalEarnings here
                  Padding(
                    padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
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
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: getUserEvents(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No upcoming events.'));
                        } else {
                          return ListView.separated(
                            padding:
                                EdgeInsets.only(left: 15, right: 15, bottom: 5),
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
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                                color: Colors.orange
                                                    .withOpacity(0.5),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 20),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class EarningsCard extends StatefulWidget {
  final double totalEarnings;

  EarningsCard({required this.totalEarnings});

  @override
  _EarningsCardState createState() => _EarningsCardState();
}

class _EarningsCardState extends State<EarningsCard> {
  late String _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = _formatDateTime(DateTime.now());
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _formatDateTime(DateTime.now());
      });
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: button1,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Earning',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'RM${widget.totalEarnings.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 32.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Updated on $_currentTime',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

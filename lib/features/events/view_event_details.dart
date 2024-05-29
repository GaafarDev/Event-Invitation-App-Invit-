// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invit/features/events/edit_event_details.dart';
import 'package:invit/features/invitations/send_invitations.dart';
import 'package:invit/shared/constants/assets_strings.dart';
import 'package:invit/shared/constants/colors.dart';
import 'package:invit/shared/constants/sizes.dart';

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;

  EventDetailsScreen({required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text("Event Details"),
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: neutralLight4),
          titleTextStyle: TextStyle(
            color: neutralLight4,
            fontSize: heading2FontSize,
          ),
        ),
        backgroundColor: neutralLight4,
        body: SingleChildScrollView(
            child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                EventImage(
                  image: EventPicture,
                ),
                Positioned(
                  left: 40,
                  right: 40,
                  bottom: -30, // half the height of the container
                  child: Container(
                      width: 300, // specify the width
                      height: 60, // specify the height
                      decoration: BoxDecoration(
                        color: neutralLight4, // specify the color
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(
                              30), // specify the radius for the left side
                          right: Radius.circular(
                              30), // specify the radius for the right side
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 0, 0, 0)
                                .withOpacity(0.25),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 4), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            EventCapacity(
                                capacity: int.parse(
                                    eventData['max_capacity'].toString())),
                            SizedBox(width: 20),
                            EventType(type: eventData['type']),
                          ])),
                ),
              ],
            ),

            SizedBox(height: 35),
            //Title
            EventTitle(
              title: eventData["name"],
            ),
            SizedBox(height: 30),
            //Date
            EventDate(
              startDate: eventData['start_date'],
              endDate: eventData['end_date'],
            ),
            SizedBox(height: 10),
            //venue
            EventVenue(
              venue: eventData['venue'],
            ),
            SizedBox(height: 15),
            //Description
            EventDescription(
              desc: eventData['description'],
            ),
            SizedBox(height: 100),
            PurchaseTicketButton(
              eventId: eventData['id'],
              userId: FirebaseAuth.instance.currentUser!.uid,
              eventPrice: eventData['ticket_price'].toDouble(),
            ),
            SizedBox(height: 15),
          ],
        )));
  }
}

class EventImage extends StatelessWidget {
  const EventImage({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Image.asset(image,
        fit: BoxFit.cover,
        width: 600,
        height: 240,
        color: Colors.black.withOpacity(0.5),
        colorBlendMode: BlendMode.darken);
  }
}

class EventTitle extends StatelessWidget {
  const EventTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 10, 24, 10),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: heading1FontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class EventDate extends StatelessWidget {
  const EventDate({super.key, required this.startDate, required this.endDate});

  final Timestamp startDate;
  final Timestamp endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 10, 24, 10),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Image.asset(
            EventCalendar,
            width: 70,
            height: 70,
          ),
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('d MMM').format(startDate.toDate()) +
                      ' to ' +
                      DateFormat('d MMM, yyyy').format(endDate.toDate()),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  DateFormat('E h:mm a').format(startDate.toDate()) +
                      " - " +
                      DateFormat('E h:mm a').format(endDate.toDate()),
                  style: TextStyle(
                    fontSize: bodyText2FontSize,
                    color: description,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class EventVenue extends StatelessWidget {
  const EventVenue({super.key, required this.venue});

  final String venue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 10, 24, 10),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Image.asset(
            EventLocation,
            width: 70,
            height: 70,
          ),
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class EventDescription extends StatelessWidget {
  const EventDescription({super.key, required this.desc});

  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 10, 24, 10),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About Event",
            style: TextStyle(
              fontSize: heading2FontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 10),
          Text(
            desc,
            style: TextStyle(
              fontSize: heading5FontSize,
            ),
          )
        ],
      ),
    );
  }
}

class EventCapacity extends StatelessWidget {
  const EventCapacity({super.key, required this.capacity});

  final int capacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 10, 24, 10),
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.group,
            size: 30,
            color: button1,
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              capacity.toString(),
              style: TextStyle(
                  fontSize: heading5FontSize,
                  fontWeight: FontWeight.w600,
                  color: description),
            ),
          )
        ],
      ),
    );
  }
}

class EventType extends StatelessWidget {
  const EventType({Key? key, required this.type}) : super(key: key);

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 10, 24, 10),
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            type == 'public' ? Icons.public : Icons.lock,
            size: 30,
            color: button1,
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              type,
              style: TextStyle(
                  fontSize: heading5FontSize,
                  fontWeight: FontWeight.w600,
                  color: description),
            ),
          )
        ],
      ),
    );
  }
}

class PurchaseTicketButton extends StatelessWidget {
  const PurchaseTicketButton(
      {Key? key,
      required this.eventId,
      required this.userId,
      required this.eventPrice})
      : super(key: key);

  final String eventId;
  final String userId;
  final double eventPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ElevatedButton(
          onPressed: () {}, // Add your onPressed function here
          style: ElevatedButton.styleFrom(
            backgroundColor: button1, // Use the button1 color
            minimumSize: Size.fromHeight(60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Buy Ticket ", // Display the ticket price
                style: TextStyle(
                  fontSize: 20,
                  color: neutralLight4,
                ),
              ),
              Row(
                children: [
                  Text(
                    "RM " + eventPrice.toString(), // Display the ticket price
                    style: TextStyle(
                      fontSize: 20,
                      color: neutralLight4,
                    ),
                  ),
                  SizedBox(width: 15),
                  Icon(
                    Icons.arrow_forward,
                    color: neutralLight4,
                  ),
                ],
              ), // Display a right arrow
            ],
          ),
        ),
      ),
    );
  }
}

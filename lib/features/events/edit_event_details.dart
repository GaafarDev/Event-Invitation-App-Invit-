import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum EventType { public, private }

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  EditEventScreen({required this.eventData});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _eventNameController;
  late TextEditingController _eventDescriptionController;
  late DateTime _eventStartDate;
  late DateTime _eventEndDate;
  late TextEditingController _eventMaxCapacityController;
  late TextEditingController _ticketPriceController;
  late TextEditingController _venueController;
  late EventType _eventType;

  @override
  void initState() {
    super.initState();
    _eventNameController =
        TextEditingController(text: widget.eventData['name']);
    _eventDescriptionController =
        TextEditingController(text: widget.eventData['description']);
    _eventStartDate = widget.eventData['start_date'].toDate();
    _eventEndDate = widget.eventData['end_date'].toDate();
    _eventMaxCapacityController = TextEditingController(
        text: widget.eventData['max_capacity'].toString());
    _ticketPriceController = TextEditingController(
        text: widget.eventData['ticket_price'].toString());
    _venueController = TextEditingController(text: widget.eventData['venue']);
    _eventType = widget.eventData['type'] == 'public'
        ? EventType.public
        : EventType.private;
  }

  Future<DateTime?> _selectDateTime(
      BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(picked),
      );
      if (time != null) {
        return DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _eventNameController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
              ),
            ),
            // Text(
            //   'Event ID: ${widget.eventData['id']}',
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _eventDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Event Description',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 2,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: 'Venue Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Start Date & Time:'),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(
                    ' ${DateFormat('dd MMM yyyy HH:mm').format(_eventStartDate)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  child: Text('Select Start Date and Time'),
                  onPressed: () async {
                    final DateTime? picked =
                        await _selectDateTime(context, _eventStartDate);
                    if (picked != null) {
                      setState(() {
                        _eventStartDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('End Date & Time:'),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(
                    ' ${DateFormat('dd MMM yyyy HH:mm').format(_eventEndDate)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  child: Text('Select End Date and Time'),
                  onPressed: () async {
                    final DateTime? picked =
                        await _selectDateTime(context, _eventEndDate);
                    if (picked != null) {
                      setState(() {
                        _eventEndDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _eventMaxCapacityController,
              decoration: const InputDecoration(
                labelText: 'Max Capacity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _ticketPriceController,
              decoration: const InputDecoration(
                labelText: 'Ticket Price (RM)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24.0),
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<EventType>(
                    title: const Text('Public'),
                    value: EventType.public,
                    groupValue: _eventType,
                    onChanged: (EventType? value) {
                      setState(() {
                        _eventType = value!;
                      });
                    },
                  ),
                  RadioListTile<EventType>(
                    title: const Text('Private'),
                    value: EventType.private,
                    groupValue: _eventType,
                    onChanged: (EventType? value) {
                      setState(() {
                        _eventType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              child: const Text('Create Event'),
              onPressed: () {
                if (_eventNameController.text.isEmpty ||
                    _eventStartDate == null ||
                    _eventEndDate == null ||
                    _ticketPriceController.text.isEmpty ||
                    _venueController.text.isEmpty ||
                    _eventDescriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('All fields are mandatory!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (_eventStartDate.isBefore(DateTime.now())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Start date cannot be in the past'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (_eventStartDate.isAfter(_eventEndDate)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Start date cannot be after end date'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  final user = FirebaseAuth.instance.currentUser;
                  final eventCollection =
                      FirebaseFirestore.instance.collection('events');

                  eventCollection.doc(widget.eventData['id']).update({
                    'user_id': user!.uid,
                    'name': _eventNameController.text,
                    'start_date': _eventStartDate,
                    'end_date': _eventEndDate,
                    'ticket_price': double.parse(_ticketPriceController.text),
                    'venue': _venueController.text,
                    'description': _eventDescriptionController.text,
                    'max_capacity': _eventMaxCapacityController.text,
                    'type':
                        _eventType == EventType.public ? 'public' : 'private',
                  }).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Event details edited successfully')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to edit event: $error')),
                    );
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

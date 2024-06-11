import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:invit/features/events/view_event_details.dart';

class EventSearchPage extends StatefulWidget {
  @override
  _EventSearchPageState createState() => _EventSearchPageState();
}

class _EventSearchPageState extends State<EventSearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  String _selectedEventType = 'All';
  DateTimeRange? _selectedDateRange; // Allow _selectedDateRange to be null
  List<Event> _events = []; // Define _events variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Search')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Enter event's name or description here",
                //Got error with the _applyFilter function, so omitted it for now
                // suffixIcon: IconButton(
                //   icon: Icon(Icons.search),
                //   onPressed: _showSearchPopup,
                // ),
              ),
              onChanged: _updateSuggestions,
            ),
            if (_suggestions.isNotEmpty)
              Expanded(
                  child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('events')
                        .where('name', isEqualTo: _suggestions[index])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        DocumentSnapshot eventDoc = snapshot.data!.docs.first;
                        Map<String, dynamic> eventData =
                            eventDoc.data() as Map<String, dynamic>;
                        eventData['id'] =
                            eventDoc.id; // Add the document id to eventData

                        String name = eventData['name'] ?? '';
                        String description = eventData['description'] ?? '';
                        String venue = eventData['venue'] ?? '';
                        Timestamp? startTimestamp = eventData['start_date'];
                        DateTime? startDate = startTimestamp?.toDate();
                        Timestamp? endTimestamp = eventData['end_date'];
                        DateTime? endDate = endTimestamp?.toDate();
                        double? ticketPrice = eventData['ticket_price'];

                        return ListTile(
                          title: Text(
                            name,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description: ' + description),
                              Text('Venue: ' + venue),
                              if (startDate != null && endDate != null)
                                Text('Date: ' +
                                    DateFormat('d MMMM yyyy')
                                        .format(startDate) +
                                    ' - ' +
                                    DateFormat('d MMMM yyyy').format(endDate) +
                                    ', ' +
                                    DateFormat('h:mm a').format(startDate) +
                                    ' - ' +
                                    DateFormat('h:mm a').format(endDate)),
                              if (ticketPrice != null)
                                Text('Ticket Price: RM' +
                                    ticketPrice.toString()),
                            ],
                          ),
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
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        // While the data is loading, show a loading spinner
                        return CircularProgressIndicator();
                      }
                    },
                  );
                },
              ))
            // Add other filters (date range, event type) here
            // Display search results here
          ],
        ),
      ),
    );
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestions.clear();
      });
      return;
    }
    FirebaseFirestore.instance
        .collection('events')
        .where('type', isEqualTo: 'public')
        .get()
        .then((snapshot) {
      List<String> suggestions = snapshot.docs
          .map((doc) {
            String name = doc.data()['name'] as String;
            // Convert both the name and the query to lower case before comparing
            if (name.toLowerCase().contains(query.toLowerCase())) {
              return name;
            } else {
              return null;
            }
          })
          .where((name) => name != null)
          .cast<String>()
          .toList();
      setState(() {
        _suggestions = suggestions;
      });
    });
  }

  void _showSearchPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Event Type'),
                trailing: DropdownButton<String>(
                  value: _selectedEventType,
                  onChanged: (value) {
                    setState(() {
                      _selectedEventType = value!;
                    });
                  },
                  items: ['All', 'Public', 'Private'].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
              ),
              ListTile(
                title: Text('Date Range'),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: _selectDateRange,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Apply filters and close
                Navigator.of(context).pop();
                _applyFilters();
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _applyFilters() {
    String eventName = _searchController.text.toLowerCase();
    Query query = FirebaseFirestore.instance.collection('events');

    if (eventName.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: eventName)
          .where('name', isLessThanOrEqualTo: eventName + '\uf8ff');
    }

    if (_selectedEventType != 'All') {
      query = query.where('type', isEqualTo: _selectedEventType);
    }

    if (_selectedDateRange != null) {
      query = query
          .where('date', isGreaterThanOrEqualTo: _selectedDateRange!.start)
          .where('date', isLessThanOrEqualTo: _selectedDateRange!.end);
    }

    query.get().then((snapshot) {
      // Update UI with filtered results
      List<Event> events = snapshot.docs
          .map((doc) => Event.fromDocument(doc))
          .whereType<Event>() // Filter out null values
          .toList();
      setState(() {
        _events = events;
      });
    });
  }
}

// Define Event class
class Event {
  String? name;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  String? venue;
  double? ticketPrice;

  Event({
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.venue,
    this.ticketPrice,
  });

  static Event? fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>?;
    if (data != null) {
      String? name = data['name'];
      String? description = data['description'];
      Timestamp? startTimestamp = data['start_date'];
      DateTime? startDate = startTimestamp?.toDate();
      Timestamp? endTimestamp = data['end_date'];
      DateTime? endDate = endTimestamp?.toDate();
      String? venue = data['venue'];
      double? ticketPrice = data['ticket_price'];

      if (name != null &&
          description != null &&
          startDate != null &&
          endDate != null &&
          venue != null &&
          ticketPrice != null) {
        return Event(
          name: name,
          description: description,
          startDate: startDate,
          endDate: endDate,
          venue: venue,
          ticketPrice: ticketPrice,
        );
      }
    }
    return null;
  }
}

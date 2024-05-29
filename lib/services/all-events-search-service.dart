import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                hintText: 'Search by name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _showSearchPopup,
                ),
              ),
              onChanged: _updateSuggestions,
            ),
            if (_suggestions.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_suggestions[index]),
                    onTap: () async {
                      QuerySnapshot eventQuery = await FirebaseFirestore
                          .instance
                          .collection('events')
                          .where('name', isEqualTo: _suggestions[index])
                          .get();

                      if (eventQuery.docs.isNotEmpty) {
                        Map<String, dynamic>? maybeMap = eventQuery.docs.first
                            .data() as Map<String, dynamic>?;
                        if (maybeMap != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailsScreen(
                                eventData: maybeMap,
                              ),
                            ),
                          );
                        } else {
                          // Handle the situation where the map is null
                          // For example, show a dialog or a snackbar
                        }
                      } else {
                        // Handle the situation where no event with the given name was found
                        // For example, show a dialog or a snackbar
                      }
                    },
                  );
                },
              )
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
        .where('name', isEqualTo: query)
        .get()
        .then((snapshot) {
      List<String> suggestions =
          snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
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
    String eventName = _searchController.text;
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
  String name;
  String type;
  DateTime date;

  Event({required this.name, required this.type, required this.date});

  // Define fromDocument method
  static Event? fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    if (data != null) {
      String? name = data['name'];
      String? type = data['type'];
      Timestamp? timestamp = data['date'];
      DateTime? date = timestamp?.toDate();

      if (name != null && type != null && date != null) {
        return Event(name: name, type: type, date: date);
      }
    }
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:invit/shared/constants/colors.dart';

class CustomNavigationBar extends StatefulWidget {
  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 70.0, // Set the height of the Container
        width: 70.0, // Set the width of the Container
        child: FloatingActionButton(
          child: Icon(Icons.add,
              size: 40.0,
              color: neutralLight5), // Increase the size of the icon
          onPressed: () {},
          backgroundColor: button1,
          shape: CircleBorder(),
          elevation: 10.0, // Increase the elevation for a "raised" effect
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 5.0,
        height: 90.0,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.home,
                        color: _currentIndex == 0 ? Colors.blue : Colors.grey),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                  ),
                  Text('Home'),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.event,
                      color: _currentIndex == 1 ? Colors.blue : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                  ),
                  Text('Events'),
                ],
              ),
              SizedBox
                  .shrink(), // The dummy space for the floating action button
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.map,
                        color: _currentIndex == 2 ? Colors.blue : Colors.grey),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 2;
                      });
                    },
                  ),
                  Text('Map'),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.attach_money,
                        color: _currentIndex == 3 ? Colors.blue : Colors.grey),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 3;
                      });
                    },
                  ),
                  Text('Finance'),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.person,
                        color: _currentIndex == 4 ? Colors.blue : Colors.grey),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 4;
                      });
                    },
                  ),
                  Text('invitations'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

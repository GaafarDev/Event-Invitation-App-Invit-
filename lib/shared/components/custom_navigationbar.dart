import 'package:flutter/material.dart';
import 'package:invit/profile.dart';


class CustomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(icon: Icon(Icons.home), onPressed: () {}),
          IconButton(icon: Icon(Icons.list_alt), onPressed: () {}),
          SizedBox(width: 48), // The empty space in the middle
          IconButton(icon: Icon(Icons.notifications_on), onPressed: () {}),
          IconButton(
    icon: Icon(Icons.person),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Profile()), // Replace with your page class name
      );
    },
  ),

        ],
      ),
    );
  }
}

class MyFloatingActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add, size:32 ), // Larger icon size for the FAB
      onPressed: () {},
    );
  }
}

//To call the custom navigation bar
// bottomNavigationBar: CustomNavigationBar(),
// floatingActionButton: MyFloatingActionButton(),
// floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

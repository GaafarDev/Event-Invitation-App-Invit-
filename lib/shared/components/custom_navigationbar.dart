import 'package:flutter/material.dart';


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
          IconButton(icon: Icon(Icons.person), onPressed: () {}),
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

// bottomNavigationBar: CustomNavigationBar(),
//       floatingActionButton: MyFloatingActionButton(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

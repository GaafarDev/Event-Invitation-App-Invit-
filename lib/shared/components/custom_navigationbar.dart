import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class CustomNavigationBar extends StatefulWidget {
  final Function(int) onTap;

  CustomNavigationBar({required this.onTap});

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _bottomNavIndex = 0; //default index of a first screen

  final iconList = <IconData>[
    Icons.home,
    Icons.event,
    Icons.map,
    Icons.insert_invitation,
  ];

  final textList = <String>[
    'Home',
    'Events',
    'Map',
    'Invitation',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar.builder(
      itemCount: iconList.length,
      tabBuilder: (int index, bool isActive) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              iconList[index],
              size: 24,
              color: isActive ? Colors.blue : Colors.grey,
            ),
            Text(
              textList[index],
              style: TextStyle(color: isActive ? Colors.blue : Colors.grey),
            ),
          ],
        );
      },
      activeIndex: _bottomNavIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.verySmoothEdge,
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      onTap: (index) {
        setState(() {
          _bottomNavIndex = index;
        });
        widget.onTap(index);
      },
    );
  }
}

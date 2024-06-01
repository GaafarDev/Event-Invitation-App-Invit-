import 'package:flutter/material.dart';

class HomeScreenContOrg extends StatefulWidget {
  @override
  _HomeScreenContOrgState createState() => _HomeScreenContOrgState();
}

class _HomeScreenContOrgState extends State<HomeScreenContOrg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer Home Screen'),
      ),
      body: Center(
        child: Text('Edit this in features/home/home_screen_cont_org.dart'),
      ),
    );
  }
}

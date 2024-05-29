import 'package:firebase_core/firebase_core.dart';
import 'package:invit/features/subscription/getSubscription.dart';
import 'package:invit/features/events/create_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invit/features/home/home_screen.dart';
import 'package:invit/firebase_options.dart';
import 'package:invit/shared/constants/colors.dart';
import 'package:invit/features/auth/signup_screen.dart';
import 'features/auth/forget_password.dart';
import 'package:invit/shared/components/custom_navigationbar.dart';
import 'features/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        // When navigating to the "/second" route, build the SecondScreen widget.

        '/HomePageUser': (context) => HomePage(),
      },
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            // User is signed in, show the home screen
            return HomePage();
          } else {
            // User is not signed in, show the login screen
            return LoginScreen();
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:invit/features/events/create_event_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invit/features/auth/login_screen.dart';
// import 'package:invit/features/auth/registration_screen.dart';
import 'package:invit/shared/constants/colors.dart';
import 'package:invit/features/auth/signup_screen.dart';
import 'features/auth/forget_password.dart';
import 'package:invit/shared/components/custom_navigationbar.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      // home: CreateEventScreen(),
    );
  }
}

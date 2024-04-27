import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invit/features/auth/registration_screen.dart';
import 'package:invit/shared/constants/assets_strings.dart';
import 'package:invit/shared/constants/colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signInWithEmailAndPassword() async {
    try {
      final User? user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[300],
            content: Text('Successfully signed in as ${user.email}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[300],
            content: Text('No user found for that email and password'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[300],
          content: Text('Failed to sign in with Email & Password'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 2.0, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.asset(
              Applogo,
              height: 300,
              width: 100,
            ),
            SizedBox(height: 24.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: highlight2,
              ),
              child: Text(
                'Log In',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400),
              ),
              onPressed: _signInWithEmailAndPassword,
            ),
            SizedBox(height: 10.0),
            Divider(
              height: 2,
              thickness: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Don\'t have an account?'),
                // TextButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => SignUpScreen(),
                //       ),
                //     );
                //   },
                //   child: Text(
                //     'Sign Up',
                //     style: TextStyle(
                //       color: highlight2,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

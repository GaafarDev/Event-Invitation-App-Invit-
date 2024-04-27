import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  Future<void> sendPasswordResetEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Recovery email has been sent to ${_emailController.text}')),
        );
      } catch (e) {
        print(e); // Optionally catch and handle errors.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (_) {
                  sendPasswordResetEmail();
                },
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: sendPasswordResetEmail,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Back to Login'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invit/features/home/home_screen.dart';
import 'package:invit/features/profile/profile_screen.dart';
import 'package:invit/shared/constants/assets_strings.dart';
import 'package:invit/shared/constants/colors.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _userNameController = TextEditingController();

  // final TextEditingController _userNameController.text = _emailController.text.split('@')[0];
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  //FOr default sub

  String? _selectedGender;
  final _genderOptions = ['Male', 'Female'];

  // var UserName, PhoneNo, FullName, Gender, City, State, Country;
  @override
  void initState() {
    super.initState();
    _userNameController.text = _emailController.text;
  }

  void _signUpWithEmailAndPassword() async {
    try {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[300],
            content: Text('Passwords do not match'),
          ),
        );
        return;
      }

      final User? user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fullName': _fullNameController.text,
          'phoneNo': _phoneNoController.text,
          'gender': _selectedGender,
          'subDateEnd': Timestamp.fromDate(DateTime
              .now()), // Assuming you have a variable _selectedGender for gender
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[300],
            // content: Text('Successfully signed up as ${user.email}'),
            content: Text(
                // 'Successfully signed up as ${user.email} with ${_fullNameController.text} and ${_selectedGender}'),
                'Successfully signed up as ${user.email}'),
          ),
        );

        Navigator.pushReplacement(
          context,
          // MaterialPageRoute(builder: (context) => ProfileScreen()),
          MaterialPageRoute(
              builder: (context) => HomePage(
                    isOrganizerView: false,
                  )),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[300],
            content: Text('Failed to sign up.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[300],
          content: Text('Failed to sign up with error ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Hero(
            tag: 'Applogo',
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Image.asset(Applogo),
            )),
        title: Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 10.0, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _phoneNoController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: Colors.grey,
                  style: BorderStyle.solid,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedGender,
                  hint: Text('Select Gender'),
                  items: _genderOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(60),
                backgroundColor: highlight6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onPressed: _signUpWithEmailAndPassword,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invit/features/profile/edit_profile.dart';
import 'package:invit/shared/constants/colors.dart';
import 'package:invit/shared/constants/sizes.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late DocumentReference userDocRef; // Reference to the user's document
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final fullNameController = TextEditingController();
  final phoneNoController = TextEditingController();
  final emailController = TextEditingController(); // Pre-fill email
  final genderController = TextEditingController();
  final subscriptionEndController = TextEditingController();
  late String formattedDate; // Stores formatted subscription end date

  @override
  void initState() {
    super.initState();
    userDocRef = FirebaseFirestore.instance.collection('users').doc(user?.uid);
    _fetchData(); // Fetch initial data
  }

  void _fetchData() async {
    DocumentSnapshot snapshot = await userDocRef.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      fullNameController.text = data['fullName'];
      phoneNoController.text = data['phoneNo'];
      emailController.text = user?.email ?? ""; // Pre-fill email
      genderController.text = data['gender'];
      Timestamp subDateEnd = data['subDateEnd'];
      formattedDate = DateFormat('yyyy-MM-dd').format(subDateEnd.toDate());
      subscriptionEndController.text = formattedDate;
    }
  }

  void initiateEmailChange() async {
    if (user != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[200],
            content: Text(
                'A password reset email has been sent to your current email address.'),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[200],
            content: Text(e.message!),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[200],
          content: Text('Please sign in first.'),
        ),
      );
    }
  }

  // void changePassword() async {
  //   if (user != null) {
  //     final currentPassword = await showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text('Enter Current Password'),
  //         content: TextField(
  //           obscureText: true,
  //           decoration: InputDecoration(
  //             labelText: 'Current Password',
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () =>
  //                 Navigator.pop(context, currentPasswordController.text),
  //             child: Text('Confirm'),
  //           ),
  //         ],
  //       ),
  //     );
  //     if (currentPassword != null) {
  //       final credential =
  //           EmailAuthCredential(email: user!.email!, password: currentPassword);
  //       try {
  //         await user!.reauthenticateWithCredential(credential);
  //         final newPassword = await showDialog(
  //           context: context,
  //           builder: (context) => AlertDialog(
  //             title: Text('Enter New Password'),
  //             content: TextField(
  //               obscureText: true,
  //               decoration: InputDecoration(
  //                 labelText: 'New Password',
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: Text('Cancel'),
  //               ),
  //               TextButton(
  //                 onPressed: () =>
  //                     Navigator.pop(context, newPasswordController.text),
  //                 child: Text('Confirm'),
  //               ),
  //             ],
  //           ),
  //         );
  //         if (newPassword != null) {
  //           await user!.updatePassword(newPassword);
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               backgroundColor: Colors.green[200],
  //               content: Text('Password changed successfully!'),
  //             ),
  //           );
  //         } else {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               backgroundColor: Colors.red[200],
  //               content: Text('Please enter a new password.'),
  //             ),
  //           );
  //         }
  //       } on FirebaseAuthException catch (e) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             backgroundColor: Colors.red[200],
  //             content: Text(e.message!),
  //           ),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Colors.red[200],
  //           content: Text('Please enter your current password.'),
  //         ),
  //       );
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: Colors.red[200],
  //         content: Text('Please sign in first.'),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralLight4,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(fontSize: heading1FontSize),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Card(
                child: TextFormField(
                  decoration: InputDecoration(
                    fillColor: neutralLight5,
                    filled: true,
                    hintText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: gray1),
                    ),
                  ),
                  controller: fullNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 10.0),
              Card(
                child: TextFormField(
                  decoration: InputDecoration(
                    fillColor: neutralLight5,
                    filled: true,
                    hintText: 'Phone No',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: gray1),
                    ),
                  ),
                  controller: phoneNoController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 10.0),
              Card(
                child: TextFormField(
                  decoration: InputDecoration(
                    fillColor: neutralLight5,
                    filled: true,
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: gray1),
                    ),
                  ),
                  controller: emailController,
                  readOnly: true, // Keep email editing disabled
                ),
              ),
              SizedBox(height: 10.0),
              Card(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    fillColor: neutralLight5,
                    filled: true,
                    hintText: 'Gender',
                    prefixIcon: Icon(Icons.person),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0), // Add padding for better spacing
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: gray1),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your gender.';
                    }
                    return null;
                  },
                  items: [
                    DropdownMenuItem<String>(
                      value: 'Male',
                      child: Text('Male'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Female',
                      child: Text('Female'),
                    ),
                  ],
                  onChanged: (value) {
                    genderController.text =
                        value!; // Update the controller with selected value
                  },
                ),
              ),
              SizedBox(height: 10.0),
              Card(
                child: TextFormField(
                  decoration: InputDecoration(
                    fillColor: neutralLight5,
                    filled: true,
                    hintText: 'Subscription End Date',
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: gray1),
                    ),
                  ),
                  controller: subscriptionEndController,
                  readOnly: true, // Keep subscription end date editing disabled
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reset Password'),
                  TextButton(
                    onPressed: initiateEmailChange,
                    child: Text(
                      'Send Reset Link',
                      style: TextStyle(
                          color: highlight6, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 68.0),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  height: 50,
                  width: 400,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: button1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Save',
                            style: TextStyle(color: neutralLight5),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_forward_ios,
                              color: neutralLight5),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Update user information in Firestore (excluding email)
                        await userDocRef.update({
                          'fullName': fullNameController.text,
                          'phoneNo': phoneNoController.text,
                          'gender': genderController.text,
                        });

                        // Show success message (optional)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green[200],
                            content: Text('Profile updated successfully!'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red[200],
                            content: Text('Something Wrong!'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              //Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //children: [
              //Text('Change Password'),
              // TextButton(
              //onPressed: changePassword,
              //   child: Text(
              //     'Change Password',
              //     style: TextStyle(color: button1),
              //   ),
              // ),
              // ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

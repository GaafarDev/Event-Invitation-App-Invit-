// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:invit/shared/constants/assets_strings.dart';
import 'package:invit/shared/constants/colors.dart';
import 'package:invit/shared/constants/sizes.dart';
import 'package:invit/shared/constants/text_strings.dart';

class GetSubscription extends StatefulWidget {
  @override
  State<GetSubscription> createState() => _GetSubscriptionState();
}

class _GetSubscriptionState extends State<GetSubscription> {
  String selectedPlan = ''; // Variable to store the selected plan

  @override
  Widget build(BuildContext context) {
    final buttonWidth = 400.0; // Width same as "Buy Now" button

    return Scaffold(
      backgroundColor: neutralLight4,
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 10.0, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              subscriptionTitle,
              style: TextStyle(
                fontSize: heading1FontSize,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: Text(
                titleDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: bodyText2FontSize,
                ),
              ),
            ),
            Center(
              child: Image.asset(
                SubscriptionIcon,
                width: 300,
                height: 300,
              ),
            ),
            SizedBox(height: 10.0),
            _buildSubscriptionButton(
              planName: 'Add 1 Year',
              price: '\$99.99 For One Year',
              duration: Duration(days: 365), // Update subscription by 1 year
              onPressed: () => setState(() => selectedPlan = 'Add 1 Year'),
              width: buttonWidth,
            ),
            SizedBox(height: 10.0),
            _buildSubscriptionButton(
              planName: 'Add 1 Month',
              price: '\$15.99 For One Month',
              duration: Duration(days: 30), // Update subscription by 1 month
              onPressed: () => setState(() => selectedPlan = 'Add 1 Month'),
              width: buttonWidth,
            ),
            SizedBox(height: 15.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                height: 50,
                width: buttonWidth, // Same width as subscription buttons
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
                          'Buy Now',
                          style: TextStyle(color: neutralLight5),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child:
                            Icon(Icons.arrow_forward_ios, color: neutralLight5),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    if (selectedPlan.isEmpty) {
                      // Show error message if no plan is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a subscription plan.'),
                        ),
                      );
                      return;
                    }

                    // Update subscription due date in Firebase based on selected plan
                    await updateSubscriptionDueDate(selectedPlan);

                    // Handle successful update (optional)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Subscription updated successfully!'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionButton({
    required String planName,
    required String price,
    required Duration duration,
    required VoidCallback onPressed,
    required double width,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: selectedPlan == planName ? button1 : highlight7,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: button1,
          width: selectedPlan == planName ? 2.0 : 1.0,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize:
              Size(width, 50.0), // Set minimum size for consistent width
          maximumSize:
              Size(width, 50.0), // Set maximum size for consistent width
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            // Change Column to Row for horizontal layout
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space evenly
            children: <Widget>[
              Text(
                planName,
                style: TextStyle(
                  fontSize: heading5FontSize,
                  fontWeight: FontWeight.w600,
                  color:
                      selectedPlan == planName ? neutralLight5 : Colors.black,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: bodyText1FontSize,
                  color:
                      selectedPlan == planName ? neutralLight5 : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Replace this with your actual function to update subscription due date in Firebase
  Future<void> updateSubscriptionDueDate(String selectedPlan) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Calculate new subscription end date based on selected plan
    DateTime newSubDateEnd;
    if (selectedPlan == 'Add 1 Year') {
      newSubDateEnd = DateTime.now().add(Duration(days: 365));
    } else if (selectedPlan == 'Add 1 Month') {
      newSubDateEnd = DateTime.now().add(Duration(days: 30));
    } else {
      throw Exception('Invalid plan selected');
    }

    // Update subDateEnd in Firebase
    await firestore.collection('users').doc(user?.uid).update({
      'subDateEnd': Timestamp.fromDate(newSubDateEnd),
    });
  }
}

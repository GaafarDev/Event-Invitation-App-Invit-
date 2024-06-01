import 'package:flutter/material.dart';

class FinancePage extends StatefulWidget {
  @override
  _FinancePageState createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Page'),
      ),
      body: Center(
        child: Text('Edit this in features/finance/finance_screen.dart'),
      ),
    );
  }
}

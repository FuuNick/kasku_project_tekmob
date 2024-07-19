import 'package:flutter/material.dart';
import 'package:financial_management_app/screens/home_screen.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(FinancialManagementApp());
}

class FinancialManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        length: 2,
        child: HomeScreen(),
      ),
    );
  }
}
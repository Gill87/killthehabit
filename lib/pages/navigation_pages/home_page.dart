import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  

  void appLimitDialog() {

  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('No Habits Found'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appLimitDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
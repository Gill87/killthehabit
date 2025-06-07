import 'package:flutter/material.dart';

class LargeTextField extends StatelessWidget {

  final TextEditingController controller;
  final String hintText;

  // Constructor for LargeTextField
  const LargeTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  bool isPasswordField() {
    if(hintText == "Confirm Password" || hintText == "Password"){
      return true;
    } else {
      return false;
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        obscureText: isPasswordField(),
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          hintText: hintText,
        ),
      ),
    );
  }
}
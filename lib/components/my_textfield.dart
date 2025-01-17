import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;

  const MyTextField({
    super.key,
    required this.hintText,  
    required this.obscureText,
    required this.controller,
    this.focusNode
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Reduce height and add right padding
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0), // Add rounded corners
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          ),   
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0), // Add rounded corners
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
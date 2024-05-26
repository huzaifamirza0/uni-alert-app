import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? errorText;
  final bool obscureText;
  final Icon preIcon;
  final VoidCallback? onPressed;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    required this.controller,
    required this.labelText,
    required this.preIcon,
    this.errorText,
    this.obscureText = false,
    this.onPressed,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (value) {
        onChanged?.call(value);
      },
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.greenAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.black),
        ),
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        prefixIcon: IconButton(
          icon: preIcon,
          onPressed: () {  },

        ),
        suffixIcon: onPressed != null
            ? IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: onPressed,
        )
            : null,
      ),
    );
  }
}

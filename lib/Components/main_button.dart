import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color buttonColor;
  final Color iconColor;
  final VoidCallback onPressed;
  final TextStyle textStyle; // Added textStyle parameter

  SquareButton({
    required this.icon,
    required this.text,
    required this.buttonColor,
    required this.iconColor,
    required this.onPressed,
    required this.textStyle, // Added textStyle parameter
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 46,
              color: iconColor, // Use the provided icon color
            ),
            const SizedBox(height: 8), // Increase the space between icon and text
            Text(
              text,
              style: textStyle, // Use the provided textStyle
              textAlign: TextAlign.center, // Center-align the text
            ),
          ],
        ),
      ),
    );
  }
}

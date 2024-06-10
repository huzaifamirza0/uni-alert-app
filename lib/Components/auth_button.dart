import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final IconData icon;
  final Color iconColor;
  final Color color;
  final Color borderColor;
  final VoidCallback onPressed;

  const AuthButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: iconColor),
      label: Text(text, style: TextStyle(color: textColor, fontSize: 16)),
      style: ElevatedButton.styleFrom(
        side: BorderSide(color: borderColor, width: 2),
        primary: color,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onPressed,
    );
  }
}

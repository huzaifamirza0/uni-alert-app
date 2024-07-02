import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final String? iconAsset;
  final IconData? icon;
  final Color iconColor;
  final Color color;
  final Color borderColor;
  final VoidCallback onPressed;

  const AuthButton({
    Key? key,
    required this.text,
    this.iconAsset,
    this.icon,
    required this.color,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.onPressed,
  }) : assert(iconAsset != null || icon != null, 'Either iconAsset or icon must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: iconAsset != null
          ? SvgPicture.asset(
        iconAsset!,
        height: 24,
        width: 24,
      )
          : Icon(icon, color: iconColor),
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

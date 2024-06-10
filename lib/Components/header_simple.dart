import 'package:flutter/material.dart';

class HeaderSimple extends StatelessWidget {
  final Icon leftIcon;
  final String title;
  final Icon rightIcon;
  final VoidCallback? onLeftIconPressed;
  final VoidCallback? onRightIconPressed;
  final Color titleColor;

  const HeaderSimple({
    Key? key,
    required this.leftIcon,
    required this.title,
    required this.rightIcon,
    this.onLeftIconPressed,
    this.onRightIconPressed,
    this.titleColor = Colors.black, // Default title color is black
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildHeaderTile(context);
  }

  Widget _buildHeaderTile(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withOpacity(0.2),
          ),
          child: IconButton(
            icon: leftIcon,
            onPressed: onLeftIconPressed ?? () => Navigator.of(context).pop(), // Back button action
          ),
        ),
        const SizedBox(width: 16), // Adjust as needed
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(width: 16), // Adjust as needed
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withOpacity(0.2),
          ),
          child: IconButton(
            icon: rightIcon,
            onPressed: onRightIconPressed, // Action for the right icon button
          ),
        ),
      ],
    );
  }
}

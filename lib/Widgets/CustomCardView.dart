import 'package:flutter/material.dart';

class CustomCardView extends StatelessWidget 
{
  final Widget child;
  final Color? backgroundColor;

  const CustomCardView({super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) 
  {
    return Card
    (
      elevation: 4.0,
      shape: RoundedRectangleBorder
      (
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: const Color(0xFF303030),
      child: Padding
      (
        padding: const EdgeInsets.all(16.0),
        child: child,
      )
    );
  }
}
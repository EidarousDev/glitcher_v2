import 'package:flutter/material.dart';
import 'package:glitcher/style/colors.dart';

class VerifiendBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kPrimary,
      ),
      child: Icon(
        Icons.done,
        size: 10,
        color: Colors.white,
      ),
      width: 13,
      height: 13,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:glitcher/ui/style/colors.dart';

class ScrollToTop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      height: 35,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: kPrimary,
      ),
      width: 100,
      padding: EdgeInsets.all(8),
      child: Text('Scroll to top'),
    );
  }
}

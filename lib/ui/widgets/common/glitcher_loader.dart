import 'package:flutter/material.dart';
import 'package:glitcher/constants/strings.dart';

class GlitcherLoader extends StatelessWidget {
  const GlitcherLoader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image.asset(
      Strings.loader,
      height: 250,
      width: 250,
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:glitcher/constants/strings.dart';

class LogoWithText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Strings.logo_with_text,
      height: 260.0,
    );
  }
}

class GlitcherLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        key: Key('loader'),
        content: Center(
            child: Image.asset(
          Strings.loader,
          height: 200,
        )),
        backgroundColor: Colors.transparent,
        elevation: 0.0);
  }
}

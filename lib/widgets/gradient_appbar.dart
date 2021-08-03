import 'package:flutter/material.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/models/app_model.dart';
import 'package:glitcher/utils/functions.dart';
import 'package:provider/provider.dart';

Widget gradientAppBar(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              Provider.of<AppModel>(context, listen: false).darkTheme == false
                  ? <Color>[MyColors.lightCardBG, MyColors.lightBG]
                  : <Color>[MyColors.darkCardBG, MyColors.darkBG]),
      boxShadow: [
        BoxShadow(
          color: switchColor(context, MyColors.lightPrimary, MyColors.darkBG),
          blurRadius: 1.0, // has the effect of softening the shadow
          spreadRadius: 0, // has the effect of extending the shadow
          offset: Offset(
            1.0, // horizontal, move right 10
            1.0, // vertical, move down 10
          ),
        )
      ],
    ),
  );
}

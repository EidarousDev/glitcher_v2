import 'package:flutter/material.dart';

import 'colors.dart';
import 'light_theme.dart';

ThemeData buildDarkTheme(String language, [String fontFamily]) {
  final base = ThemeData.dark();
  return base.copyWith(
    primaryIconTheme: IconThemeData(color: kPrimary),
    textTheme: buildTextTheme(base.textTheme, language, fontFamily).apply(
      displayColor: kLightBG,
      bodyColor: kLightBG,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kPrimary,
    ),
    primaryTextTheme:
        buildTextTheme(base.primaryTextTheme, language, fontFamily).apply(
      displayColor: kLightBG,
      bodyColor: kLightBG,
    ),
    accentTextTheme:
        buildTextTheme(base.accentTextTheme, language, fontFamily).apply(
      displayColor: kLightBG,
      bodyColor: kLightBG,
    ),
    iconTheme: IconThemeData(color: Colors.white),
    dividerColor: kDarkDivider,
    canvasColor: kDarkBG,
    cardColor: kDarkCard,
    brightness: Brightness.dark,
    backgroundColor: kDarkBG,
    primaryColor: kPrimary,
    primaryColorLight: kPrimary,
    accentColor: kDarkAccent,
    scaffoldBackgroundColor: kDarkBG,
    appBarTheme: const AppBarTheme(
      backgroundColor: kDarkCard,
      elevation: 0,
      textTheme: TextTheme(
        headline6: TextStyle(
          color: kDarkTextLight,
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
        ),
      ),
      iconTheme: IconThemeData(
        color: kDarkAccent,
      ),
    ),
    buttonTheme: ButtonThemeData(
        colorScheme: kColorScheme.copyWith(onPrimary: kLightBG)),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    }),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white,
      labelPadding: EdgeInsets.zero,
      labelStyle: TextStyle(fontSize: 13),
      unselectedLabelStyle: TextStyle(fontSize: 13),
    ),
  );
}

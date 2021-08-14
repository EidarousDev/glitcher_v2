import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glitcher/services/remote_config_service.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppModel with ChangeNotifier {
  ThemeMode themeMode;
  bool get darkTheme => themeMode == ThemeMode.dark;

  set darkTheme(bool value) =>
      themeMode = value ? ThemeMode.dark : ThemeMode.light;

  PackageInfo _packageInfo;

  PackageInfo get packageInfo => _packageInfo;

  bool _newUpdateExists;

  bool get newUpdateExists => _newUpdateExists;

  Future<void> getPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  Future getThemeFromPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.get(
      'darkTheme',
    );
    this.darkTheme = isDark ?? true;
  }

  Future<void> updateTheme(bool theme) async {
    try {
      darkTheme = theme;
      themeMode = theme ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
      var prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkTheme', theme);
    } catch (error) {
      print('[updateTheme] error: ${error.toString()}');
    }
  }

  Future<bool> checkForUpdates(int build) async {
    bool newUpdateExists;
    var version = jsonDecode(await RemoteConfigService.getString('version'));
    newUpdateExists = version['build'] > build;
    _newUpdateExists = newUpdateExists;
    if (newUpdateExists) return true;
    return false;
  }
}

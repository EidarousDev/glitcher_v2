import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/models/app_model.dart';
import 'package:glitcher/models/user_model.dart';
import 'package:glitcher/services/auth.dart';
import 'package:glitcher/services/auth_provider.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/style/colors.dart';
import 'package:glitcher/style/dark_theme.dart';
import 'package:glitcher/style/light_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AppModel _app = AppModel();
  User _userModel = User();
  await _app.getThemeFromPrefs();
  await _app.getPackageInfo();
  await _app.checkForUpdates(int.parse(_app.packageInfo.buildNumber));
  runApp(MyApp(
    appModel: _app,
    userModel: _userModel,
  ));
}

Future<void> retrieveDynamicLink(BuildContext context) async {
  final PendingDynamicLinkData data =
      await FirebaseDynamicLinks.instance.getInitialLink();
  final Uri deepLink = data?.link;

  if (deepLink != null) {
    Navigator.pushNamed(context, deepLink.path);
    return deepLink.toString();
  }
}

class MyApp extends StatefulWidget {
  final AppModel appModel;
  final User userModel;

  const MyApp({Key key, this.appModel, this.userModel}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    retrieveDynamicLink(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppModel>(
          create: (context) => widget.appModel,
        ),
        ChangeNotifierProvider<User>(
          create: (context) => widget.userModel,
        )
      ],
      child: Builder(
        builder: (
          context,
        ) {
          return AuthProvider(
            auth: Auth(),
            child: Consumer<AppModel>(
              builder: (context, appModel, child) => MaterialApp(
                title: widget.appModel.packageInfo.appName,
                debugShowCheckedModeBanner: false,
                theme: getTheme(context),
                initialRoute: RouteList.initialRoute,
                onGenerateRoute: RouteGenerator.generateRoute,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    Firebase.initializeApp().whenComplete(() {
      print("Firebase Initialized!");
      setState(() {});
    });
    super.initState();
  }

  /// Build the App Theme
  ThemeData getTheme(context) {
    var isDarkTheme = widget.appModel.darkTheme ?? true;
    var fontFamily = 'Roboto';
    if (isDarkTheme) {
      return buildDarkTheme('en', fontFamily).copyWith(
        primaryColor: kPrimary,
      );
    }
    return buildLightTheme('en', fontFamily).copyWith(
      primaryColor: MyColors.lightPrimary,
    );
  }
}

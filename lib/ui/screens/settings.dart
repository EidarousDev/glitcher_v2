import 'package:flutter/material.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/constants/strings.dart';
import 'package:glitcher/data/models/app_model.dart';
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/style/colors.dart';
import 'package:glitcher/ui/widgets/common/gradient_appbar.dart';
import 'package:glitcher/utils/app_util.dart';
import 'package:glitcher/utils/functions.dart';
import 'package:provider/provider.dart';

import '../widgets/common/custom_loader.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int filter = 0;

  bool _isSubscribedToNewsletter = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _isAccountPrivate = false;

  isSubscribedToNewsletter() async {
    bool isSubscribed =
        (await newsletterEmailsRef.doc(Constants.currentUserID).get()).exists;
    setState(() {
      _isSubscribedToNewsletter = isSubscribed;
    });
    return isSubscribed;
  }

  isAccountPrivate() async {
    bool isPrivate = (await DatabaseService.getUserWithId(
            Constants.currentUserID,
            checkLocal: false))
        .isAccountPrivate;
    setState(() {
      _isAccountPrivate = isPrivate ?? false;
    });
    return isPrivate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(Strings.settings),
        flexibleSpace: gradientAppBar(context),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  children: [
                    Text('Dark theme'),
                    SizedBox(
                      width: 10,
                    ),
                    Switch(
                      activeColor: kPrimary,
                      key: Key('theme'),
                      value: Provider.of<AppModel>(context, listen: false)
                          .darkTheme,
                      onChanged: (bool value) {
                        Provider.of<AppModel>(context, listen: false)
                            .updateTheme(value);
                      },
                    ),
                  ],
                )),
            Divider(
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16),
              child: Text(
                'Favourite Feed filter: ',
                style: titleTextStyle(),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Radio(
                        activeColor: MyColors.darkPrimary,
                        value: 0,
                        groupValue: filter,
                        onChanged: (value) {
                          setFavouriteFilter(context, value);
                          setState(() {
                            filter = value;
                          });
                        }),
                    Text(
                      'Recent Posts',
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Radio(
                        activeColor: MyColors.darkPrimary,
                        value: 1,
                        groupValue: filter,
                        onChanged: (value) {
                          setFavouriteFilter(context, value);
                          setState(() {
                            filter = value;
                          });
                        }),
                    Text(
                      'Followed Gamers',
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Radio(
                        activeColor: MyColors.darkPrimary,
                        value: 2,
                        groupValue: filter,
                        onChanged: (value) {
                          setFavouriteFilter(context, value);
                          setState(() {
                            filter = value;
                          });
                        }),
                    Text(
                      'Followed Games',
                    ),
                  ],
                )
              ],
            ),
            Divider(
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16),
              child: Row(
                children: [
                  Text(
                    'Subscribed to newsletter? : ',
                    style: titleTextStyle(),
                  ),
                  Checkbox(
                    checkColor: Colors.white,
                    activeColor: MyColors.darkPrimary,
                    onChanged: (value) async {
                      await alterNewsletterState();
                    },
                    value: _isSubscribedToNewsletter,
                  )
                ],
              ),
            ),
            Divider(
              height: 2,
            ),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Account Privacy',
                  style: titleTextStyle(),
                ),
              ),
              subtitle: Text(
                  'Other users  won\'t be able to see  your following, followers, friends, and followed games'),
              trailing: Switch(
                  key: Key('privacy'),
                  activeColor: kPrimary,
                  value: _isAccountPrivate,
                  onChanged: (value) async {
                    await alternateAccountPrivate();
                  }),
            ),
            Divider(
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16),
              child: MaterialButton(
                color: switchColor(
                    context, MyColors.lightPrimary, MyColors.darkPrimary),
                child: Text(
                  'Change Password',
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteList.passwordChange);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  TextStyle titleTextStyle() {
    return TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  }

  alterNewsletterState() async {
    Navigator.of(context).push(CustomScreenLoader());

    bool isSubscribed = await isSubscribedToNewsletter();
    if (isSubscribed) {
      await newsletterEmailsRef.doc(Constants.currentUserID).delete();
      setState(() {
        _isSubscribedToNewsletter = false;
      });
      AppUtil.showSnackBar(context, 'Unsubscribed from newsletter');
    } else {
      await DatabaseService.addUserEmailToNewsletter(Constants.currentUserID,
          Constants.currentUser.email, Constants.currentUser.username);
      setState(() {
        _isSubscribedToNewsletter = true;
      });
      Navigator.of(context).pop();

      AppUtil.showSnackBar(context, 'Subscribed to newsletter');
    }
  }

  alternateAccountPrivate() async {
    Navigator.of(context).push(CustomScreenLoader());
    bool isPrivate = await isAccountPrivate() ?? false;

    await usersRef
        .doc(Constants.currentUserID)
        .update({'is_account_private': !isPrivate});

    setState(() {
      _isAccountPrivate = !isPrivate;
    });
    Navigator.of(context).pop();
    AppUtil.showSnackBar(context, 'Privacy changed!');
  }

  @override
  void initState() {
    setState(() {
      filter = Constants.favouriteFilter;
    });

    isSubscribedToNewsletter();
    isAccountPrivate();
    super.initState();
  }
}

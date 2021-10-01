import 'package:flutter/material.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/constants/strings.dart';
import 'package:glitcher/data/models/app_model.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/ui/widgets/gradient_appbar.dart';
import 'package:provider/provider.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  // If you want to edit any of the listItems,
  // make sure you edit its link in the itemsRoute

  List<String> listItems = [
    'Help Center',
    'Terms of service',
    'Privacy policy',
    'Cookie use',
    'Legal notices'
  ];

  List<String> itemsRoute = [
    RouteList.helpCenter,
    RouteList.termsOfService,
    RouteList.privacyPolicy,
    RouteList.cookieUse,
    RouteList.legalNotices
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.about_us),
        flexibleSpace: gradientAppBar(context),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
                'Version ${Provider.of<AppModel>(context, listen: false).packageInfo.version}'),
          ),
          Divider(
            height: 1.0,
            color: MyColors.darkLineBreak,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: listItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed(itemsRoute[index]);
                    },
                    title: Text(listItems[index]),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

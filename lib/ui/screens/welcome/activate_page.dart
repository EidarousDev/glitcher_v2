import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/ui/style/colors.dart';
import 'package:glitcher/ui/widgets/common/gradient_appbar.dart';
import 'package:glitcher/utils/app_util.dart';

import '../../widgets/common/logo_widgets.dart';

class ActivatePage extends StatelessWidget {
  final String email;
  final User user;

  const ActivatePage({Key key, this.email, this.user}) : super(key: key);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Activate email'),
        flexibleSpace: gradientAppBar(context),
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Icon(Icons.arrow_back),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GlitcherLoader(),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16.0,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text:
                          'To get started, we need to confirm your email address. ',
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w900)),
                  TextSpan(text: 'We sent an email to you at '),
                  TextSpan(
                      text: email,
                      style: TextStyle(
                          color: kPrimary, fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          '. Please click the link in the email to finish creating your account.')
                ],
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            MaterialButton(
              minWidth: 300.0,
              color: kPrimary,
              onPressed: () => sendActivationEmail(context),
              child: Text('Resend email', style: TextStyle(fontSize: 17.0)),
            ),
            MaterialButton(
                minWidth: 300.0,
                color: kPrimary,
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(RouteList.initialRoute),
                child: Text('OK, I tapped the link',
                    style: TextStyle(fontSize: 17.0))),
          ],
        ),
      ),
    );
  }

  Future<void> sendActivationEmail(BuildContext context) async {
    try {
      await user.sendEmailVerification();
    } catch (e) {
      AppUtil.alertDialog(
          context: context,
          heading: 'Failure',
          message: e.toString(),
          okBtn: 'Ok',
          onSuccess: () {}); // Stay on the same page
    }

    AppUtil.alertDialog(
        context: context,
        heading: 'Verification Email Sent!',
        message:
            'Please check your Inbox and click on the link in the message to activate your account.',
        okBtn: 'Ok',
        onSuccess: () {}); // Go back to login_page
  }
}

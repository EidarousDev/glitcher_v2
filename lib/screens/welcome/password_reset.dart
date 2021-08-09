import 'package:flutter/material.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/models/user_model.dart';
import 'package:glitcher/screens/welcome/widgets/bezier_container.dart';
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/utils/app_util.dart';
import 'package:glitcher/widgets/logo_widgets.dart';

class PasswordResetScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer()),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        LogoWithText(),
                        SizedBox(height: 50),
                        _entryField('E-Mail'),
                        SizedBox(height: 20),
                        _submitButton(context),
                        SizedBox(height: 100.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(top: 40, left: 0, child: _backButton(context))
            ],
          ),
        ));
  }

  Widget _entryField(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextFormField(
                controller: _emailController,
                // onChanged: (value) {
                //   _email = value;
                // },
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: MyColors.darkCardBG),
                decoration: InputDecoration(
                    prefixIcon: Container(
                        width: 48,
                        child: Icon(
                          Icons.email,
                          size: 18,
                          color: Colors.grey.shade400,
                        )),
                    hintText: 'E-mail',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    fillColor: Color(0xfff3f3f4),
                    filled: true)),
          )
        ],
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        AppUtil.showGlitcherLoader(context);
        User user =
            await DatabaseService.getUserWithEmail(_emailController.text);
        if (user.id == null) {
          //print('Email is not registered!');
          Navigator.pop(context); // Dismiss the loader dialog
          AppUtil.showSnackBar(context, 'Email is not registered!');
        } else {
          try {
            await firebaseAuth.sendPasswordResetEmail(
                email: _emailController.text);
            //print('Password reset e-mail sent');
            Navigator.pop(context); // Dismiss the loader dialog
            AppUtil.alertDialog(
                context: context,
                heading: 'Success',
                message: 'Password reset e-mail sent',
                okBtn: 'Done',
                onSuccess: () =>
                    Navigator.pop(context)); // Go back to login_page
          } catch (e) {
            Navigator.pop(context); // Dismiss the loader dialog
            AppUtil.alertDialog(
                context: context,
                heading: 'Failure',
                message: e.toString(),
                okBtn: 'Ok',
                onSuccess: () =>
                    Navigator.pop(context)); // Go back to login_page
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerRight,
                colors: [MyColors.darkCardBG, MyColors.darkPrimary])),
        child: Text(
          'Reset Password',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

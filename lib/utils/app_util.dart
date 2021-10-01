import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/constants/strings.dart';
import 'package:glitcher/data/models/app_model.dart';
import 'package:glitcher/data/models/hashtag_model.dart';
import 'package:glitcher/data/models/user_model.dart';
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/services/notification_handler.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/ui/widgets/fluttertoast.dart';
import 'package:glitcher/ui/widgets/logo_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'functions.dart';

class AppUtil {
  static final AppUtil _instance = new AppUtil.internal();
  static bool networkStatus;

  AppUtil.internal();

  factory AppUtil() {
    return _instance;
  }

  static checkForUpdates(BuildContext context) {
    if (Provider.of<AppModel>(context, listen: false).newUpdateExists) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        bool isMandatory =
            Provider.of<AppModel>(context, listen: false).isUpdateMandatory;
        twoButtonsDialog(context, () async {
          // AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();
          // if (appUpdateInfo?.updateAvailability ==
          //     UpdateAvailability.updateAvailable)
          //   InAppUpdate.performImmediateUpdate();
          if (Platform.isAndroid) {
            AppUtil.launchURL(Strings.playStoreUrl);
          }
        },
            bodyText: isMandatory
                ? 'New critical update available, you must update in order to continue use'
                : 'New update available, want to update?',
            headerText: 'New Update',
            isBarrierDismissible: isMandatory ? false : true,
            yestBtn: 'UPDATE',
            cancelFunction: isMandatory ? () => exit(0) : null);
      });
    }
  }

  static bool checkForInterests(BuildContext context) {
    bool hasInterests;

    if (Provider.of<User>(context, listen: false).followedGames <
        kMinInterests) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.of(context).pushNamed(RouteList.interests);
      });
      hasInterests = false;
    } else {
      hasInterests = true;
    }

    return hasInterests;
  }

  static createVideoThumbnail(String url) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight:
          600, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 85,
    );

    return fileName;
  }

  static createAppDirectory() async {
    String initialPath = '${(await getApplicationSupportDirectory()).path}/';
    if (!(await Directory('$initialPath$appName').exists())) {
      final dir = await Directory('$initialPath$appName').create();
      appTempDirectoryPath = dir.path + '/';
      //print('appTempDirectoryPath: $appTempDirectoryPath');
    } else {
      appTempDirectoryPath = '$initialPath$appName/';
    }
  }

  static deleteAppDirectoryFiles() async {
    final dir = Directory(appTempDirectoryPath);
    await dir.delete(recursive: true);
    await AppUtil.createAppDirectory();
  }

  static englishOnly(String input) {
    String pattern = r'^(?:[a-zA-Z]|\P{L})+$';
    RegExp regex = RegExp(pattern, unicode: true);
    //print(regex.hasMatch(input));
    return regex.hasMatch(input);
  }

  bool isNetworkWorking() {
    return networkStatus;
  }

  static launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      //print('Could not launch $url');
    }
  }

  static randomIndices(List list, {int requiredRandoms = 10}) {
    Random r = Random();
    List randoms = [];

    for (int i = 0; i < requiredRandoms; i++) {
      int random = r.nextInt(list.length);

      while (randoms.contains(random)) {
        random = r.nextInt(list.length);
      }
      randoms.add(list[random]);
    }

    return randoms;
  }

  showToast(String msg) {
    FlutterToast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        textcolor: '#ffffff');
  }

  static void showSnackBar(BuildContext context, String value) {
    final scaffold = ScaffoldMessenger.of(context);
    FocusScope.of(context).requestFocus(new FocusNode());
    scaffold.removeCurrentSnackBar();
    scaffold.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: MyColors.darkPrimary,
      duration: Duration(seconds: 3),
    ));
  }

  static void showFixedSnackBar(BuildContext context, String value) {
    final scaffold = ScaffoldMessenger.of(context);
    FocusScope.of(context).requestFocus(new FocusNode());
    scaffold.removeCurrentSnackBar();
    scaffold.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: MyColors.darkPrimary,
      duration: Duration(hours: 1),
    ));
  }

  static Future<File> chooseImage(
      {ImageSource source = ImageSource.gallery}) async {
    PickedFile image =
        await ImagePicker.platform.pickImage(source: source, imageQuality: 80);
    //print('File size: ${File(image.path).lengthSync()}');
    return File(image.path);
  }

  static chooseVideo() async {
    await ImagePicker.platform.pickVideo(source: ImageSource.gallery);
  }

  static Future uploadFile(File file, BuildContext context, String path,
      {List<String> groupMembersIds}) async {
    if (file == null) return;

    Reference storageReference = FirebaseStorage.instance.ref().child(path);
    //print('storage path: $path');
    UploadTask uploadTask;

    if (path.contains('group')) {
      Map<String, String> members = {};
      for (String id in groupMembersIds) {
        //print('Member: $id');
        members.putIfAbsent(id, () => id);
      }
      uploadTask = storageReference.putFile(
        file,
        SettableMetadata(
          contentLanguage: 'en',
          customMetadata: members,
        ),
      );
    } else {
      uploadTask = storageReference.putFile(file);
    }

    await uploadTask;
    //print('File Uploaded');
    String url = await storageReference.getDownloadURL();

    return url;
  }

  void customSnackBar(BuildContext context, String msg,
      {double height = 30, Color backgroundColor = Colors.black}) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.hideCurrentSnackBar();
    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      content: Text(
        msg,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
    scaffold.showSnackBar(snackBar);
  }

  String getSocialLinks(String url) {
    if (url != null && url.isNotEmpty) {
      url = url.contains("https://www") || url.contains("http://www")
          ? url
          : url.contains("www") &&
                  (!url.contains('https') && !url.contains('http'))
              ? 'https://' + url
              : 'https://www.' + url;
    } else {
      return null;
    }
    //print('Launching URL : $url');
    return url;
  }

  static sendSupportEmail(String subject) async {
    final Email email = Email(
      body:
          '\n\n\n\nPlease don\'t remove this line (${Constants.currentUserID})',
      subject: subject,
      recipients: ['support@gl1tch3r.com'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  static checkIfContainsMention(String text, String postId) async {
    text.split(' ').forEach((word) async {
      if (word.startsWith('@')) {
        User user =
            await DatabaseService.getUserWithUsername(word.substring(1));

        await NotificationHandler.sendNotification(
            user.id,
            'New mention',
            Constants.currentUser.username + ' mentioned you',
            postId,
            'mention');
      }
    });
  }

  static Future checkIfContainsHashtag(
      String text, String postId, bool newHashtag) async {
    text.split(' ').forEach((word) async {
      if (word.startsWith('#')) {
        Hashtag hashtag = await DatabaseService.getHashtagWithText(word);

        if (newHashtag) {
          String hashtagId = randomAlphaNumeric(20);
          await hashtagsRef
              .doc(hashtagId)
              .set({'text': word, 'timestamp': FieldValue.serverTimestamp()});

          await hashtagsRef
              .doc(hashtagId)
              .collection('posts')
              .doc(postId)
              .set({'timestamp': FieldValue.serverTimestamp()});
        } else {
          await hashtagsRef
              .doc(hashtag.id)
              .collection('posts')
              .doc(postId)
              .set({'timestamp': FieldValue.serverTimestamp()});
        }

        return hashtag;
      } else
        return null;
    });
  }

  static void alertDialog(
      {BuildContext context,
      String heading,
      String message,
      String okBtn,
      Function onSuccess}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            key: Key('AlertDialog'),
            title: Text(heading),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  //Navigator.of(context).pop(); // Dismiss the dialog
                  onSuccess(); // Execute what happens after dismissing the alertDialog
                },
                child: Text(okBtn),
              ),
            ],
          );
        });
  }

  static void showGlitcherLoader(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => GlitcherLoader());
  }
}

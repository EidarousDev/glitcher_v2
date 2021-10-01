import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/data/repositories/posts_repo.dart';
import 'package:glitcher/services/route_generator.dart';

import 'database_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // MyApp.restartApp(NotificationHandler.context);
  // //print(message.data['type']);
  // NotificationHandler.lastNotification = message.data;
}

class NotificationHandler {
  // Create a [AndroidNotificationChannel] for heads up notifications
  static AndroidNotificationChannel _channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  static receiveNotification(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) async {
    StreamSubscription iosSubscription;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    if (!kIsWeb) {
      _channel = const AndroidNotificationChannel(
          'high_importance_channel', // id
          'High Importance Notifications', // title
          'This channel is used for important notifications.', // description
          importance: Importance.high,
          playSound: true);
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        navigateToScreen(
            context, message.data['type'], message.data['object_id']);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        _flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              iOS: IOSNotificationDetails(
                  presentAlert: true, presentSound: true),
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                _channel.description,
                groupKey: message.data['type'] == 'message'
                    ? '${message.data['type']}_${message.data['sender']}'
                    : null,
                icon: 'ic_notification',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      navigateToScreen(
          context, message.data['type'], message.data['object_id']);
    });
  }

  static makeNotificationSeen(String notificationId) {
    usersRef
        .doc(Constants.currentUserID)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'seen': true,
    });
  }

  static navigateToScreen(
      BuildContext context, String type, String objectId) async {
    switch (type) {
      case 'message':
        Navigator.of(context).pushNamed(RouteList.conversation,
            arguments: {'otherUid': objectId});
        break;

      case 'follow':
        Navigator.of(context)
            .pushNamed(RouteList.profile, arguments: {'userId': objectId});
        break;

      case 'new_group':
        Navigator.of(context).pushNamed(RouteList.groupConversation,
            arguments: {'groupId': objectId});
        break;

      default:
        Navigator.of(context).pushNamed(RouteList.post,
            arguments: {'post': await PostsRepo.getPostWithId(objectId)});
        break;
    }
  }

  static sendNotification(String receiverId, String title, String body,
      String objectId, String type) async {
    if (receiverId == Constants.currentUserID) return;
    await usersRef.doc(receiverId).collection('notifications').add({
      'title': title,
      'body': body,
      'seen': false,
      'timestamp': FieldValue.serverTimestamp(),
      'sender': Constants.currentUserID,
      'object_id': objectId,
      'type': type
    });
    if (type == 'message') {
      await usersRef
          .doc(receiverId)
          .update({'messagesNumber': FieldValue.increment(1)});
    } else {
      await usersRef
          .doc(receiverId)
          .update({'notificationsNumber': FieldValue.increment(1)});
    }
  }

  static removeNotification(
      String receiverId, String objectId, String type) async {
    await DatabaseService.removeNotification(receiverId, objectId, type);

    //print('noti removed');
  }

  void configLocalNotification() async {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('ic_notification');

    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (data) {
      //print('data: $data');
    });
  }

  void showNotification(Map<String, dynamic> message) async {
    await configLocalNotification();

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        Platform.isAndroid ? 'com.devyat.alhani' : 'com.devyat.alhani',
        'Alhany',
        'your channel description',
        enableVibration: true,
        importance: Importance.max,
        priority: Priority.high,
        groupKey: message['type'] == 'message'
            ? '${message['type']}_${message['sender']}'
            : null,
        autoCancel: true);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'].toString(),
        message['notification']['body'].toString(),
        platformChannelSpecifics,
        payload: json.encode(message));
  }

  clearNotificationsNumber() async {
    await usersRef
        .doc(Constants.currentUserID)
        .update({'notificationsNumber': 0});
  }

  clearMessagesNumber() async {
    await usersRef.doc(Constants.currentUserID).update({'messagesNumber': 0});
  }
}

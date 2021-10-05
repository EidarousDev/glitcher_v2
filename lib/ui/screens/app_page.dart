import 'dart:async';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/data/models/game_model.dart';
import 'package:glitcher/data/models/hashtag_model.dart';
import 'package:glitcher/data/models/post_model.dart';
import 'package:glitcher/data/models/user_model.dart';
import 'package:glitcher/data/repositories/games_repo.dart';
import 'package:glitcher/data/repositories/posts_repo.dart';
import 'package:glitcher/logic/blocs/game_bloc.dart';
import 'package:glitcher/logic/blocs/post_bloc.dart';
import 'package:glitcher/logic/blocs/posts_bloc.dart';
import 'package:glitcher/logic/states/game_state.dart';
import 'package:glitcher/logic/states/post_state.dart';
import 'package:glitcher/logic/states/posts_state.dart';
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/services/notification_handler.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/ui/screens/games/games_screen.dart';
import 'package:glitcher/ui/screens/home/home_screen.dart';
import 'package:glitcher/ui/screens/notifications/notifications_screen.dart';
import 'package:glitcher/ui/screens/profile/profile_screen.dart';
import 'package:glitcher/ui/style/colors.dart';
import 'package:glitcher/utils/app_util.dart';
import 'package:glitcher/utils/functions.dart';
import 'package:package_info/package_info.dart';

import 'chats/chats.dart';

class AppPage extends StatefulWidget {
  static const String id = 'home_page';
  AppPage({Key key}) : super(key: key);

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  PageController _pageController;
  int _page = 0; //Highlight the first Icon in the BottomNavigationBarItem
  String username;
  String profileImageUrl;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  StreamSubscription<ConnectivityResult> connectivitySubscription;

  //int _unseenNotifications = 0;
  @override
  Widget build(BuildContext context) {
    //print('currentUser = ${Constants.currentUser}');
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: <Widget>[
          HomeScreen(),
          Chats(),
          GamesScreen(),
          NotificationsScreen(),
          BlocProvider.value(
              value: PostsBloc(PostsState.initialState()),
              child: ProfileScreen(Constants.currentUserID)),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          primaryColor: kPrimary,
        ),
        child: BottomNavigationBar(
          selectedItemColor: kPrimary,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                ),
                label: 'Home'),
            BottomNavigationBarItem(
                // ignore: null_aware_before_operator
                icon: (Constants.currentUser?.messagesNumber ?? 0) > 0
                    ? Badge(
                        badgeContent: Text(
                          (Constants.currentUser?.messagesNumber ?? 0) < 9
                              ? (Constants.currentUser?.messagesNumber ?? 0)
                                  .toString()
                              : '+9',
                          style: TextStyle(color: Colors.white),
                        ),
                        child: Icon(Icons.message),
                        toAnimate: true,
                        animationType: BadgeAnimationType.scale,
                      )
                    : Icon(Icons.message),
                label: 'Chats'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.games,
                ),
                label: 'Games'),
            BottomNavigationBarItem(
                // ignore: null_aware_before_operator
                icon: (Constants.currentUser?.notificationsNumber ?? 0) > 0
                    ? Badge(
                        badgeContent: Text(
                          Constants.currentUser.notificationsNumber < 9
                              ? Constants.currentUser?.notificationsNumber
                                  .toString()
                              : '+9',
                          style: TextStyle(color: Colors.white),
                        ),
                        child: Icon(Icons.notifications),
                        toAnimate: true,
                        animationType: BadgeAnimationType.scale,
                      )
                    : Icon(Icons.notifications),
                label: 'Notifications'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                ),
                label: 'Profile'),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    //print('Constants.loggedInUser: ${Constants.currentUser}');
    _pageController = PageController(initialPage: 0);
    //_retrieveDynamicLink();
    userListener();
    _saveDeviceToken();
    setHashtags();

    this._getFavouriteFilter();
    NotificationHandler.receiveNotification(context, _scaffoldKey);

    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        Constants.connectionState = result;
      });

      // Got a new connectivity status!
      if (result == ConnectivityResult.none) {
        //print('No internet');
        AppUtil.showFixedSnackBar(context, 'No internet connection.');
      } else {
        //_scaffoldKey.currentState.hideCurrentSnackBar();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        if (deepLink.pathSegments[deepLink.pathSegments.length - 2] ==
            'posts') {
          Post post = await PostsRepo.getPostWithId(deepLink.pathSegments.last);
          Navigator.of(context).pushNamed(RouteList.post, arguments: {
            'postBloc': PostBloc(PostState(post)),
          });
        } else if (deepLink.pathSegments[deepLink.pathSegments.length - 2] ==
            'users') {
          User user = await DatabaseService.getUserWithId(
              deepLink.pathSegments.last,
              checkLocal: false);
          Navigator.of(context)
              .pushNamed(RouteList.profile, arguments: {'userId': user.id});
        } else if (deepLink.pathSegments[deepLink.pathSegments.length - 2] ==
            'games') {
          Game game = await GamesRepo.getGameWithId(deepLink.pathSegments.last);
          Navigator.of(context).pushNamed(RouteList.game, arguments: {
            'gameBloc': GameBloc(
              GameState(game),
            ),
          });
        }
      }
    }, onError: (OnLinkErrorException e) async {
      //print('onLinkError');
      //print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Post post = await PostsRepo.getPostWithId(deepLink.pathSegments.last);
      Navigator.of(context).pushNamed(RouteList.post, arguments: {
        'postBloc': PostBloc(PostState(post)),
      });
    }
  }

//  Future<void> _retrieveDynamicLink() async {
//    final PendingDynamicLinkData data =
//        await FirebaseDynamicLinks.instance.getInitialLink();
//    final Uri deepLink = data?.link;
//
//    if (deepLink != null) {
//      // to get the parameters we sent
//      // to get what link it is use deepLink.path
//      //print('test link $deepLink.path');
//      String postId = deepLink.queryParameters['postId'];
//      // perform your navigation operations here
//      Post post = await DatabaseService.getPostWithId(postId);
//      Navigator.of(context).pushNamed(RouteList.post, arguments: {'post': post});
//    }
//  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _getFavouriteFilter() async {
    int favouriteFilter = await getFavouriteFilter();
    setState(() {
      Constants.favouriteFilter = favouriteFilter;
    });
    //print('filter: ${Constants.favouriteFilter}');
  }

  userListener() {
    usersRef.snapshots().listen((querySnapshot) {
      querySnapshot.docChanges.forEach((change) {
        if (mounted) {
          setState(() {
            if (change.doc.id == Constants.currentUserID) {
              Constants.currentUser = User.fromDoc(change.doc);
            }
          });
        }
      });
    });
  }

  void onPageChanged(int page) {
    //Solves the problem setState() called after dispose()
    if (mounted) {
      setState(() {
        this._page = page;
        if (page == 3) {
          //TODO change if bottom navbar changed
          //notification screen
          NotificationHandler().clearNotificationsNumber();
        } else if (page == 1) {
          NotificationHandler().clearMessagesNumber();
        }
      });
    }
  }

  _saveDeviceToken() async {
    String token = await _firebaseMessaging.getToken();
    if (token != null) {
      usersRef
          .doc(Constants.currentUserID)
          .collection('tokens')
          .doc(token)
          .set({'modifiedAt': FieldValue.serverTimestamp(), 'signed': true});
    }
    //print('token = $token');
  }

  Future<void> setHashtags() async {
    List<Hashtag> hashtags = await getHashtags();
    // User Friends
    setState(() {
      Constants.hashtags = hashtags;
    });
  }
}

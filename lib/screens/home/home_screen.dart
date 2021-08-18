//eidarous
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/constants/sizes.dart';
import 'package:glitcher/constants/strings.dart';
import 'package:glitcher/list_items/post_item.dart';
import 'package:glitcher/models/app_model.dart';
import 'package:glitcher/models/post_model.dart';
import 'package:glitcher/models/user_model.dart' as user;
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/style/colors.dart';
import 'package:glitcher/utils/app_util.dart';
import 'package:glitcher/utils/functions.dart';
import 'package:glitcher/widgets/caching_image.dart';
import 'package:glitcher/widgets/drawer.dart';
import 'package:glitcher/widgets/gradient_appbar.dart';
import 'package:glitcher/widgets/rate_app.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

//import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../widgets/card_icon_text.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();

  static bool isBottomSheetVisible = false;

  static showMyBottomSheet(BuildContext context) {
    // the context of the bottomSheet will be this widget
    //the context here is where you want to show the bottom sheet
    showBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return BottomSheet(
            enableDrag: true,
            onClosing: () {
              HomeScreen.isBottomSheetVisible = false;
            },
            builder: (BuildContext context) {
              return Container(
                color: MyColors.darkPrimary,
                height: 120,
              );
            },
          ); // returns your BottomSheet widget
        });
  }
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  user.User loggedInUser;
  String username;
  //String profileImageUrl = '';
  List<Post> _posts = [];
  User currentFirebaseUser;
  Timestamp lastVisiblePostSnapShot;
  bool _noMorePosts = false;
  int _feedFilter = 0;

  ScrollController _scrollController = ScrollController();

  bool isFiltering = false;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  getFollowedGames() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     Navigator.of(context).push(CustomScreenLoader());
      //     QuerySnapshot usersSnapshot = await usersRef.get();
      //
      //     int docsDeleted = 0;
      //     for (var doc in usersSnapshot.docs) {
      //       if ((doc.data() as Map)['username'] == null) {
      //         await usersRef.doc(doc.id).delete();
      //         print('Docs deleted${docsDeleted++}');
      //       }
      //     }
      //     Navigator.of(context).pop();
      //     AppUtil.showSnackBar(context, 'DONE!!!');
      //     print('DONE!!!');
      //   },
      //   child: Icon(Icons.code),
      // ),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Home'),
        flexibleSpace: gradientAppBar(context),
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Icon(Icons.menu),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.tune,
              color: [1, 2].contains(_feedFilter) ? kPrimary : null,
            ),
            onPressed: () async {
              setState(() {
                isFiltering = !isFiltering;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                color: switchColor(context, MyColors.lightBG, MyColors.darkBG),
                child: Column(
                  children: <Widget>[
                    isFiltering
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 10, top: 2, right: 10),
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    'Filter by:',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Radio(
                                          activeColor: MyColors.darkPrimary,
                                          value: 0,
                                          groupValue: _feedFilter,
                                          onChanged: (value) {
                                            setState(() {
                                              //arePostsFilteredByFollowedGames = false;
                                              _feedFilter = value;
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
                                          groupValue: _feedFilter,
                                          onChanged: (value) {
                                            setState(() {
                                              //arePostsFilteredByFollowedGames = false;
                                              _feedFilter = value;
                                            });
                                          }),
                                      Text(
                                        'Followed Gamers',
                                      ),
                                      Radio(
                                          activeColor: MyColors.darkPrimary,
                                          value: 2,
                                          groupValue: _feedFilter,
                                          onChanged: (value) {
                                            setState(() {
                                              //arePostsFilteredByFollowedGames = true;
                                              _feedFilter = value;
                                            });
                                          }),
                                      Text(
                                        'Followed Games',
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: MaterialButton(
                                      color: MyColors.darkPrimary,
                                      child: Text('Filter'),
                                      onPressed: () async {
                                        await _setupFeed();
                                        setState(() {
                                          isFiltering = false;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Divider(
                                      height: 1,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    Row(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CacheThisImage(
                              imageUrl: loggedInProfileImageURL,
                              imageShape: BoxShape.circle,
                              width: Sizes.sm_profile_image_w,
                              height: Sizes.sm_profile_image_h,
                              defaultAssetImage: Strings.default_profile_image,
                            )),
                        Expanded(
                          child: InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  border: Border.all(
                                      color: switchColor(
                                          context,
                                          MyColors.lightPrimary,
                                          MyColors.darkPrimary),
                                      width: 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 22.0),
                                  child: TextField(
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Any thoughts?",
                                        enabled: false,
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(RouteList.newPost,
                                  arguments: {'selectedGame': ''});
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          CardIconText(
                              tStyle: TextStyle(fontWeight: FontWeight.bold),
                              icon: FontAwesome.image,
                              text: "Image",
                              color: Colors.transparent,
                              ccolor: kPrimary),
                          CardIconText(
                            tStyle: TextStyle(fontWeight: FontWeight.bold),
                            icon: FontAwesome.file_video_o,
                            text: "Video",
                            color: Colors.transparent,
                            ccolor: kPrimary,
                          ),
                          CardIconText(
                            tStyle: TextStyle(fontWeight: FontWeight.bold),
                            icon: FontAwesome.youtube,
                            text: "YouTube",
                            color: Colors.transparent,
                            ccolor: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: _posts.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                Post post = _posts[index];
                return FutureBuilder(
                    future: DatabaseService.getUserWithId(post.authorId,
                        checkLocal: _feedFilter == 1),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox.shrink();
                      }
                      user.User author = snapshot.data;
                      return PostItem(post: post, author: author);
                    });
              },
            )
          ],
        ),
      ),
      drawer: BuildDrawer(),
    );
  }

  Future<List<Post>> _setupFeed() async {
    List<Post> posts;

    if (isFiltering) {
      AppUtil.showGlitcherLoader(context);

      if (Constants.followedGamesNames.length == 0) {
        await DatabaseService.getAllFollowedGames(Constants.currentUserID);
      }
      if (Constants.followingIds.length == 0) {
        await DatabaseService.getAllMyFollowing();
      }

      Navigator.pop(context); // Dismiss the loader dialog
    }

    //print('Home Filter: $_feedFilter');

    if (_feedFilter == 0) {
      posts = await DatabaseService.getPosts();
      _posts = posts;
      this.lastVisiblePostSnapShot = posts.last.timestamp;
    } else if (_feedFilter == 1) {
      posts = await DatabaseService.getPostsFilteredByFollowing();
      _posts = posts;
      this.lastVisiblePostSnapShot = posts.last.timestamp;
    } else if (_feedFilter == 2) {
      posts = await DatabaseService.getPostsFilteredByFollowedGames();
      _posts = posts;
      if (_posts.length > 0)
        this.lastVisiblePostSnapShot = posts.last.timestamp;
    }
    setState(() {
      _posts = posts;
    });
    return posts;

//    setState(() {
//      Cache.homePosts = _posts;
//    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    if (mounted) {
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

    ///Set up listener here
    _scrollController
      ..addListener(() {
        if (_scrollController.offset >=
                _scrollController.position.maxScrollExtent &&
            !_scrollController.position.outOfRange) {
          //print('reached the bottom');
          nextPosts();
        } else if (_scrollController.offset <=
                _scrollController.position.minScrollExtent &&
            !_scrollController.position.outOfRange) {
          //print("reached the top");
        } else {}
      });
    loadUserData();
    loadUserFavoriteFilter();
    _setupFeed();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();

    RateApp(context).rateGlitcher();
  }

  loadUserFavoriteFilter() async {
    _feedFilter = await getFavouriteFilter();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
        .dispose(); // it is a good practice to dispose the controller
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    updateOnlineUserState(state);
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      //print('resumed');
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
      //print('inactive');
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
      //print('paused');
    } else if (state == AppLifecycleState.detached) {
      // app suspended (not used in iOS)
    }
  }

  void updateOnlineUserState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      DatabaseService.makeUserOffline();
    } else if (state == AppLifecycleState.resumed) {
      DatabaseService.makeUserOnline();
    }
  }

  void loadUserData() async {
    currentFirebaseUser = await firebaseAuth.currentUser;
    ////print('currentUserID: ${currentUser.uid}');
    // here you write the codes to input the data into firestore
    loggedInUser = await DatabaseService.getUserWithId(currentFirebaseUser.uid,
        checkLocal: false);

    if (mounted) {
      setState(() {
        //profileImageUrl = loggedInUser.profileImageUrl;
        loggedInProfileImageURL = loggedInUser.profileImageUrl;
        username = loggedInUser.username;
//        //print(
//            'profileImageUrl = ${loggedInProfileImageURL} and username = $username');
      });
    }
  }

  void nextPosts() async {
    var posts;
    if (_feedFilter == 0) {
      posts = await DatabaseService.getNextPosts(lastVisiblePostSnapShot);
    } else if (_feedFilter == 1) {
      posts = await DatabaseService.getNextPostsFilteredByFollowing(
          lastVisiblePostSnapShot);
    } else if (_feedFilter == 2) {
      posts = await DatabaseService.getNextPostsFilteredByFollowedGames(
          lastVisiblePostSnapShot);
    }
    if (posts.length > 0) {
      setState(() {
        posts.forEach((element) => _posts.add(element));
        this.lastVisiblePostSnapShot = posts.last.timestamp;
      });
    }

//    setState(() {
//      Cache.homePosts = _posts;
//    });
//    //print('cache posts length: ${Cache.homePosts}');
  }

  AudioPlayer audioPlayer = AudioPlayer();
  void _onRefresh() async {
    audioPlayer
        .setAsset(Strings.swipe_up_to_reload)
        .then((value) => audioPlayer.play());
    await _setupFeed();
    //await Future.delayed(Duration(milliseconds: 1000));
    //_refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    //await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    //_refreshController.loadComplete();
  }
}

searchList(String text) {
  List<String> list = [];
  for (int i = 1; i <= text.length; i++) {
    list.add(text.substring(0, i).toLowerCase());
  }
  return list;
}

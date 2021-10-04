import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/constants/sizes.dart';
import 'package:glitcher/constants/strings.dart';
import 'package:glitcher/data/models/app_model.dart';
import 'package:glitcher/data/models/user_model.dart' as user_model;
import 'package:glitcher/logic/blocs/posts_bloc.dart';
import 'package:glitcher/logic/states/posts_state.dart';
import 'package:glitcher/services/auth.dart';
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/services/notification_handler.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/services/share_link.dart';
import 'package:glitcher/services/sqlite_service.dart';
import 'package:glitcher/ui/style/colors.dart';
import 'package:glitcher/ui/widgets/bottom_sheets/profile_image_edit_bottom_sheet.dart';
import 'package:glitcher/ui/widgets/common/caching_image.dart';
import 'package:glitcher/ui/widgets/common/posts_list.dart';
import 'package:glitcher/ui/widgets/custom_widgets.dart';
import 'package:glitcher/ui/widgets/drawer.dart';
import 'package:glitcher/ui/widgets/image_overlay.dart';
import 'package:glitcher/utils/app_util.dart';
import 'package:glitcher/utils/functions.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:share/share.dart';

import '../../widgets/common/circular_clipper.dart';
import '../../widgets/common/custom_loader.dart';

enum ScreenState { to_edit, to_follow, to_save, to_unfollow }

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen(this.userId);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _coverImageUrl;
  var _profileImageUrl;
  var _coverImageFile;
  var _profileImageFile;

  String _descText = 'Description here';
  String _usernameText = 'Username';
  String _nameText = 'name';
  var _descEditingController = TextEditingController()
    ..text = 'Description here';
  var _usernameEditingController = TextEditingController()..text = '';
  var _nameEditingController = TextEditingController()..text = '';

  user_model.User userData;

  bool _loading = false;

  User currentUser;

  bool isFollowing = false;
  bool isFriend = false;

  ScrollController _scrollController = ScrollController();

  bool isEditingUsername = false;
  bool isEditingName = false;
  bool isEditingDesc = false;

  String _errorMsgUsername = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _ProfileScreenState();

  String validateUsername(String value) {
    String pattern =
        r'^(?=.{4,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      AppUtil().showToast("Username is Required");
      setState(() {
        _errorMsgUsername = "Username is Required";
      });
    } else if (!regExp.hasMatch(value)) {
      //AppUtil().showToast("Invalid Username");
      setState(() {
        _errorMsgUsername = "Invalid Username";
      });
      return _errorMsgUsername;
    } else {
      setState(() {
        _errorMsgUsername = null;
      });
    }
    return _errorMsgUsername;
  }

  Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return result.docs.isEmpty;
  }

  @override
  void initState() {
    super.initState();

    ///Set up listener here
    _scrollController
      ..addListener(() {
        if (_scrollController.offset >=
                _scrollController.position.maxScrollExtent &&
            !_scrollController.position.outOfRange) {
          //print('reached the bottom');
          _nextPosts();
        } else if (_scrollController.offset <=
                _scrollController.position.minScrollExtent &&
            !_scrollController.position.outOfRange) {
          //print("reached the top");
        } else {}
      });
    checkUser();
  }

  checkUser() async {
    currentUser = await Auth().getCurrentUser();

    if (this.widget.userId != currentUser.uid) {
      DocumentSnapshot followSnapshot = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('following')
          .doc(widget.userId)
          .get();

      setState(() {
        isFollowing = followSnapshot.exists;
      });

      DocumentSnapshot friendSnapshot = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friends')
          .doc(widget.userId)
          .get();

      setState(() {
        isFriend = friendSnapshot.exists;
      });
    }

    if (userData == null) {
      loadUserData();
      loadPosts();
    }
  }

  void _nextPosts() async {
    BlocProvider.of<PostsBloc>(context).getMoreUserPosts(widget.userId);
  }

  void loadUserData() async {
    setState(() {
      _loading = true;
    });
    //print('profileUserID = ${widget.userId}');
    user_model.User user =
        await DatabaseService.getUserWithId(widget.userId, checkLocal: false);
    setState(() {
      userData = user;
      _usernameText = user.username;
      _nameText = user.name;
      _descText = user.description;
      _profileImageUrl = user.profileImageUrl;
      _coverImageUrl = user.coverImageUrl;
      _profileImageFile = null;
      _coverImageFile = null;
      _loading = false;
    });

    user_model.User localUser = await UserSqlite.getUserWithId(user.id);
    if (localUser == null) {
      await UserSqlite.insert(user);
    } else {
      user.isFriend = localUser.isFriend;
      user.isFollowing = localUser.isFollowing;
      user.isFollower = localUser.isFollower;
      await UserSqlite.update(user);
    }
  }

  Stack _profileAndCover() {
    return Stack(
      alignment: Alignment(0, 0),
      children: <Widget>[
        Container(
          transform: Matrix4.translationValues(0.0, -50.0, 0.0),
          child: Hero(
            tag: _coverImageUrl != null
                ? _coverImageUrl
                : Strings.default_post_image,
            child: ClipShadowPath(
                clipper: CircularClipper(),
                shadow: Shadow(blurRadius: 20.0),
                child: GestureDetector(
                  onTap: () {
                    if (widget.userId == Constants.currentUserID)
                      coverEdit();
                    else {
                      coverDownload();
                    }
                  },
                  child: CacheThisImage(
                    imageUrl: _coverImageUrl,
                    imageShape: BoxShape.rectangle,
                    width: double.infinity,
                    height: 300.0,
                    defaultAssetImage: Strings.default_profile_image,
                  ),
                )),
          ),
        ),
        Positioned.fill(
          bottom: 10.0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: RawMaterialButton(
                padding: EdgeInsets.all(1.0),
                elevation: 12.0,
                onPressed: () => () {},
                shape: CircleBorder(),
                fillColor: Colors.white,
                child: GestureDetector(
                  onTap: () {
                    if (widget.userId == Constants.currentUserID)
                      profileEdit();
                    else {
                      profileDownload();
                    }
                  },
                  child: CacheThisImage(
                    imageUrl: _profileImageUrl,
                    imageShape: BoxShape.circle,
                    width: Sizes.lg_profile_image_w,
                    height: Sizes.lg_profile_image_h,
                    defaultAssetImage: Strings.default_profile_image,
                  ),
                )),
          ),
        ),
        widget.userId != Constants.currentUserID
            ? Positioned(
                bottom: 0.0,
                left: 20.0,
                child: IconButton(
                  onPressed: isFollowing
                      ? () {
                          unfollowUser();
                        }
                      : () {
                          followUser();
                        },
                  icon: !isFollowing
                      ? Icon(
                          FontAwesome.user_plus,
                          color: kPrimary,
                        )
                      : Icon(
                          FontAwesome.user_times,
                          color: kPrimary,
                        ),
                  iconSize: 25.0,
                ),
              )
            : Container(),
        isFriend
            ? Positioned(
                bottom: 0.0,
                right: 25.0,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteList.conversation,
                        arguments: {'otherUid': widget.userId});
                  },
                  icon: Icon(
                    Icons.chat,
                    color: kPrimary,
                  ),
                  iconSize: 25.0,
                  color: switchColor(context, MyColors.lightButtonsBackground,
                      MyColors.darkPrimaryTappedBtn),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _build() {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Stack(
        alignment: Alignment(0, 0),
        children: <Widget>[
          SingleChildScrollView(
            controller: _scrollController,
            child: BlocBuilder<PostsBloc, PostsState>(
              builder: (context, postsState) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _profileAndCover(),
                  SizedBox(
                    height: 1.0,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          !isEditingName
                              ? Text(
                                  '${_nameText ?? ''} ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(
                                  width: 200,
                                  child: TextField(
                                    controller: _nameEditingController,
                                  )),
                          widget.userId == Constants.currentUserID
                              ? !isEditingName
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: switchColor(context,
                                            Colors.black, Colors.white),
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isEditingName = true;
                                          _nameEditingController.text =
                                              _nameText;
                                        });
                                      })
                                  : IconButton(
                                      icon: Icon(
                                        Icons.done,
                                        color: switchColor(context,
                                            Colors.black, Colors.white),
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isEditingName = false;
                                          _nameText =
                                              _nameEditingController.text;
                                        });

                                        updateName();
                                      })
                              : Container(),
                          !isEditingUsername
                              ? Text(
                                  '@' + _usernameText,
                                  style: TextStyle(
                                      color: switchColor(
                                          context,
                                          MyColors.lightPrimaryTappedBtn,
                                          MyColors.darkPrimaryTappedBtn),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'WorkSansMedium'),
                                )
                              : Container(
                                  width: 150,
                                  child: TextFormField(
                                    controller: _usernameEditingController,
                                    onFieldSubmitted: (v) {
                                      setState(() {
                                        isEditingUsername = false;
                                      });

                                      updateUsername();
                                    },
                                  )),
                          widget.userId == Constants.currentUserID
                              ? !isEditingUsername
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: switchColor(context,
                                            Colors.black, Colors.white),
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isEditingUsername = true;
                                          _usernameEditingController.text =
                                              _usernameText;
                                        });
                                      })
                                  : IconButton(
                                      icon: Icon(
                                        Icons.done,
                                        color: switchColor(context,
                                            Colors.black, Colors.white),
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isEditingUsername = false;
                                        });

                                        updateUsername();
                                      })
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      !isEditingDesc
                          ? Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                constraints: new BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 70),
                                child: Text(
                                  _descText,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontFamily: 'WorkSansMedium'),
                                ),
                              ),
                            )
                          : Container(
                              width: Sizes.fullWidth(context) - 50,
                              child: TextField(
                                controller: _descEditingController,
                              )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      widget.userId == Constants.currentUserID
                          ? !isEditingDesc
                              ? IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: switchColor(
                                        context, Colors.black, Colors.white),
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isEditingDesc = true;
                                      _descEditingController.text = _descText;
                                    });
                                  })
                              : IconButton(
                                  icon: Icon(
                                    Icons.done,
                                    color: switchColor(
                                        context, Colors.black, Colors.white),
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isEditingDesc = false;
                                      _descText = _descEditingController.text;
                                    });
                                    updateDesc();
                                  })
                          : Container(),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              if (Constants.currentUserID == widget.userId ||
                                  !(userData.isAccountPrivate ?? false)) {
                                Navigator.of(context).pushNamed(RouteList.users,
                                    arguments: {
                                      'screen_type': 'Followers',
                                      'userId': widget.userId
                                    });
                              } else {
                                AppUtil.showSnackBar(
                                    context, 'User set account to private');
                              }
                            },
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Followers',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text('${userData?.followers ?? '0'}')
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (Constants.currentUserID == widget.userId ||
                                  !(userData.isAccountPrivate ?? false)) {
                                Navigator.of(context).pushNamed(RouteList.users,
                                    arguments: {
                                      'screen_type': 'Following',
                                      'userId': widget.userId
                                    });
                              } else {
                                AppUtil.showSnackBar(
                                    context, 'User set account to private');
                              }
                            },
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Following',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                                Text('${userData?.following ?? '0'}')
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (Constants.currentUserID == widget.userId ||
                                  !(userData.isAccountPrivate ?? false)) {
                                Navigator.of(context).pushNamed(RouteList.users,
                                    arguments: {
                                      'screen_type': 'Friends',
                                      'userId': widget.userId
                                    });
                              } else {
                                AppUtil.showSnackBar(
                                    context, 'User set account to private');
                              }
                            },
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Friends',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                                Text('${userData?.friends ?? '0'}')
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          if (Constants.currentUserID == widget.userId ||
                              !(userData.isAccountPrivate ?? false)) {
                            Navigator.of(context).pushNamed(
                                RouteList.followedGames,
                                arguments: {'userId': widget.userId});
                          } else {
                            AppUtil.showSnackBar(
                                context, 'User set account to private');
                          }
                        },
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Followed Games',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text('${userData?.followedGames ?? '0'}')
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  customDivider(context, 3.0,
                      width: Sizes.fullWidth(context) - 100.0),
                  postsState.posts.length > 0
                      ? PostsList(
                          posts: postsState.posts,
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Center(
                              child: Text(
                            'User has no posts yet.',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          )),
                        ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              leading: Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.userId == Constants.currentUserID
                      ? InkWell(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                        )
                      : InkWell(
                          onTap: () => _onBackPressed(),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () async {
                    await shareProfile(
                        widget.userId, _usernameText, _profileImageUrl);
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                      )
                      //, Text('Share Profile')
                    ],
                  ),
                )
              ],
            ),
          ),
          _loading
              ? Center(
                  child: Image.asset(
                  'assets/images/glitcher_loader.gif',
                  height: 250,
                  width: 250,
                ))
              : Container(
                  width: 0,
                  height: 0,
                ),
        ],
      ),
    );
  }

  shareProfile(String userId, String username, String profileImageUrl) async {
    //print('profileImageUrl: $profileImageUrl');
    var userLink = await DynamicLinks(
            Provider.of<AppModel>(context, listen: false)
                .packageInfo
                .packageName)
        .createProfileDynamicLink(
            {'userId': userId, 'text': username, 'imageUrl': profileImageUrl});
    Share.share('Check out @$username profile: $userLink');
    //print('Check out @$username profile: $userLink');
  }

  updateUsername() async {
    Navigator.of(context).push(CustomScreenLoader());
    String validUsername = validateUsername(_usernameEditingController.text);
    final valid = await isUsernameTaken(_usernameEditingController.text);

    if (!valid) {
      // username exists
      AppUtil.showSnackBar(context,
          '${_usernameEditingController.text} is already in use. Please choose a different username.');
    } else {
      if (validUsername == null) {
        List search = searchList(_usernameEditingController.text);
        search.addAll(searchList(_nameText));
        await usersRef.doc(widget.userId).update(
            {'username': _usernameEditingController.text, 'search': search});
        setState(() {
          _usernameText = _usernameEditingController.text;
        });
      } else {
        AppUtil.showSnackBar(context, 'Invalid Username!');
      }
    }
    Navigator.of(context).pop();
  }

  searchList(String text) {
    List<String> list = [];
    for (int i = 1; i <= text.length; i++) {
      list.add(text.substring(0, i).toLowerCase());
    }
    return list;
  }

  updateName() async {
    List search = searchList(_usernameText);
    search.addAll(searchList(_nameText));
    await usersRef
        .doc(widget.userId)
        .update({'name': _nameText, 'search': search});
  }

  updateDesc() async {
    await usersRef.doc(widget.userId).update({'description': _descText});
  }

  loadPosts() async {
    BlocProvider.of<PostsBloc>(context).getUserPosts(widget.userId);
  }

  void followUser() async {
    Navigator.of(context).push(CustomScreenLoader());

    await DatabaseService.followUser(widget.userId);
    await checkUser();

    Navigator.of(context).pop();
  }

  void unfollowUser() async {
//    setState(() {
//      _isBtnEnabled = false;
//      _loading = true;
//    });

    Navigator.of(context).push(CustomScreenLoader());

    await DatabaseService.unfollowUser(widget.userId);
    await NotificationHandler.removeNotification(
        widget.userId, Constants.currentUserID, 'follow');

    await checkUser();

    Navigator.of(context).pop();

//    setState(() {
//      _loading = false;
//      _isBtnEnabled = true;
//      isFollowing = false;
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _build(),
      drawer: BuildDrawer(),
    );
  }

  coverEdit() async {
    if (_coverImageUrl == null && _coverImageFile == null) {
      ImageEditBottomSheet bottomSheet = ImageEditBottomSheet();
      await bottomSheet.openBottomSheet(context);
      File image = await AppUtil.chooseImage(source: bottomSheet.choice);
      setState(() {
        _coverImageFile = image;
        _coverImageUrl = null;
      });
      Navigator.of(context).push(CustomScreenLoader());
      String url = await AppUtil.uploadFile(
          _coverImageFile, context, 'cover_images/${widget.userId}');
      setState(() {
        _coverImageUrl = url;
        _coverImageFile = null;
      });
      await usersRef.doc(widget.userId).update({'cover_url': _coverImageUrl});
      Navigator.of(context).pop();
    } else {
      await showDialog(
          barrierDismissible: true,
          builder: (_) {
            return Container(
              width: Sizes.sm_profile_image_w,
              height: Sizes.sm_profile_image_h,
              child: ImageOverlay(
                imageUrl: _coverImageUrl,
                imageFile: _coverImageFile,
                btnText: 'Edit',
                btnFunction: () async {
                  ImageEditBottomSheet bottomSheet = ImageEditBottomSheet();
                  await bottomSheet.openBottomSheet(context);
                  File image =
                      await AppUtil.chooseImage(source: bottomSheet.choice);
                  setState(() {
                    _coverImageFile = image;
                    _coverImageUrl = null;
                  });
                  Navigator.of(context).push(CustomScreenLoader());
                  String url = await AppUtil.uploadFile(_coverImageFile,
                      context, 'cover_images/${widget.userId}');
                  setState(() {
                    _coverImageUrl = url;
                    _coverImageFile = null;
                  });

                  await usersRef
                      .doc(widget.userId)
                      .update({'cover_url': _coverImageUrl});
                  Navigator.of(context).pop();

                  Navigator.of(context).pop();
                },
              ),
            );
          },
          context: context);
    }
  }

  profileEdit() async {
    if (_profileImageUrl == null && _profileImageFile == null) {
      ImageEditBottomSheet bottomSheet = ImageEditBottomSheet();
      await bottomSheet.openBottomSheet(context);
      File image = await AppUtil.chooseImage(source: bottomSheet.choice);
      setState(() {
        _profileImageFile = image;
        _profileImageUrl = null;
      });
      Navigator.of(context).push(CustomScreenLoader());
      String url = await AppUtil.uploadFile(
          _profileImageFile, context, 'cover_images/${widget.userId}');
      setState(() {
        _profileImageUrl = url;
        _profileImageFile = null;
      });
      await usersRef
          .doc(widget.userId)
          .update({'profile_url': _profileImageUrl});
      Navigator.of(context).pop();
    } else {
      showDialog(
          barrierDismissible: true,
          builder: (_) {
            return Container(
              width: Sizes.sm_profile_image_w,
              height: Sizes.sm_profile_image_h,
              child: ImageOverlay(
                imageUrl: _profileImageUrl,
                imageFile: _profileImageFile,
                btnText: 'Edit',
                btnFunction: () async {
                  ImageEditBottomSheet bottomSheet = ImageEditBottomSheet();
                  await bottomSheet.openBottomSheet(context);
                  File image =
                      await AppUtil.chooseImage(source: bottomSheet.choice);
                  setState(() {
                    _profileImageFile = image;
                    _profileImageUrl = null;
                  });
                  Navigator.of(context).push(CustomScreenLoader());
                  String url = await AppUtil.uploadFile(_profileImageFile,
                      context, 'profile_images/${widget.userId}');
                  setState(() {
                    _profileImageUrl = url;
                    _profileImageFile = null;
                  });
                  await usersRef
                      .doc(widget.userId)
                      .update({'profile_url': _profileImageUrl});
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            );
          },
          context: context);
    }
  }

  coverDownload() async {
    if (_coverImageUrl == null && _coverImageFile == null)
      return;
    else {
      showDialog(
          barrierDismissible: true,
          builder: (_) {
            return Container(
              width: Sizes.sm_profile_image_w,
              height: Sizes.sm_profile_image_h,
              child: ImageOverlay(
                imageUrl: _coverImageUrl,
                imageFile: _coverImageFile,
                btnText: 'Download',
                btnFunction: () async {
                  downloadImage(
                      _coverImageUrl, randomAlphaNumeric(20) + '_cover');
                  Navigator.of(context).pop();
                },
              ),
            );
          },
          context: context);
    }
  }

  profileDownload() async {
    if (_profileImageUrl == null && _profileImageFile == null)
      return;
    else {
      showDialog(
          barrierDismissible: true,
          builder: (_) {
            return Container(
              width: Sizes.sm_profile_image_w,
              height: Sizes.sm_profile_image_h,
              child: ImageOverlay(
                imageUrl: _profileImageUrl,
                imageFile: _profileImageFile,
                btnText: 'Download',
                btnFunction: () async {
                  await downloadImage(
                      _profileImageUrl, randomAlphaNumeric(20) + '_profile');
                  Navigator.of(context).pop();
                },
              ),
            );
          },
          context: context);
    }
  }

  Future<bool> _onBackPressed() {
    /// Navigate back to home page
    if (widget.userId == Constants.currentUserID)
      Navigator.of(context).pushReplacementNamed(RouteList.home);
    else
      Navigator.of(context).pop();
  }
}

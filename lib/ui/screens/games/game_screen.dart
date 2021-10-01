import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/constants/sizes.dart';
import 'package:glitcher/data/models/app_model.dart';
import 'package:glitcher/data/models/game_model.dart';
import 'package:glitcher/data/models/post_model.dart';
import 'package:glitcher/data/models/user_model.dart' as user;
import 'package:glitcher/data/repositories/posts_repo.dart';
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/services/share_link.dart';
import 'package:glitcher/style/colors.dart';
import 'package:glitcher/ui/list_items/post_item.dart';
import 'package:glitcher/ui/widgets/caching_image.dart';
import 'package:glitcher/ui/widgets/drawer.dart';
import 'package:glitcher/ui/widgets/gradient_appbar.dart';
import 'package:glitcher/utils/functions.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share/share.dart';

class GameScreen extends StatefulWidget {
  GameScreen({this.game});

  final Game game;
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  String username;
  String profileImageUrl = '';
  var _posts = [];
  User currentFirebaseUser;
  Timestamp lastVisiblePostSnapShot;
  //bool _noMorePosts = false;
  //bool _isFetching = false;

  ScrollController _scrollController = ScrollController();

  Image _gameImage;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(RouteList.suggestion, arguments: {
                  'initial_title': '${widget.game.fullName} edit suggestion',
                  'initial_details':
                      'I (${Constants.currentUser.username}) suggest the following edit:',
                  'game_id': widget.game.id
                });
              },
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Suggest',
                        style: TextStyle(
                            color:
                                switchColor(context, kPrimary, Colors.white)),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.edit,
                        size: 17,
                        color: switchColor(context, kPrimary, Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                await shareGame(
                    widget.game.id, widget.game.fullName, widget.game.image);
              },
              icon: Icon(
                Icons.share,
                size: 20,
                color: switchColor(context, kPrimary, Colors.white),
              ),
            )
          ],
          flexibleSpace: gradientAppBar(context),
          leading: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: switchColor(context, kPrimary, Colors.white),
                  ),
                  onPressed: () => _onBackPressed(),
                ),
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Stack(
                children: <Widget>[
                  CacheThisImage(
                    height: 180,
                    imageUrl: widget.game.image,
                    imageShape: BoxShape.rectangle,
                    width: Sizes.fullWidth(context),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius:
                                BorderRadius.all(Radius.circular((5)))),
                        padding: EdgeInsets.all(5),
                        child: Text(
                          widget.game.fullName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              shadows: [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.black,
                                  offset: Offset(2.0, 2.0),
                                ),
                              ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  widthFactor: 10,
                  child: Text(
                    "${widget.game.genres}",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Flexible(
                fit: FlexFit.loose,
                child: ExpansionTile(
                  title: Text(
                    'Details',
                    style: TextStyle(color: MyColors.darkPrimary),
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ReadMoreText(
                        widget.game.description,
                        colorClickableText: MyColors.darkPrimary,
                        trimLength: 300,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 1,
                      color: switchColor(context, MyColors.lightLineBreak,
                          Colors.grey.shade600),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Platforms: ${widget.game.platforms}'),
                    ),
                    Container(
                      height: 1,
                      color: switchColor(context, MyColors.lightLineBreak,
                          Colors.grey.shade600),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Stores: ${widget.game.stores}'),
                    ),
                    Container(
                      height: 1,
                      color: switchColor(context, MyColors.lightLineBreak,
                          Colors.grey.shade600),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('ESRB Rating: ${widget.game.esrbRating}'),
                    ),
                    Container(
                      height: 1,
                      color: switchColor(context, MyColors.lightLineBreak,
                          Colors.grey.shade600),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:
                          Text('Metacritic score: ${widget.game.metacritic}'),
                    ),
                    Container(
                      height: 1,
                      color: switchColor(context, MyColors.lightLineBreak,
                          Colors.grey.shade600),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Developers: ${widget.game.developers}'),
                    ),
                    Container(
                      height: 1,
                      color: switchColor(context, MyColors.lightLineBreak,
                          Colors.grey.shade600),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                          'Release Date: ${widget.game.tba ? 'TBA' : widget.game.releaseDate}'),
                    ),
                  ],
                ),
              ),
              _posts.length > 0
                  ? ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: _posts.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        Post post = _posts[index];
                        return FutureBuilder(
                            future: DatabaseService.getUserWithId(post.authorId,
                                checkLocal: false),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }
                              user.User author = snapshot.data;
                              return PostItem(
                                  key: Key(post.id),
                                  post: post,
                                  author: author);
                            });
                      },
                    )
                  : Center(child: Text('Be the first to post on this game!')),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('New post'),
              SizedBox(
                width: 5,
              ),
              Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(RouteList.newPost,
                arguments: {'selectedGame': widget.game.fullName});
          },
        ),
        drawer: BuildDrawer(),
      ),
    );
  }

  shareGame(String gameId, String gameName, String imageUrl) async {
    var gameLink = await DynamicLinks(
            Provider.of<AppModel>(context, listen: false)
                .packageInfo
                .packageName)
        .createGameDynamicLink(
            {'gameId': gameId, 'text': gameName, 'imageUrl': imageUrl});
    Share.share('Check out ($gameName) : $gameLink');
    //print('Check out this game ($gameName): $gameLink');
  }

  _setupFeed() async {
    List<Post> posts = await PostsRepo.getGamePosts(widget.game.fullName);
    setState(() {
      _posts = posts;
      this.lastVisiblePostSnapShot = posts.last.timestamp;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gameImage = Image.network(
      widget.game.image,
    );

    ///Set up listener here
    _scrollController
      ..addListener(() {
        if (_scrollController.offset >=
                _scrollController.position.maxScrollExtent &&
            !_scrollController.position.outOfRange) {
          //print('reached the bottom');
          nextGamePosts();
        } else if (_scrollController.offset <=
                _scrollController.position.minScrollExtent &&
            !_scrollController.position.outOfRange) {
          //print("reached the top");
        } else {}
      });
    _setupFeed();
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
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      _setupFeed();
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
      _setupFeed();
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
      _setupFeed();
    } else if (state == AppLifecycleState.detached) {
      // app suspended (not used in iOS)
    }
  }

  void nextGamePosts() async {
    var posts = await PostsRepo.getNextGamePosts(
        lastVisiblePostSnapShot, widget.game.fullName);
    if (posts.length > 0) {
      setState(() {
        posts.forEach((element) => _posts.add(element));
        this.lastVisiblePostSnapShot = posts.last.timestamp;
      });
    }
  }

  Future<bool> _onBackPressed() {
    Navigator.of(context).pop();
  }
}

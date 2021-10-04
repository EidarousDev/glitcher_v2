import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/constants/sizes.dart';
import 'package:glitcher/data/models/app_model.dart';
import 'package:glitcher/logic/blocs/game_bloc.dart';
import 'package:glitcher/logic/blocs/posts_bloc.dart';
import 'package:glitcher/logic/states/game_state.dart';
import 'package:glitcher/logic/states/posts_state.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/services/share_link.dart';
import 'package:glitcher/ui/style/colors.dart';
import 'package:glitcher/ui/widgets/common/caching_image.dart';
import 'package:glitcher/ui/widgets/common/gradient_appbar.dart';
import 'package:glitcher/ui/widgets/common/posts_list.dart';
import 'package:glitcher/ui/widgets/drawer.dart';
import 'package:glitcher/ui/widgets/multi_fab.dart';
import 'package:glitcher/utils/app_util.dart';
import 'package:glitcher/utils/functions.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share/share.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, gameState) => Scaffold(
          appBar: AppBar(
            actions: [
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(RouteList.suggestion, arguments: {
                    'initial_title':
                        '${gameState.game.fullName} edit suggestion',
                    'initial_details':
                        'I (${Constants.currentUser.username}) suggest the following edit:',
                    'game_id': gameState.game.id
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
                  await shareGame(gameState.game.id, gameState.game.fullName,
                      gameState.game.image);
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
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: BlocBuilder<PostsBloc, PostsState>(
                  builder: (context, postsState) => Column(
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
                            imageUrl: gameState.game.image,
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
                                  gameState.game.fullName,
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
                            "${gameState.game.genres}",
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
                                gameState.game.description,
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
                              color: switchColor(
                                  context,
                                  MyColors.lightLineBreak,
                                  Colors.grey.shade600),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                  'Platforms: ${gameState.game.platforms}'),
                            ),
                            Container(
                              height: 1,
                              color: switchColor(
                                  context,
                                  MyColors.lightLineBreak,
                                  Colors.grey.shade600),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Stores: ${gameState.game.stores}'),
                            ),
                            Container(
                              height: 1,
                              color: switchColor(
                                  context,
                                  MyColors.lightLineBreak,
                                  Colors.grey.shade600),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                  'ESRB Rating: ${gameState.game.esrbRating}'),
                            ),
                            Container(
                              height: 1,
                              color: switchColor(
                                  context,
                                  MyColors.lightLineBreak,
                                  Colors.grey.shade600),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                  'Metacritic score: ${gameState.game.metacritic}'),
                            ),
                            Container(
                              height: 1,
                              color: switchColor(
                                  context,
                                  MyColors.lightLineBreak,
                                  Colors.grey.shade600),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                  'Developers: ${gameState.game.developers}'),
                            ),
                            Container(
                              height: 1,
                              color: switchColor(
                                  context,
                                  MyColors.lightLineBreak,
                                  Colors.grey.shade600),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                  'Release Date: ${gameState.game.tba ? 'TBA' : gameState.game.releaseDate}'),
                            ),
                          ],
                        ),
                      ),
                      postsState.posts.length > 0
                          ? PostsList(
                              posts: postsState.posts,
                            )
                          : Center(
                              child:
                                  Text('Be the first to post on this game!')),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: MultiFab(
                  icons1: !gameState.isFollowed
                      ? Icons.person_add
                      : Icons.person_add_disabled_sharp,
                  color1: !gameState.isFollowed ? Colors.green : Colors.red,
                  onTap1: () {
                    gameState.isFollowed
                        ? BlocProvider.of<GameBloc>(context).unfollowGame()
                        : BlocProvider.of<GameBloc>(context).followGame();
                    AppUtil.showSnackBar(
                        context,
                        !gameState.isFollowed
                            ? 'Game followed'
                            : 'Game unfollowed');
                  },
                  onTap2: () {
                    Navigator.of(context).pushNamed(RouteList.newPost,
                        arguments: {'selectedGame': gameState.game.fullName});
                  },
                ),
              ),
            ],
          ),
          drawer: BuildDrawer(),
        ),
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
    BlocProvider.of<PostsBloc>(context)
        .getGamePosts(BlocProvider.of<GameBloc>(context).state.game.fullName);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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
    BlocProvider.of<PostsBloc>(context).getMoreGamePosts(
        BlocProvider.of<GameBloc>(context).state.game.fullName);
  }

  Future<bool> _onBackPressed() {
    Navigator.of(context).pop();
  }
}

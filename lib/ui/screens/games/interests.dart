import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/data/models/game_model.dart';
import 'package:glitcher/data/models/user_model.dart';
import 'package:glitcher/data/repositories/games_repo.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/style/colors.dart';
import 'package:glitcher/ui/list_items/game_item.dart';
import 'package:glitcher/ui/widgets/gradient_appbar.dart';
import 'package:provider/provider.dart';

class InterestsScreen extends StatefulWidget {
  @override
  _InterestsScreenState createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  List<Game> _games = [];
  List<Game> _filteredGames = [];

  bool _searching = false;
  ScrollController _scrollController = ScrollController();

  TextEditingController _typeAheadController = TextEditingController();

  int lastVisibleGameSnapShot;

  GlobalKey<ScaffoldState> _scaffoldKey;

  int interests;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBack,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: Container(),
          title: Text(
            "Follow some games to setup your feed",
            style: TextStyle(fontSize: 16),
          ),
          flexibleSpace: gradientAppBar(context),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search games',
                      filled: false,
                      prefixIcon: Icon(
                        Icons.search,
                        size: 28.0,
                      ),
                      suffixIcon: _searching
                          ? IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                _typeAheadController.clear();
                                setState(() {
                                  _games = [];
                                  _filteredGames = [];
                                  _searching = false;
                                });
                                _setupFeed();
                              })
                          : null,
                    ),
                    controller: _typeAheadController,
                    onChanged: (text) {
                      _filteredGames = [];
                      if (text.isEmpty) {
                        _setupFeed();
                        setState(() {
                          _filteredGames = [];
                          _searching = false;
                        });
                      } else {
                        setState(() {
                          _searching = true;
                        });
                        _searchGames(text);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: !_searching
                      ? ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _games.length,
                          itemBuilder: (BuildContext context, int index) {
                            Game game = _games[index];

                            return StreamBuilder(builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              return Column(
                                children: <Widget>[
                                  GameItem(
                                    key: ValueKey(game.id),
                                    game: game,
                                    onFollow: (isFollowing) {
                                      setState(() {
                                        isFollowing ? interests++ : interests--;
                                      });
                                    },
                                  ),
                                  Divider(height: .5, color: Colors.grey)
                                ],
                              );
                            });
                          },
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _filteredGames.length,
                          itemBuilder: (BuildContext context, int index) {
                            Game game = _filteredGames[index];

                            return StreamBuilder(builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              return Column(
                                children: <Widget>[
                                  GameItem(key: ValueKey(game?.id), game: game),
                                  Divider(height: .5, color: Colors.grey)
                                ],
                              );
                            });
                          },
                        ),
                ),
              ],
            ),
            Positioned.fill(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: kPrimary,
                child: Center(
                    child: Text(
                  kMinInterests - interests == 0
                      ? 'You\'re all set'
                      : '${kMinInterests - interests} more games to go',
                  style: TextStyle(fontSize: 16),
                )),
                height: 50,
                width: MediaQuery.of(context).size.width,
              ),
            )),
            kMinInterests - interests == 0
                ? Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: InkWell(
                        onTap: _onBack,
                        child: Container(
                          decoration: BoxDecoration(
                            color: kPrimary,
                          ),
                          height: 50,
                          width: 50,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                color: Colors.white,
                                width: 1,
                              ),
                              Expanded(
                                child: Icon(
                                  Icons.exit_to_app,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  _setupFeed() async {
    List<Game> games = await GamesRepo.getGames();
    //await DatabaseService.getGameNames();
    setState(() {
      _games = games;
      this.lastVisibleGameSnapShot = games.last.frequency;
    });
  }

  _searchGames(String text) async {
    List<Game> games = await GamesRepo.searchGames(text.toLowerCase());

    setState(() {
      _filteredGames = games;
      this.lastVisibleGameSnapShot = games?.last?.frequency;
    });
  }

  @override
  void initState() {
    super.initState();
    interests = Provider.of<User>(context, listen: false).followedGames ?? 0;

    ///Set up listener here
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        //print('reached the bottom');
        nextGames();
      } else if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
        //print("reached the top");
      } else {}
    });
    _setupFeed();
  }

  nextGames() async {
    var games = await GamesRepo.getNextGames(lastVisibleGameSnapShot);
    if (games.length > 0) {
      setState(() {
        games.forEach((element) => _games.add(element));
        this.lastVisibleGameSnapShot = games.last.frequency;
      });
      //print('lastVisibleGameSnapShot: $lastVisibleGameSnapShot');
    }
  }

  Future<bool> _onBack() {
    Provider.of<User>(context, listen: false).setFollowingGames(interests);
    if (interests >= kMinInterests) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(RouteList.initialRoute);
    } else {
      Navigator.of(context).pop();
    }
  }
}

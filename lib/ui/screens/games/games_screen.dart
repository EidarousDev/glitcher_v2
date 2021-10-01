import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/data/models/game_model.dart';
import 'package:glitcher/logic/blocs/game_bloc.dart';
import 'package:glitcher/logic/blocs/games_bloc.dart';
import 'package:glitcher/logic/states/game_state.dart';
import 'package:glitcher/logic/states/games_state.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/ui/list_items/game_item.dart';
import 'package:glitcher/ui/widgets/drawer.dart';
import 'package:glitcher/ui/widgets/gradient_appbar.dart';
import 'package:glitcher/utils/app_util.dart';

class GamesScreen extends StatefulWidget {
  @override
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  bool _searching = false;
  ScrollController _scrollController = ScrollController();
  TextEditingController _typeAheadController = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton.extended(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Suggest'),
            SizedBox(
              width: 5,
            ),
            Icon(
              //Icons.lightbulb_outline,
              Icons.add,
              color: Colors.white, size: 20,
            ),
          ],
        ),
        onPressed: () async {
          Navigator.of(context).pushNamed(RouteList.suggestion, arguments: {
            'initial_title': 'New game suggestion',
            'initial_details':
                'I (${Constants.currentUser.username}) suggest adding the following game: '
          });
          AppUtil.showSnackBar(context, "Suggestion sent ");
        },
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Icon(Icons.menu),
            ),
          ),
        ),
        title: Text("Games"),
        flexibleSpace: gradientAppBar(context),
        centerTitle: true,
      ),
      body: BlocBuilder<GamesBloc, GamesState>(
        builder: (context, gamesState) => Column(
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
                            //BlocProvider.of<GamesBloc>(context).clearGames();
                            setState(() {
                              _searching = false;
                            });
                            showAll();
                          })
                      : null,
                ),
                controller: _typeAheadController,
                onChanged: (text) {
                  if (text.isEmpty) {
                    setState(() {
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
                child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: gamesState.games.length,
              itemBuilder: (BuildContext context, int index) {
                Game game = gamesState.games[index];

                return StreamBuilder(
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return Column(
                    children: <Widget>[
                      BlocProvider<GameBloc>(
                          create: (context) =>
                              GameBloc(GameState(game)),
                          child: GameItem(
                            key: ValueKey(game.id),
                          )),
                      Divider(height: .5, color: Colors.grey)
                    ],
                  );
                });
              },
            )),
          ],
        ),
      ),
      drawer: BuildDrawer(),
    );
  }

  _setupFeed() async {
    if (BlocProvider.of<GamesBloc>(context).games.isEmpty)
      BlocProvider.of<GamesBloc>(context).getGames();
    else
      BlocProvider.of<GamesBloc>(context).showAll();
  }

  _searchGames(String text) async {
    BlocProvider.of<GamesBloc>(context).searchGames(text);
  }

  @override
  void initState() {
    super.initState();

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
      } else {}
    });
    _setupFeed();
  }

  nextGames() async {
    BlocProvider.of<GamesBloc>(context).getMoreGames();
  }

  showAll() {
    BlocProvider.of<GamesBloc>(context).showAll();
  }
}

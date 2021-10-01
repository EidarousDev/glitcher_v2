import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glitcher/logic/blocs/game_bloc.dart';
import 'package:glitcher/logic/states/game_state.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/style/colors.dart';
import 'package:glitcher/ui/widgets/caching_image.dart';
import 'package:glitcher/ui/widgets/custom_loader.dart';

class GameItem extends StatefulWidget {
  final Function onFollow;
  GameItem({Key key, this.onFollow}) : super(key: key);

  @override
  _GameItemState createState() => _GameItemState();
}

class _GameItemState extends State<GameItem> {
  String snackbarText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: InkWell(
        child: _buildItem(),
        onTap: () {},
      ),
    );
  }

  _buildItem() {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, gameState) => Container(
        padding: EdgeInsets.all(7),
        child: ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: CacheThisImage(
            height: 50,
            imageUrl: gameState.game.image,
            imageShape: BoxShape.rectangle,
            width: 50,
          ),
          title: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: Text(
                  gameState.game.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: gameState.game.genres.length > 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        "${gameState.game.genres}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 11,
                        ),
                      ),
                    ])
              : null,
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ButtonTheme(
                height: 20,
                minWidth: 40,
                child: MaterialButton(
                  height: 30,
                  onPressed: () {
                    //DatabaseService.followGame(widget.game.id);
                    followUnfollow(gameState.isFollowed);
                  },
                  textColor: Colors.white,
                  color: kPrimary,
                  child: Text(gameState.isFollowed ? 'Unfollow' : 'Follow'),
                ),
              )
            ],
          ),
          onTap: () {
            Navigator.of(context).pushNamed(RouteList.game, arguments: {
              'game': gameState.game,
            });
          },
        ),
      ),
    );
  }

  followUnfollow(bool isFollowed) async {
    Navigator.of(context).push(CustomScreenLoader());
    isFollowed
        ? BlocProvider.of<GameBloc>(context).unfollowGame()
        : BlocProvider.of<GameBloc>(context).followGame();
    Navigator.of(context).pop();
    if (widget.onFollow != null) {
      widget.onFollow(!isFollowed);
    }
  }

  checkStates() async {
    BlocProvider.of<GameBloc>(context).checkIsFollowing();
  }

  @override
  void initState() {
    checkStates();
    super.initState();
  }
}

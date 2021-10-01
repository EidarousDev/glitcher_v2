import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/data/models/game_model.dart';
import 'package:glitcher/data/repositories/games_repo.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/style/colors.dart';
import 'package:glitcher/ui/widgets/caching_image.dart';
import 'package:glitcher/ui/widgets/custom_loader.dart';

class GameItem extends StatefulWidget {
  final Game game;
  final Function onFollow;
  GameItem({Key key, @required this.game, this.onFollow}) : super(key: key);

  @override
  _GameItemState createState() => _GameItemState();
}

class _GameItemState extends State<GameItem> {
  String followBtnText;

  String snackbarText;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: InkWell(
        child: _buildItem(widget.game),
        onTap: () {},
      ),
    );
  }

  _buildItem(Game game) {
    return Container(
      padding: EdgeInsets.all(7),
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: CacheThisImage(
          height: 50,
          imageUrl: widget.game.image,
          imageShape: BoxShape.rectangle,
          width: 50,
        ),
        title: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              child: Text(
                widget.game.fullName,
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: widget.game.genres.length > 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      "${widget.game.genres}",
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
                  followUnfollow();
                },
                textColor: Colors.white,
                color: kPrimary,
                child: Text(followBtnText == null ? '' : followBtnText),
              ),
            )
          ],
        ),
        onTap: () {
          Navigator.of(context).pushNamed(RouteList.game, arguments: {
            'game': widget.game,
          });
        },
      ),
    );
  }

  followUnfollow() async {
    Navigator.of(context).push(CustomScreenLoader());
    bool isFollowing = false;
    DocumentSnapshot game = await usersRef
        .doc(Constants.currentUserID)
        .collection('followedGames')
        .doc(widget.game.id)
        .get();

    DocumentSnapshot gameInDB = await gamesRef.doc(widget.game.id).get();

    if (game.exists) {
      await GamesRepo.unFollowGame(widget.game.id);
      setState(() {
        followBtnText = 'Follow';
      });
      Constants.followedGamesNames.remove(widget.game.fullName);
      //AppUtil.showSnackBar(context, _scaffoldKey, 'Game unfollowed');
    } else {
      if (!gameInDB.exists) {
        await widget.game.addGamesToFirestore();
      }
      await GamesRepo.followGame(widget.game.id);
      setState(() {
        followBtnText = 'Unfollow';
      });
      Constants.followedGamesNames.add(widget.game.fullName);
      isFollowing = true;
    }
    Navigator.of(context).pop();
    //DatabaseService.getFollowedGames();
    if (widget.onFollow != null) {
      widget.onFollow(isFollowing);
    }
  }

  checkStates() async {
    if (widget.game.id.isEmpty) {
      if (mounted) {
        setState(() {
          followBtnText = 'Follow';
        });
      }
      return;
    }
    DocumentSnapshot game = await usersRef
        .doc(Constants.currentUserID)
        .collection('followedGames')
        .doc(widget.game.id)
        .get();
    if (game.exists) {
      if (mounted) {
        setState(() {
          followBtnText = 'Unfollow';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          followBtnText = 'Follow';
        });
      }
    }
  }

  @override
  void initState() {
    checkStates();
    super.initState();
  }
}

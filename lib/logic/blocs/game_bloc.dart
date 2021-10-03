import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glitcher/data/models/game_model.dart';
import 'package:glitcher/data/repositories/games_repo.dart';
import 'package:glitcher/logic/events/game_event.dart';
import 'package:glitcher/logic/states/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameState initialState;
  GameBloc(GameState initialState) : super(initialState) {
    this.initialState = initialState;
    checkIsFollowing();
  }

  getGame() {
    this.add(GameEvent(GameEventType.get, data: initialState.game.id));
  }

  followGame() {
    this.add(GameEvent(GameEventType.follow, data: initialState.game.id));
  }

  unfollowGame() {
    this.add(GameEvent(GameEventType.unfollow, data: initialState.game.id));
  }

  checkIsFollowing() {
    this.add(
        GameEvent(GameEventType.checkIsFollowing, data: initialState.game.id));
  }

  @override
  Stream<GameState> mapEventToState(GameEvent event) async* {
    switch (event.type) {
      case GameEventType.get:
        Game game = await GamesRepo.getGameWithId(event.data);
        yield GameState(game);
        break;
      case GameEventType.follow:
        await GamesRepo.followGame(initialState.game.id);
        yield GameState(initialState.game, isFollowed: true);
        break;
      case GameEventType.unfollow:
        await GamesRepo.unFollowGame(initialState.game.id);
        yield GameState(initialState.game, isFollowed: false);
        break;
      case GameEventType.checkIsFollowing:
        bool isFollowed =
            await GamesRepo.checkIsFollowing(initialState.game.id);
        yield GameState(initialState.game, isFollowed: isFollowed);
        break;
    }
  }
}

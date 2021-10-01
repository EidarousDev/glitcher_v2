import 'package:glitcher/data/models/game_model.dart';

class GameState {
  final Game game;
  final bool isFollowed;
  factory GameState.initialState() {
    return GameState(Game());
  }
  GameState(this.game, {this.isFollowed = false});
}

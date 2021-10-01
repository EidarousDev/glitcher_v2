import 'package:glitcher/data/models/game_model.dart';

class GamesState {
  final List<Game> games;
  factory GamesState.initialState() {
    return GamesState([]);
  }
  GamesState(this.games);
}

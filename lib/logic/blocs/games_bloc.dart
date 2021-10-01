import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glitcher/data/models/game_model.dart';
import 'package:glitcher/data/repositories/games_repo.dart';
import 'package:glitcher/logic/events/games_event.dart';
import 'package:glitcher/logic/states/games_state.dart';

class GamesBloc extends Bloc<GamesEvent, GamesState> {
  GamesBloc(GamesState initialState) : super(initialState);
  List<Game> games = [];
  List<Game> filteredGames = [];
  getGames() {
    this.add(GamesEvent(GamesEventType.get));
  }

  clearGames() {
    this.add(GamesEvent(GamesEventType.clear));
  }

  getMoreGames() {
    this.add(GamesEvent(GamesEventType.getMore));
  }

  searchGames(String text) {
    this.add(GamesEvent(GamesEventType.search, data: text));
  }

  showAll() {
    this.add(GamesEvent(
      GamesEventType.showAll,
    ));
  }

  @override
  Stream<GamesState> mapEventToState(GamesEvent event) async* {
    switch (event.type) {
      case GamesEventType.get:
        List<Game> games = await GamesRepo.getGames();
        this.games = games;
        yield GamesState(games);
        break;
      case GamesEventType.clear:
        yield GamesState.initialState();
        break;
      case GamesEventType.getMore:
        List<Game> moreGames =
            await GamesRepo.getNextGames(games.last.frequency);
        this.games.addAll(moreGames);
        yield GamesState(this.games);
        break;
      case GamesEventType.search:
        List<Game> games = await GamesRepo.searchGames(event.data);
        this.filteredGames = games;
        yield GamesState(games);
        break;
      case GamesEventType.showAll:
        yield GamesState(games);
        break;
    }
  }
}

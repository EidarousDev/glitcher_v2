enum GamesEventType { get, clear, getMore, search, showAll }

class GamesEvent {
  final GamesEventType type;
  final dynamic data;
  GamesEvent(this.type, {this.data});
}

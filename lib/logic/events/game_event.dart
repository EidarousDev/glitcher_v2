enum GameEventType { get, follow, unfollow, checkIsFollowing }

class GameEvent {
  final GameEventType type;
  final dynamic data;
  GameEvent(this.type, {this.data});
}

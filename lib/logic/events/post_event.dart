enum PostEventType {
  like,
  dislike,
}

class PostEvent {
  final PostEventType type;
  final dynamic data;

  PostEvent(this.type, {this.data});
}

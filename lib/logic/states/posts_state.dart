import 'package:glitcher/data/models/post_model.dart';

class PostsState {
  final List<Post> posts;
  factory PostsState.initialState() {
    return PostsState([]);
  }
  PostsState(this.posts);
}

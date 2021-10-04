import 'package:glitcher/data/models/post_model.dart';

class PostState {
  final Post post;
  final bool isLiked;
  final bool isDisliked;

  factory PostState.initialState() {
    return PostState(Post(), false, false);
  }

  PostState(this.post, this.isLiked, this.isDisliked);
}

import 'package:glitcher/data/models/post_model.dart';

class PostState {
  final Post post;
  final bool isLiked;
  final bool isDisliked;

  factory PostState.initialState() {
    return PostState(
      Post(),
    );
  }

  PostState(this.post, {this.isLiked = false, this.isDisliked = false});
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glitcher/data/repositories/posts_repo.dart';
import 'package:glitcher/logic/events/post_event.dart';
import 'package:glitcher/logic/states/post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostState postState;
  PostBloc(initialState) : super(initialState) {
    this.postState = initialState;
    checkStates();
  }

  checkStates() {
    this.add(PostEvent(PostEventType.checkStates));
  }

  like() {
    this.add(PostEvent(PostEventType.like));
  }

  dislike() {
    this.add(PostEvent(PostEventType.dislike));
  }

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    switch (event.type) {
      case PostEventType.get:
        // TODO: Handle this case.
        break;
      case PostEventType.like:
        if (postState.isLiked == true && postState.isDisliked == false) {
          await PostsRepo.removeLike(postState.post);
          postState.post.likesCount--;
          postState =
              PostState(postState.post, isLiked: false, isDisliked: false);
          yield PostState(postState.post, isLiked: false, isDisliked: false);
        } else if (postState.isDisliked == true && postState.isLiked == false) {
          await PostsRepo.removeDislike(postState.post);
          await PostsRepo.addLike(postState.post);
          postState.post.disLikesCount--;
          postState.post.likesCount++;
          postState =
              PostState(postState.post, isLiked: true, isDisliked: false);
          yield PostState(postState.post, isLiked: true, isDisliked: false);
        } else if (postState.isLiked == false &&
            postState.isDisliked == false) {
          await PostsRepo.addLike(postState.post);
          postState.post.likesCount++;
          postState =
              PostState(postState.post, isLiked: true, isDisliked: false);
          yield PostState(postState.post, isLiked: true, isDisliked: false);
        } else {
          throw Exception('Unconditional Event Occurred!');
        }
        break;
      case PostEventType.dislike:
        if (postState.isDisliked == true && postState.isLiked == false) {
          await PostsRepo.removeDislike(postState.post);
          postState.post.disLikesCount--;
          postState =
              PostState(postState.post, isLiked: false, isDisliked: false);
          yield PostState(postState.post, isLiked: false, isDisliked: false);
        } else if (postState.isLiked == true && postState.isDisliked == false) {
          await PostsRepo.removeLike(postState.post);
          await PostsRepo.addDislike(postState.post);
          postState.post.likesCount--;
          postState.post.disLikesCount++;
          postState =
              PostState(postState.post, isLiked: false, isDisliked: true);
          yield PostState(postState.post, isLiked: false, isDisliked: true);
        } else if (postState.isDisliked == false &&
            postState.isLiked == false) {
          await PostsRepo.addDislike(postState.post);
          postState.post.disLikesCount++;

          postState =
              PostState(postState.post, isLiked: false, isDisliked: true);
          yield PostState(postState.post, isLiked: false, isDisliked: true);
        } else {
          throw Exception('Unconditional Event Occurred.');
        }

        break;
      case PostEventType.checkStates:
        bool isLiked = await PostsRepo.isPostLiked(postState.post.id);
        bool isDisliked = await PostsRepo.isPostDisliked(postState.post.id);
        this.postState =
            PostState(postState.post, isDisliked: isDisliked, isLiked: isLiked);
        yield PostState(postState.post,
            isLiked: isLiked, isDisliked: isDisliked);
        break;
    }
  }
}

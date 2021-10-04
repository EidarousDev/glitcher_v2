import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glitcher/data/models/post_model.dart';
import 'package:glitcher/data/repositories/posts_repo.dart';
import 'package:glitcher/logic/events/posts_event.dart';
import 'package:glitcher/logic/states/posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  PostsBloc(PostsState initialState) : super(initialState);
  List<Post> posts = [];
  int feedFilter = 0;

  getPosts() {
    this.add(PostsEvent(PostsEventType.get));
  }

  getMorePosts() {
    this.add(PostsEvent(PostsEventType.getMore));
  }

  filterByFollowing() {
    this.add(PostsEvent(PostsEventType.filterByFollowing));
  }

  filterByFollowedGames() {
    this.add(PostsEvent(PostsEventType.filterByFollowedGames));
  }

  clearFilter() {
    this.add(PostsEvent(PostsEventType.clearFilter));
  }

  setFilter(int filter) {
    this.add(PostsEvent(PostsEventType.setFilter, data: filter));
  }

  getBookmarks() {
    this.add(PostsEvent(PostsEventType.getBookmarks));
  }

  getMoreBookmarks() {
    this.add(PostsEvent(PostsEventType.getMoreBookmarks));
  }

  getHashtagPosts(String hashtag) {
    this.add(
      PostsEvent(PostsEventType.getHashtagPosts, data: hashtag),
    );
  }

  getMoreHashtagPosts(String hashtag) {
    this.add(
      PostsEvent(PostsEventType.getMoreHashtagPosts, data: hashtag),
    );
  }

  getUserPosts(String userId) {
    this.add(PostsEvent(PostsEventType.getUserPosts, data: userId));
  }

  getMoreUserPosts(String userId) {
    this.add(PostsEvent(PostsEventType.getMoreUserPosts, data: userId));
  }

  getGamePosts(String gameName) {
    this.add(PostsEvent(PostsEventType.getGamePosts, data: gameName));
  }

  getMoreGamePosts(String gameName) {
    this.add(PostsEvent(PostsEventType.getMoreGamePosts, data: gameName));
  }

  @override
  Stream<PostsState> mapEventToState(PostsEvent event) async* {
    switch (event.type) {
      case PostsEventType.get:
        List<Post> posts;
        switch (feedFilter) {
          case 0:
            posts = await PostsRepo.getPosts();
            break;
          case 1:
            posts = await PostsRepo.getPostsFilteredByFollowing();
            break;
          case 2:
            posts = await PostsRepo.getPostsFilteredByFollowedGames();
        }
        this.posts = posts;
        yield PostsState(posts);
        break;
      case PostsEventType.getMore:
        List<Post> posts;
        switch (feedFilter) {
          case 0:
            posts = await PostsRepo.getNextPosts(this.posts.last.timestamp);
            break;
          case 1:
            posts = await PostsRepo.getNextPostsFilteredByFollowing(
                this.posts.last.timestamp);
            break;
          case 2:
            posts = await PostsRepo.getNextPostsFilteredByFollowedGames(
                this.posts.last.timestamp);
        }
        this.posts.addAll(posts);
        yield PostsState(this.posts);
        break;
      case PostsEventType.getBookmarks:
        List<Post> posts = await PostsRepo.getBookmarksPosts();
        this.posts = posts;
        yield PostsState(posts);
        break;
      case PostsEventType.getMoreBookmarks:
        List<Post> posts =
            await PostsRepo.getNextBookmarksPosts(this.posts.last.timestamp);
        this.posts.addAll(posts);
        yield PostsState(this.posts);
        break;
      case PostsEventType.getHashtagPosts:
        List<Post> posts = await PostsRepo.getHashtagPosts(event.data);
        this.posts = posts;
        yield PostsState(posts);
        break;
      case PostsEventType.getMoreHashtagPosts:
        List<Post> posts = await PostsRepo.getNextHashtagPosts(
            this.posts.last.timestamp, event.data);
        this.posts.addAll(posts);
        yield PostsState(this.posts);
        break;
      case PostsEventType.filterByFollowing:
        this.feedFilter = 1;
        //getPosts();
        break;
      case PostsEventType.filterByFollowedGames:
        this.feedFilter = 2;
        break;
      case PostsEventType.clearFilter:
        this.feedFilter = 0;
        break;
      case PostsEventType.setFilter:
        this.feedFilter = event.data;
        break;
      case PostsEventType.getUserPosts:
        List<Post> posts = await PostsRepo.getUserPosts(event.data);
        this.posts = posts;
        yield PostsState(posts);
        break;
      case PostsEventType.getMoreUserPosts:
        List<Post> posts = await PostsRepo.getNextUserPosts(
            event.data, this.posts.last.timestamp);
        this.posts.addAll(posts);
        yield PostsState(this.posts);
        break;
      case PostsEventType.getGamePosts:
        List<Post> posts = await PostsRepo.getGamePosts(event.data);
        this.posts = posts;
        yield PostsState(posts);
        break;
      case PostsEventType.getMoreGamePosts:
        List<Post> posts = await PostsRepo.getNextGamePosts(
            event.data, this.posts.last.timestamp);
        this.posts.addAll(posts);
        yield PostsState(this.posts);
        break;
    }
  }
}

enum PostsEventType {
  get,
  getMore,
  getBookmarks,
  getMoreBookmarks,
  getHashtagPosts,
  getMoreHashtagPosts,
  getUserPosts,
  getMoreUserPosts,
  getGamePosts,
  getMoreGamePosts,
  filterByFollowing,
  filterByFollowedGames,
  clearFilter,
  setFilter,
}

class PostsEvent {
  final PostsEventType type;
  final dynamic data;
  PostsEvent(this.type, {this.data});
}

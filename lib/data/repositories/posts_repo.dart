import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/data/models/post_model.dart';
import 'package:glitcher/utils/app_util.dart';

class PostsRepo {
  // This function is used to get the recent posts (unfiltered)
  static Future<List<Post>> getPosts() async {
    QuerySnapshot postSnapshot =
        await postsRef.orderBy('timestamp', descending: true).limit(20).get();
    List<Post> posts =
        postSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  //Gets the posts of a certain user
  static Future<List<Post>> getUserPosts(String authorId) async {
    QuerySnapshot postSnapshot = await postsRef
        .where('author', isEqualTo: authorId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    List<Post> posts =
        postSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  // This function is used to get the recent posts of a certain user
  static Future<List<Post>> getNextUserPosts(
      String authorId, Timestamp lastVisiblePostSnapShot) async {
    QuerySnapshot postSnapshot = await postsRef
        .where('author', isEqualTo: authorId)
        .orderBy('timestamp', descending: true)
        .startAfter([lastVisiblePostSnapShot])
        .limit(20)
        .get();
    List<Post> posts =
        postSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  // This function is used to get the recent posts (unfiltered)
  static Future<List<Post>> getNextPosts(
      Timestamp lastVisiblePostSnapShot) async {
    QuerySnapshot postSnapshot = await postsRef
        .orderBy('timestamp', descending: true)
        .startAfter([lastVisiblePostSnapShot])
        .limit(20)
        .get();
    List<Post> posts =
        postSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  // This function is used to get the recent user posts (unfiltered)
  static Future<List<Post>> getUserNextPosts(
      Timestamp lastVisiblePostSnapShot, String authorId) async {
    QuerySnapshot postSnapshot = await postsRef
        .where('author', isEqualTo: authorId)
        .orderBy('timestamp', descending: true)
        .startAfter([lastVisiblePostSnapShot])
        .limit(20)
        .get();
    List<Post> posts =
        postSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<Post> getUserLastPost(String authorId) async {
    QuerySnapshot postSnapshot = await postsRef
        .where('author', isEqualTo: authorId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    List<Post> posts =
        postSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();

    if (posts == null || posts.isEmpty) {
      return null;
    } else {
      return posts[0];
    }
  }

  // Get Post info of a specific post
  static Future<Post> getPostWithId(String postId) async {
    DocumentSnapshot postDocSnapshot = await postsRef.doc(postId).get();
    if (postDocSnapshot.exists) {
      return Post.fromDoc(postDocSnapshot);
    }
    return Post();
  }

  // Get Post Meta Info of a specific post
  static Future<Map> getPostMeta(String postId) async {
    var postMeta = Map();
    DocumentSnapshot postDocSnapshot = await postsRef.doc(postId).get();
    if (postDocSnapshot.exists) {
      postMeta['likes'] = postDocSnapshot['likes'];
      postMeta['dislikes'] = postDocSnapshot['dislikes'];
      postMeta['comments'] = postDocSnapshot['comments'];
    }
    return postMeta;
  }

  // This function is used to get the recent posts for a certain tag
  static Future<List<Post>> getHashtagPosts(String hashtagId) async {
    QuerySnapshot postSnapshot = await hashtagsRef
        .doc(hashtagId)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();

    List<Post> posts = [];

    for (DocumentSnapshot doc in postSnapshot.docs) {
      DocumentSnapshot postDoc = await postsRef.doc(doc.id).get();

      if (postDoc.exists) {
        posts.add(await getPostWithId(doc.id));
      } else {
        hashtagsRef.doc(hashtagId).collection('posts').doc(doc.id).delete();
      }
    }

    return posts;
  }

  // This function is used to get the recent posts (filtered by a certain game)
  static Future<List<Post>> getNextHashtagPosts(
      Timestamp lastVisiblePostSnapShot, String hashtagId) async {
    QuerySnapshot postSnapshot = await hashtagsRef
        .doc(hashtagId)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .startAfter([lastVisiblePostSnapShot])
        .limit(20)
        .get();

    List<Post> posts = [];

    for (DocumentSnapshot doc in postSnapshot.docs) {
      DocumentSnapshot postDoc = await postsRef.doc(doc.id).get();

      if (postDoc.exists) {
        posts.add(await getPostWithId(doc.id));
      } else {
        hashtagsRef.doc(hashtagId).collection('posts').doc(doc.id).delete();
      }
    }

    return posts;
  }

  static Future<List<Post>> getBookmarksPosts() async {
    QuerySnapshot postSnapshot = await usersRef
        .doc(Constants.currentUserID)
        .collection('bookmarks')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();

    List<Post> posts = [];

    for (DocumentSnapshot doc in postSnapshot.docs) {
      DocumentSnapshot postDoc = await postsRef.doc(doc.id).get();

      if (postDoc.exists) {
        Post post = await getPostWithId(doc.id);

        posts.add(post);
      } else {
        posts.add(Post(id: doc.id, authorId: 'deleted'));
//        usersRef
//            .doc(Constants.currentUserID)
//            .collection('bookmarks')
//            .doc(doc.id)
//            .delete();
      }
    }
    return posts;
  }

  static Future<List<Post>> getNextBookmarksPosts(
      Timestamp lastVisiblePostSnapShot) async {
    QuerySnapshot postsSnapshot = await usersRef
        .doc(Constants.currentUserID)
        .collection('bookmarks')
        .orderBy('timestamp', descending: true)
        .startAfter([lastVisiblePostSnapShot])
        .limit(20)
        .get();

    List<Post> posts = [];

    for (DocumentSnapshot doc in postsSnapshot.docs) {
      DocumentSnapshot postDoc = await postsRef.doc(doc.id).get();

      if (postDoc.exists) {
        posts.add(await getPostWithId(doc.id));
      } else {
        usersRef
            .doc(Constants.currentUserID)
            .collection('bookmarks')
            .doc(doc.id)
            .delete();
      }
    }

    return posts;
  }

  // This function is used to get the recent posts (filtered by a certain game)
  static Future<List<Post>> getGamePosts(String gameName) async {
    QuerySnapshot postSnapshot = await postsRef
        .where('game', isEqualTo: gameName)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    List<Post> posts =
        postSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  // This function is used to get the recent posts (filtered by a certain game)
  static Future<List<Post>> getNextGamePosts(
    String gameName,
    Timestamp lastVisiblePostSnapShot,
  ) async {
    QuerySnapshot postSnapshot = await postsRef
        .where('game', isEqualTo: gameName)
        .orderBy('timestamp', descending: true)
        .startAfter([lastVisiblePostSnapShot])
        .limit(20)
        .get();
    List<Post> posts =
        postSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<List<Post>> getPostsFilteredByFollowedGames() async {
    List list = [];
    if (Constants.followedGamesNames.length > 10) {
      list = AppUtil.randomIndices(Constants.followedGamesNames);
    } else {
      list = Constants.followedGamesNames;
    }
    QuerySnapshot postSnapshot = await postsRef
        .where('game', whereIn: list)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    List<Post> posts =
        postSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<List<Post>> getPostsFilteredByFollowing() async {
    List list = [];
    if (Constants.followingIds.length > 10) {
      list = AppUtil.randomIndices(Constants.followingIds);
    } else {
      list = Constants.followingIds;
    }
    QuerySnapshot postSnapshot = await postsRef
        .where('author', whereIn: list)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    List<Post> posts =
        postSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  // This function is used to get the recent posts (filtered by followed games)
  static Future<List<Post>> getNextPostsFilteredByFollowedGames(
      Timestamp lastVisiblePostSnapShot) async {
    List list = [];
    if (Constants.followedGamesNames.length > 10) {
      list = AppUtil.randomIndices(Constants.followedGamesNames);
    } else {
      list = Constants.followedGamesNames;
    }

    QuerySnapshot postSnapshot = await postsRef
        .where('game', whereIn: list)
        .orderBy('timestamp', descending: true)
        .startAfter([lastVisiblePostSnapShot])
        .limit(20)
        .get();
    List<Post> posts =
        postSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  // This function is used to get the recent posts (filtered by followed gamers)
  static Future<List<Post>> getNextPostsFilteredByFollowing(
      Timestamp lastVisiblePostSnapShot) async {
    List list = [];
    if (Constants.followingIds.length > 10) {
      list = AppUtil.randomIndices(Constants.followingIds);
    } else {
      list = Constants.followedGamesNames;
    }

    QuerySnapshot postSnapshot = await postsRef
        .where('author', whereIn: list)
        .orderBy('timestamp', descending: true)
        .startAfter([lastVisiblePostSnapShot])
        .limit(20)
        .get();
    List<Post> posts =
        postSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }
}

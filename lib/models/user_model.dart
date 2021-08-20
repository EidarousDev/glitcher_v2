import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  String id;
  String name;
  String username;
  String profileImageUrl;
  String coverImageUrl;
  String email;
  String description;
  dynamic online;
  int violations;
  int following;
  int followers;
  int friends;
  int followedGames;
  bool isAccountPrivate;
  int notificationsNumber;
  int messagesNumber;
  List search;
  int isFollower;
  int isFollowing;
  int isFriend;

  User(
      {this.id,
      this.name,
      this.username,
      this.profileImageUrl,
      this.coverImageUrl,
      this.email,
      this.description,
      this.online,
      this.violations,
      this.following,
      this.followers,
      this.friends,
      this.followedGames,
      this.isAccountPrivate,
      this.notificationsNumber,
      this.messagesNumber,
      this.search,
      this.isFollower,
      this.isFollowing,
      this.isFriend});

  factory User.fromDoc(DocumentSnapshot doc) {
    Map data = doc.data();

    return User(
        id: doc.id,
        name: data['name'],
        username: data['username'],
        profileImageUrl: data['profile_url'],
        coverImageUrl: data['cover_url'],
        email: data['email'],
        description: data['description'] ?? '',
        online: data['online'],
        violations: data['violations'],
        following: data['following'],
        followers: data['followers'],
        friends: data['friends'],
        followedGames: data['followed_games'],
        isAccountPrivate: data['is_account_private'],
        notificationsNumber: data['notificationsNumber'],
        messagesNumber: data['messagesNumber'],
        search: data['search']);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': this.id,
      'name': this.name,
      'username': this.username,
      'profile_url': this.profileImageUrl,
      'cover_url': this.coverImageUrl,
      'description': this.description,
      'following': this.following,
      'followers': this.followers,
      'friends': this.friends,
      'followed_games': this.followedGames,
      'is_follower': this.isFollower ?? 0,
      'is_following': this.isFollowing ?? 0,
      'is_friend': this.isFriend ?? 0,
    };
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      username: map['username'],
      profileImageUrl: map['profile_url'],
      coverImageUrl: map['cover_url'],
      description: map['description'],
      following: map['following'],
      followers: map['followers'],
      friends: map['friends'],
      followedGames: map['followed_games'],
      isFollower: map['is_follower'],
      isFollowing: map['is_following'],
      isFriend: map['is_friend'],
    );
  }

  void setData(User user) {
    id = user.id;
    name = user.name;
    username = user.username;
    profileImageUrl = user.profileImageUrl;
    coverImageUrl = user.coverImageUrl;
    email = user.email;
    description = user.description;
    online = user.online;
    violations = user.violations;
    following = user.following;
    followers = user.followers;
    friends = user.friends;
    followedGames = user.followedGames;
    isAccountPrivate = user.isAccountPrivate;
    notificationsNumber = user.notificationsNumber;
    messagesNumber = user.messagesNumber;
    search = user.search;
    isFollower = user.isFollower;
    isFollowing = user.isFollowing;
    isFriend = user.isFriend;
    notifyListeners();
  }

  void setFollowingGames(int value) {
    followedGames = value;
    notifyListeners();
  }
}

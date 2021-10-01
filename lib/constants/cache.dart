import 'package:glitcher/data/models/notification_model.dart';
import 'package:glitcher/data/models/post_model.dart';
import 'package:glitcher/data/models/user_model.dart';

class Cache {
  static Map<String, Post> postsMap;
  static List<Post> homePosts = List<Post>();
  static Map<String, User> usersMap;
  static Map<String, Notification> notificationsMap;
  static List<Notification> notifications;
}

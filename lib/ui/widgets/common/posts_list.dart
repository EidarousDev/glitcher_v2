import 'package:flutter/material.dart';
import 'package:glitcher/data/models/post_model.dart';
import 'package:glitcher/data/models/user_model.dart';
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/ui/list_items/post_item.dart';

class PostsList extends StatelessWidget {
  final List<Post> posts;

  const PostsList({Key key, this.posts}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: posts.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        Post post = posts[index];
        return FutureBuilder(
            future:
                DatabaseService.getUserWithId(post.authorId, checkLocal: false),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }
              User author = snapshot.data;
              return PostItem(key: Key(post.id), post: post, author: author);
            });
      },
    );
  }
}

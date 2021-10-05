import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glitcher/data/models/post_model.dart';
import 'package:glitcher/logic/blocs/post_bloc.dart';
import 'package:glitcher/logic/states/post_state.dart';
import 'package:glitcher/ui/list_items/post_item.dart';

class PostsList extends StatelessWidget {
  final List<Post> posts;

  const PostsList({Key key, this.posts}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      addAutomaticKeepAlives: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: posts.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        Post post = posts[index];
        return BlocProvider<PostBloc>.value(
            key: Key(post.id),
            value: PostBloc(PostState(
              post,
            )),
            child: PostItem(
              key: Key(post.id),
              post: post,
            ));
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glitcher/data/models/hashtag_model.dart';
import 'package:glitcher/logic/blocs/posts_bloc.dart';
import 'package:glitcher/logic/states/posts_state.dart';
import 'package:glitcher/ui/widgets/common/gradient_appbar.dart';
import 'package:glitcher/ui/widgets/common/posts_list.dart';

class HashtagPostsScreen extends StatefulWidget {
  final Hashtag hashtag;
  const HashtagPostsScreen(this.hashtag);
  @override
  _HashtagPostsScreenState createState() => _HashtagPostsScreenState();
}

class _HashtagPostsScreenState extends State<HashtagPostsScreen>
    with WidgetsBindingObserver {
  ScrollController _scrollController = ScrollController();
  _HashtagPostsScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: gradientAppBar(context),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            _onBackPressed();
          },
        ),
        title: Text(widget.hashtag.text),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: BlocBuilder<PostsBloc, PostsState>(
          builder: (context, postsState) => PostsList(
            posts: postsState.posts,
          ),
        ),
      ),
    );
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  _setupFeed() async {
    BlocProvider.of<PostsBloc>(context).getHashtagPosts(widget.hashtag.id);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    ///Set up listener here
    _scrollController
      ..addListener(() {
        if (_scrollController.offset >=
                _scrollController.position.maxScrollExtent &&
            !_scrollController.position.outOfRange) {
          //print('reached the bottom');
          _nextHashtagPosts();
        } else if (_scrollController.offset <=
                _scrollController.position.minScrollExtent &&
            !_scrollController.position.outOfRange) {
          //print("reached the top");
        } else {}
      });
    _setupFeed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
        .dispose(); // it is a good practice to dispose the controller
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      _setupFeed();
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
      _setupFeed();
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
      _setupFeed();
    } else if (state == AppLifecycleState.detached) {
      // app suspended (not used in iOS)
    }
  }

  void _nextHashtagPosts() async {
    BlocProvider.of<PostsBloc>(context).getMoreHashtagPosts(widget.hashtag.id);
  }
}

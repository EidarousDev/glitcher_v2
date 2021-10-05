import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/constants/sizes.dart';
import 'package:glitcher/constants/strings.dart';
import 'package:glitcher/data/models/app_model.dart';
import 'package:glitcher/data/models/game_model.dart';
import 'package:glitcher/data/models/hashtag_model.dart';
import 'package:glitcher/data/models/post_model.dart';
import 'package:glitcher/data/models/user_model.dart';
import 'package:glitcher/data/repositories/games_repo.dart';
import 'package:glitcher/logic/blocs/game_bloc.dart';
import 'package:glitcher/logic/blocs/post_bloc.dart';
import 'package:glitcher/logic/states/game_state.dart';
import 'package:glitcher/logic/states/post_state.dart';
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/services/share_link.dart';
import 'package:glitcher/ui/screens/home/home_screen.dart';
import 'package:glitcher/ui/widgets/bottom_sheets/post_bottom_sheet.dart';
import 'package:glitcher/ui/widgets/common/caching_image.dart';
import 'package:glitcher/ui/widgets/common/verifiend_badge.dart';
import 'package:glitcher/ui/widgets/image_overlay.dart';
import 'package:glitcher/utils/app_util.dart';
import 'package:glitcher/utils/functions.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import '../widgets/common/custom_url_text.dart';

class PostItem extends StatefulWidget {
  final Post post;
  final bool isLoading;
  final Widget youtubePlayer;
  final bool loadVideo;
  final bool isClickable;
  PostItem(
      {Key key,
      @required this.post,
      this.youtubePlayer,
      this.isClickable = true,
      this.isLoading = false,
      this.loadVideo = false})
      : super(key: key);
  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem>
    with AutomaticKeepAliveClientMixin {
  /// On-the-fly audio data for the second card.
  //YoutubePlayerController _youtubeController;
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  Chewie playerWidget;
  String dropdownValue = 'Edit';
  bool isLikeEnabled = true;
  bool isDislikedEnabled = true;
  var likes = [];
  var dislikes = [];

  String firstHalf;
  String secondHalf;
  bool flag = true;
  Game currentGame;
  final number = ValueNotifier(0);

  String _hashtagText = '';

  String _mentionText;

  var audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return _buildPost();
  }

  User _author;
  getAuthor() async {
    User author = await DatabaseService.getUserWithId(widget.post.authorId,
        checkLocal: false);
    setState(() {
      _author = author;
    });
  }

  _buildPost() {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, postState) => InkWell(
        onTap: () => _goToPostPreview(postState.post),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: <Widget>[
              Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    leading: widget.isLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              width: Sizes.md_profile_image_w,
                              height: Sizes.md_profile_image_h,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : InkWell(
                            child: CacheThisImage(
                              imageUrl: _author?.profileImageUrl,
                              imageShape: BoxShape.circle,
                              width: Sizes.md_profile_image_w,
                              height: Sizes.md_profile_image_h,
                              defaultAssetImage: Strings.default_profile_image,
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(RouteList.profile, arguments: {
                                'userId': postState.post.authorId,
                              });
                            }),
                    title: widget.isLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.grey[300],
                              height: 10,
                              width: 70,
                            ))
                        : Row(
                            children: <Widget>[
                              InkWell(
                                child: Text('@${_author?.username}' ?? '',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: MyColors.darkPrimary)),
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(RouteList.profile, arguments: {
                                    'userId': _author?.id,
                                  });
                                },
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              _author?.isVerified ?? false
                                  ? VerifiendBadge()
                                  : Container()
                            ],
                          ),
                    subtitle: widget.isLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.grey[300],
                              height: 10,
                              width: 70,
                            ))
                        : InkWell(
                            child: Text('↳ ${postState.post.game}' ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: MyColors.darkGrey,
                                )),
                            onTap: () {
                              //print('currentGame : ${currentGame.id}');
                              Navigator.of(context)
                                  .pushNamed(RouteList.game, arguments: {
                                'gameBloc': GameBloc(
                                  GameState(currentGame),
                                )
                              });
                            },
                          ),
                    trailing: ValueListenableBuilder<int>(
                      valueListenable: number,
                      builder: (context, value, child) {
                        return PostBottomSheet().postOptionIcon(
                          context,
                          postState.post,
                        );
                      },
                    ),
                  ),
                  widget.isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.grey[100],
                          child: Container(
                            color: Colors.grey[300],
                            height: 200,
                            width: MediaQuery.of(context).size.width - 20,
                          ))
                      : Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    secondHalf.isEmpty
                                        ? GestureDetector(
                                            onLongPress: () async {
                                              _onLongPressedPost(context);
                                            },
                                            onTap: () => _goToPostPreview(
                                                postState.post),
                                            child: UrlText(
                                              context: context,
                                              text: postState.post.text,
                                              onMentionPressed: (text) =>
                                                  mentionedUserProfile(),
                                              onHashTagPressed: (text) =>
                                                  hashtagScreen(),
                                              style: TextStyle(
                                                color: switchColor(context,
                                                    Colors.black, Colors.white),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              urlStyle: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )
                                        : GestureDetector(
                                            onLongPress: () async {
                                              _onLongPressedPost(context);
                                            },
                                            onTap: () => _goToPostPreview(
                                                postState.post),
                                            child: UrlText(
                                              context: context,
                                              text: flag
                                                  ? (firstHalf + '...')
                                                  : (firstHalf + secondHalf),
                                              onMentionPressed: (text) =>
                                                  mentionedUserProfile(),
                                              onHashTagPressed: (text) =>
                                                  hashtagScreen(),
                                              style: TextStyle(
                                                color: switchColor(context,
                                                    Colors.black, Colors.white),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              urlStyle: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                    InkWell(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          secondHalf.isEmpty
                                              ? Text('')
                                              : Text(
                                                  flag
                                                      ? 'Show more'
                                                      : 'Show less',
                                                  style: TextStyle(
                                                      color:
                                                          MyColors.darkPrimary),
                                                )
                                        ],
                                      ),
                                      onTap: () {
                                        setState(() {
                                          flag = !flag;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 8.0,
                                    ),
                                    Container(
                                      child: postState.post.imageUrl == null
                                          ? null
                                          : Container(
                                              width: Sizes.home_post_image_w,
                                              height: Sizes.home_post_image_h,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: InkWell(
                                                      onTap: () {
                                                        showDialog(
                                                            barrierDismissible:
                                                                true,
                                                            builder: (_) {
                                                              return Container(
                                                                width: Sizes
                                                                    .sm_profile_image_w,
                                                                height: Sizes
                                                                    .sm_profile_image_h,
                                                                child:
                                                                    ImageOverlay(
                                                                  imageUrl:
                                                                      postState
                                                                          .post
                                                                          .imageUrl,
                                                                  btnText: Strings
                                                                      .SAVE_IMAGE,
                                                                  btnFunction:
                                                                      () {},
                                                                ),
                                                              );
                                                            },
                                                            context: context);
                                                      },
                                                      child: CacheThisImage(
                                                        imageUrl: postState
                                                            .post.imageUrl,
                                                        imageShape:
                                                            BoxShape.rectangle,
                                                        width: Sizes
                                                            .home_post_image_w,
                                                        height: Sizes
                                                            .home_post_image_h,
                                                        defaultAssetImage: Strings
                                                            .default_post_image,
                                                      ))),
                                            ),
                                    ),
                                    postState.post.video != null
                                        ? widget.loadVideo
                                            ? Container(
                                                child: postState.post.video ==
                                                        null
                                                    ? null
                                                    : AspectRatio(
                                                        aspectRatio:
                                                            videoPlayerController
                                                                .value
                                                                .aspectRatio,
                                                        child: playerWidget),
                                              )
                                            : Center(
                                                child: Stack(
                                                  children: [
                                                    _videoThumbnail != null
                                                        ? Image.file(
                                                            File(
                                                                _videoThumbnail),
                                                            fit:
                                                                BoxFit.fitWidth,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            height: 200,
                                                          )
                                                        : Image.asset(
                                                            Strings
                                                                .default_post_image,
                                                            fit:
                                                                BoxFit.fitWidth,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            height: 200,
                                                          ),
                                                    Positioned.fill(
                                                        child: Align(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .black54,
                                                                shape: BoxShape
                                                                    .circle),
                                                        child: Icon(
                                                          Icons.play_arrow,
                                                          color: Colors.white,
                                                          size: 50,
                                                        ),
                                                      ),
                                                    ))
                                                  ],
                                                ),
                                              )
                                        : Container(),
                                    postState.post.youtubeId != null &&
                                            postState.post.imageUrl == null
                                        ? widget.youtubePlayer != null
                                            ? widget.youtubePlayer
                                            : InkWell(
                                                onTap: () => _goToPostPreview(
                                                    postState.post),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                        child: CacheThisImage(
                                                      imageUrl:
                                                          'https://img.youtube.com/vi/${postState.post.youtubeId}/0.jpg',
                                                      defaultAssetImage: Strings
                                                          .default_post_image,
                                                      height: 200,
                                                      imageShape:
                                                          BoxShape.rectangle,
                                                    )),
                                                    Positioned.fill(
                                                      child: Align(
                                                        child: _youtubeBtn(),
                                                        alignment:
                                                            Alignment.center,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                        : Container(),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "${Functions.formatTimestamp(postState.post.timestamp)}",
                                        style: TextStyle(
                                            fontSize: 13.0,
                                            color: switchColor(
                                                context,
                                                MyColors.darkGrey,
                                                Colors.white70)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: double.infinity,
                      height: .5,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 1.0,
                width: double.infinity,
                child: DecoratedBox(
                  decoration:
                      BoxDecoration(color: Theme.of(context).dividerColor),
                ),
              ),
              Container(
                height: Sizes.inline_break,
                color: Theme.of(context).cardColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    InkWell(
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            child: postState.isLiked
                                ? Icon(
                                    FontAwesome.thumbs_up,
                                    size: Sizes.card_btn_size,
                                    color: MyColors.darkPrimary,
                                  )
                                : Icon(
                                    FontAwesome.thumbs_o_up,
                                    size: Sizes.card_btn_size,
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(
                              '${postState.post.likesCount ?? 0}',
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        if (isLikeEnabled) {
                          audioPlayer
                              .setAsset(
                                Strings.like_sound,
                              )
                              .then((value) => audioPlayer.play());
                          await likeBtnHandler(postState.post);
                        }
                      },
                    ),
                    SizedBox(
                      width: 1.0,
                      height: Sizes.inline_break,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor),
                      ),
                    ),
                    InkWell(
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            child: postState.isDisliked
                                ? Icon(
                                    FontAwesome.thumbs_down,
                                    size: Sizes.card_btn_size,
                                    color: MyColors.darkPrimary,
                                  )
                                : Icon(
                                    FontAwesome.thumbs_o_down,
                                    size: Sizes.card_btn_size,
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(
                              '${postState.post.disLikesCount ?? 0}',
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        if (isDislikedEnabled) {
                          audioPlayer
                              .setAsset(
                                Strings.dislike_sound,
                              )
                              .then((value) => audioPlayer.play());
                          await dislikeBtnHandler(postState.post);
                        }
                      },
                    ),
                    SizedBox(
                      width: 1.0,
                      height: Sizes.inline_break,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor),
                      ),
                    ),
                    InkWell(
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: Sizes.card_btn_size,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(
                              '${postState.post.commentsCount ?? 0}',
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
//                    Navigator.of(context).pushNamed(RouteList.post, arguments: {
//                      'post': post,
//                      'commentsNo': post.commentsCount
//                    });
                        if (_author != null)
                          Navigator.of(context)
                              .pushNamed(RouteList.addComment, arguments: {
                            'post': postState.post,
                            'user': _author,
                          });
                      },
                    ),
                    SizedBox(
                      width: 1.0,
                      height: Sizes.inline_break,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor),
                      ),
                    ),
                    InkWell(
                      child: SizedBox(
                        child: Icon(
                          Icons.share,
                          size: Sizes.card_btn_size,
                        ),
                      ),
                      onTap: () async {
                        await sharePost(postState.post.id, postState.post.text,
                            postState.post.imageUrl);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5.0,
                width: double.infinity,
                child: DecoratedBox(
                  decoration:
                      BoxDecoration(color: Theme.of(context).dividerColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sharing a post with a shortened url
  sharePost(String postId, String postText, String imageUrl) async {
    var postLink = await DynamicLinks(
            Provider.of<AppModel>(context, listen: false)
                .packageInfo
                .packageName)
        .createPostDynamicLink(
            {'postId': postId, 'text': postText, 'imageUrl': imageUrl});
    Share.share('Check out: $postText : $postLink');
    //print('Check out: $postText : $postLink');
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  String _videoThumbnail;
  createVideoThumbnail() async {
    String thumbnail;
    if (!widget.loadVideo && widget.post.video != null) {
      thumbnail = await AppUtil.createVideoThumbnail(widget.post.video);
    }
    setState(() {
      _videoThumbnail = thumbnail;
    });
  }

  @override
  void initState() {
    super.initState();
    getAuthor();
    createVideoThumbnail();
    checkIfContainsHashtag();
    checkIfContainsMention();
    setCurrentGame();
    if (widget.post.text.length > Sizes.postExcerpt) {
      firstHalf = widget.post.text.substring(0, Sizes.postExcerpt);
      secondHalf = widget.post.text
          .substring(Sizes.postExcerpt, widget.post.text.length);
    } else {
      firstHalf = widget.post.text;
      secondHalf = "";
    }
    if (widget.post.video != null) {
      videoPlayerController = VideoPlayerController.network(widget.post.video)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          chewieController = ChewieController(
            videoPlayerController: videoPlayerController,
            autoPlay: false,
            looping: false,
          );

          setState(() {
            playerWidget = Chewie(
              controller: chewieController,
            );
          });
        });
    }
  }

  Future<void> likeBtnHandler(Post post) async {
    setState(() {
      isLikeEnabled = false;
    });
    await BlocProvider.of<PostBloc>(context).like();
    setState(() {
      isLikeEnabled = true;
    });

    //print('likes = ${postMeta['likes']} and dislikes = ${postMeta['dislikes']}');
  }

  Future<void> dislikeBtnHandler(Post post) async {
    setState(() {
      isDislikedEnabled = false;
    });
    await BlocProvider.of<PostBloc>(context).dislike();

    setState(() {
      isDislikedEnabled = true;
    });
  }

  Widget dropDownBtn() {
    if (Constants.currentUserID == widget.post.authorId) {
      return specialBtns();
    }
    return Container();
  }

  Widget specialBtns() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 16.0),
      child: Row(
        children: <Widget>[
          InkWell(
              child: Icon(
                Icons.report_problem,
                size: 22.0,
                color: MyColors.darkAccent,
              ),
              onTap: () {}),
          InkWell(
              child: Icon(
                Icons.delete_forever,
                size: 22.0,
                color: MyColors.darkAccent,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: new AlertDialog(
                      title: new Text('Are you sure?'),
                      content:
                          new Text('Do you really want to delete this post?'),
                      actions: <Widget>[
                        new GestureDetector(
                          onTap: () => Navigator.of(context).pop(false),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text("NO"),
                          ),
                        ),
                        SizedBox(height: 16),
                        new GestureDetector(
                          onTap: () {
                            DatabaseService.deletePost(this.widget.post.id);
                            (context as Element).rebuild();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text("YES"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          InkWell(
              child: Icon(
                Icons.edit,
                size: 22.0,
                color: MyColors.darkAccent,
              ),
              onTap: () {}),
        ],
      ),
    );
  }

  Future mentionedUserProfile() async {
    ////print('mention: $_mentionText');
    User user =
        await DatabaseService.getUserWithUsername(_mentionText.substring(1));
    Navigator.of(context)
        .pushNamed(RouteList.profile, arguments: {'userId': user.id});
    ////print(user.id);
  }

  checkIfContainsHashtag() {
    var words = widget.post.text.split(' ');
    ////print(words.length);
    for (String word in words) {
      ////print('word: $word');
      _hashtagText = words.length > 0 && word.startsWith('#') ? word : '';
      break;
    }
  }

  checkIfContainsMention() {
    var words = widget.post.text.split(' ');

    for (String word in words) {
      ////print('word: $word');
      _mentionText = words.length > 0 && word.startsWith('@') ? word : '';
      //if (_mentionText.length > 1) _mentionText = _mentionText.substring(1);
      break;
    }
  }

  Future hashtagScreen() async {
    ////print('hashtagText: $_hashtagText');
    Hashtag hashtag = await DatabaseService.getHashtagWithText(_hashtagText);

    Navigator.of(context)
        .pushNamed(RouteList.hashtag, arguments: {'hashtag': hashtag});
    ////print(hashtag.id);
  }

  dropDownOptions() {
    if (HomeScreen.isBottomSheetVisible) {
      Navigator.pop(context);
    } else {
      HomeScreen.showMyBottomSheet(context);
    }

    setState(() {
      HomeScreen.isBottomSheetVisible = !HomeScreen.isBottomSheetVisible;
    });
  }

  void setCurrentGame() async {
    currentGame = await GamesRepo.getGameWithGameName(widget.post.game);
  }

  _onLongPressedPost(BuildContext context) async {
    var postLink = await DynamicLinks(
            Provider.of<AppModel>(context, listen: false)
                .packageInfo
                .packageName)
        .createPostDynamicLink({
      'postId': widget.post.id,
      'text': widget.post.text,
      'imageUrl': widget.post.imageUrl
    });
    var text = ClipboardData(text: '$postLink');
    Clipboard.setData(text);
    //AppUtil().showToast('Post copied to clipboard');
  }

  _goToPostPreview(Post post) {
    if (!widget.isClickable) return;
    Navigator.of(context).pushNamed(RouteList.post, arguments: {
      'postBloc': PostBloc(PostState(post)),
    });
  }

  Widget _youtubeBtn() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.black87),
      child: Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: 50,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

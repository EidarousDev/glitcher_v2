import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glitcher/logic/blocs/game_bloc.dart';
import 'package:glitcher/logic/blocs/posts_bloc.dart';
import 'package:glitcher/logic/states/posts_state.dart';
import 'package:glitcher/root_page.dart';
import 'package:glitcher/ui/screens/about/about_us.dart';
import 'package:glitcher/ui/screens/about/cookie_use.dart';
import 'package:glitcher/ui/screens/about/help_center.dart';
import 'package:glitcher/ui/screens/about/legal_notices.dart';
import 'package:glitcher/ui/screens/about/privacy_policy.dart';
import 'package:glitcher/ui/screens/about/terms_of_service.dart';
import 'package:glitcher/ui/screens/app_page.dart';
import 'package:glitcher/ui/screens/chats/add_members_to_group.dart';
import 'package:glitcher/ui/screens/chats/chats.dart';
import 'package:glitcher/ui/screens/chats/conversation.dart';
import 'package:glitcher/ui/screens/chats/group_conversation.dart';
import 'package:glitcher/ui/screens/chats/group_details.dart';
import 'package:glitcher/ui/screens/chats/group_members.dart';
import 'package:glitcher/ui/screens/chats/new_group.dart';
import 'package:glitcher/ui/screens/games/followed_games.dart';
import 'package:glitcher/ui/screens/games/game_screen.dart';
import 'package:glitcher/ui/screens/games/interests.dart';
import 'package:glitcher/ui/screens/posts/comments/add_comment.dart';
import 'package:glitcher/ui/screens/posts/comments/add_reply.dart';
import 'package:glitcher/ui/screens/posts/comments/edit_comment.dart';
import 'package:glitcher/ui/screens/posts/comments/edit_reply.dart';
import 'package:glitcher/ui/screens/posts/new_post/create_post.dart';
import 'package:glitcher/ui/screens/posts/new_post/edit_post.dart';
import 'package:glitcher/ui/screens/posts/post_preview.dart';
import 'package:glitcher/ui/screens/profile/profile_screen.dart';
import 'package:glitcher/ui/screens/report_post_screen.dart';
import 'package:glitcher/ui/screens/settings.dart';
import 'package:glitcher/ui/screens/suggestion_screen.dart';
import 'package:glitcher/ui/screens/users/users_screen.dart';
import 'package:glitcher/ui/screens/web_browser/in_app_browser.dart';
import 'package:glitcher/ui/screens/welcome/activate_page.dart';
import 'package:glitcher/ui/screens/welcome/login_page.dart';
import 'package:glitcher/ui/screens/welcome/password_change.dart';
import 'package:glitcher/ui/screens/welcome/password_reset.dart';
import 'package:glitcher/ui/screens/welcome/set_username.dart';
import 'package:glitcher/ui/screens/welcome/signup_page.dart';
import 'package:page_transition/page_transition.dart';

import '../ui/screens/posts/bookmarks.dart';
import '../ui/screens/posts/hashtag_posts_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final Map args = settings.arguments as Map;
    switch (settings.name) {
      case RouteList.initialRoute:
        return MaterialPageRoute(builder: (_) => RootPage());

      case RouteList.home:
        return PageTransition(
            child: AppPage(), type: PageTransitionType.leftToRightWithFade);

      case RouteList.newPost:
        return MaterialPageRoute(
            builder: (_) => CreatePost(
                  selectedGame: args['selectedGame'],
                ));

      case RouteList.editPost:
        return MaterialPageRoute(builder: (_) => EditPost(post: args['post']));

      case RouteList.profile:
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(
            args['userId'],
          ),
        );

      case RouteList.post:
        // Validation of correct data type
        return MaterialPageRoute(
          builder: (_) => PostPreview(
            post: args['post'],
          ),
        );
        return _errorRoute();

      case RouteList.addComment:
        // Validation of correct data type
        return MaterialPageRoute(
          builder: (_) => AddComment(
            post: args['post'],
            user: args['user'],
          ),
        );

      case RouteList.editComment:
        // Validation of correct data type
        return MaterialPageRoute(
          builder: (_) => EditComment(
            post: args['post'],
            user: args['user'],
            comment: args['comment'],
          ),
        );

      case RouteList.game:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<GameBloc>.value(
            value: args['gameBloc'],
            child: GameScreen(),
          ),
        );

      case RouteList.conversation:
        return MaterialPageRoute(
            builder: (_) => Conversation(
                  otherUid: args['otherUid'],
                ));

      case RouteList.groupConversation:
        return MaterialPageRoute(
            builder: (_) => GroupConversation(
                  groupId: args['groupId'],
                ));

      case RouteList.groupMembers:
        return MaterialPageRoute(
            builder: (_) => GroupMembers(
                  groupId: args['groupId'],
                ));

      case RouteList.addMembersToGroup:
        return MaterialPageRoute(
            builder: (_) => AddMembersToGroup(
                  args['groupId'],
                ));

      case RouteList.newGroup:
        return MaterialPageRoute(builder: (_) => NewGroup());

      case RouteList.groupDetails:
        return MaterialPageRoute(builder: (_) => GroupDetails(args['groupId']));

      case RouteList.chats:
        return MaterialPageRoute(builder: (_) => Chats());

      case RouteList.aboutUs:
        return MaterialPageRoute(builder: (_) => AboutUs());
      case RouteList.cookieUse:
        return MaterialPageRoute(builder: (_) => CookieUse());
      case RouteList.helpCenter:
        return MaterialPageRoute(builder: (_) => HelpCenter());
      case RouteList.legalNotices:
        return MaterialPageRoute(builder: (_) => LegalNotices());
      case RouteList.termsOfService:
        return MaterialPageRoute(builder: (_) => TermsOfService());
      case RouteList.privacyPolicy:
        return MaterialPageRoute(builder: (_) => PrivacyPolicy());
      case RouteList.browser:
        return MaterialPageRoute(
            builder: (_) => WebViewScreen(
                  url: args['url'],
                  title: args['title'],
                  headers: args['headers'],
                  javaScript: args['javaScript'],
                ));
      case RouteList.hashtag:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<PostsBloc>.value(
                value: PostsBloc(PostsState.initialState()),
                child: HashtagPostsScreen(args['hashtag'])));
      case RouteList.settings:
        return MaterialPageRoute(builder: (_) => SettingsScreen());

      case RouteList.addReply:
        // Validation of correct data type
        return MaterialPageRoute(
          builder: (_) => AddReply(
            post: args['post'],
            comment: args['comment'],
            user: args['user'],
            mention: args['mention'],
          ),
        );

      case RouteList.editReply:
        // Validation of correct data type
        return MaterialPageRoute(
          builder: (_) => EditReply(
            post: args['post'],
            comment: args['comment'],
            reply: args['reply'],
            user: args['user'],
          ),
        );

      case RouteList.bookmarks:
        return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
                value: PostsBloc(PostsState.initialState()),
                child: BookmarksScreen()));

      case RouteList.users:
        return MaterialPageRoute(
            builder: (_) => UsersScreen(
                  screenType: args['screen_type'],
                  userId: args['userId'],
                ));

      case RouteList.reportPost:
        return MaterialPageRoute(
            builder: (_) => ReportPostScreen(
                  postAuthor: args['post_author'],
                  postId: args['post_id'],
                ));

      case RouteList.suggestion:
        return MaterialPageRoute(
            builder: (_) => SuggestionScreen(
                  initialTitle: args['initial_title'],
                  initialDetails: args['initial_details'],
                  gameId: args['game_id'],
                ));

      case RouteList.signUp:
        return MaterialPageRoute(builder: (_) => SignUpPage());

      case RouteList.login:
        return MaterialPageRoute(
            builder: (_) => LoginPage(
                  onSignUpCallback: args['on_sign_up_callback'],
                ));

      case RouteList.passwordReset:
        return MaterialPageRoute(builder: (_) => PasswordResetScreen());

      case RouteList.activate:
        return MaterialPageRoute(
            builder: (_) => ActivatePage(
                  email: args['email'],
                  user: args['user'],
                ));
      case RouteList.setUsername:
        return MaterialPageRoute(
            builder: (_) => SetUsernameScreen(
                  user: args['user'],
                ));

      case RouteList.passwordChange:
        return MaterialPageRoute(builder: (_) => PasswordChangeScreen());

      case RouteList.followedGames:
        return MaterialPageRoute(
            builder: (_) => FollowedGames(
                  userId: args['userId'],
                ));

      case RouteList.interests:
        return MaterialPageRoute(builder: (_) => InterestsScreen());

      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}

class RouteList {
  static const String initialRoute = '/';
  static const String home = '/home';
  static const String newPost = '/new-post';
  static const String editPost = '/edit-post';
  static const String profile = '/user-profile';
  static const String post = '/post';
  static const String addComment = '/add-comment';
  static const String editComment = '/edit-comment';
  static const String game = '/game-screen';
  static const String conversation = '/conversation';
  static const String groupConversation = '/group-conversation';
  static const String groupMembers = '/group-members';
  static const String addMembersToGroup = '/add-members-to-group';
  static const String newGroup = '/new-group';
  static const String groupDetails = '/group-details';
  static const String chats = '/chats';
  static const String aboutUs = '/about-us';
  static const String cookieUse = '/cookie-use';
  static const String helpCenter = '/help-center';
  static const String legalNotices = '/legal-notices';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';
  static const String browser = '/browser';
  static const String hashtag = '/hashtag-posts';
  static const String settings = '/settings';
  static const String addReply = '/add-reply';
  static const String editReply = '/edit-reply';
  static const String bookmarks = '/bookmarks';
  static const String users = '/users';
  static const String reportPost = '/report-post';
  static const String suggestion = '/suggestion';
  static const String signUp = '/sign-up';
  static const String login = '/login';
  static const String activate = '/activate';
  static const String passwordReset = '/password-reset';
  static const String setUsername = '/set-username';
  static const String passwordChange = '/password-change';
  static const String followedGames = '/followed-games';
  static const String interests = '/interests';
}

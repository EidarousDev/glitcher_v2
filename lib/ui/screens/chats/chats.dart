import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/constants/strings.dart';
import 'package:glitcher/data/models/group_model.dart';
import 'package:glitcher/data/models/message_model.dart';
import 'package:glitcher/data/models/notification_model.dart' as noti;
import 'package:glitcher/data/models/user_model.dart';
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/services/notification_handler.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/ui/list_items/chat_item.dart';
import 'package:glitcher/ui/widgets/common/caching_image.dart';
import 'package:glitcher/ui/widgets/common/gradient_appbar.dart';
import 'package:glitcher/ui/widgets/drawer.dart';

class Chats extends StatefulWidget {
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver {
  PageController _pageController;
  TabController _tabController;
  List<ChatItem> chats = [];
  List<Group> groups = [];
  List<User> friends = [];

  bool _searching = false;

  List<ChatItem> filteredChats = [];
  List<Group> filteredGroups = [];

  TextEditingController _searchController = TextEditingController();

  void getCurrentUserFriends() async {
    List<User> friends = await DatabaseService.getAllMyFriends();

    friends.forEach((f) async {
      await loadUserData(f.id);
      await sortChatItems();
    });

    setState(() {
      this.friends = friends;
    });
  }

  Future<ChatItem> loadUserData(String uid) async {
    ChatItem chatItem;
    User user = await DatabaseService.getUserWithId(uid, checkLocal: true);
    Message message = await DatabaseService.getLastMessage(user.id);
    List<noti.Notification> newMessages =
        await DatabaseService.hasNewMessages(uid);
    setState(() {
      chatItem = ChatItem(
        key: ValueKey(uid),
        dp: user.profileImageUrl,
        name: user.username,
        isOnline: user.online == 'online',
        msg: message ?? 'No messages yet',
        counter: newMessages.length,
        onClearNotifications: () async {
          for (noti.Notification notification in newMessages) {
            await NotificationHandler.makeNotificationSeen(notification.id);
          }
        },
      );
      chats.add(chatItem);
    });

    return chatItem;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    getCurrentUserFriends();
    getChatGroups();
    super.initState();
    _pageController = PageController(initialPage: 0);
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  getChatGroups() async {
    List<String> groupsIds = await DatabaseService.getGroups();
    for (String groupId in groupsIds) {
      Group group = await DatabaseService.getGroupWithId(groupId);
      setState(() {
        this.groups.add(group);
      });
    }
  }

  sortChatItems() {
    int n = chats.length;
    for (int i = 0; i < n - 1; i++) {
      for (int j = 0; j < n - i - 1; j++) {
        var current = chats[j].msg.timestamp;
        if (current == null) {
          current = Timestamp.fromDate(DateTime.now());
        }
        var next = chats[j + 1].msg.timestamp;
        if (next == null) {
          next = Timestamp.fromDate(DateTime.now());
        }
        if (current.seconds <= next.seconds) {
          setState(() {
            ChatItem temp = chats[j];
            chats[j] = chats[j + 1];
            chats[j + 1] = temp;
          });
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    sortChatItems();
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    updateOnlineUserState(state);
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      getCurrentUserFriends();
      getChatGroups();
      //print('resumed');
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
      //_setupFeed();
      //print('inactive');
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
      //_setupFeed();
      //print('paused');
    } else if (state == AppLifecycleState.detached) {
      // app suspended (not used in iOS)
    }
  }

  void updateOnlineUserState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      await DatabaseService.makeUserOffline();
    } else if (state == AppLifecycleState.resumed) {
      await DatabaseService.makeUserOnline();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: gradientAppBar(context),
//        elevation: 4,
          title: TextField(
            cursorColor: MyColors.darkPrimary,
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                size: 28.0,
              ),
              suffixIcon: _searching
                  ? IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                      })
                  : null,
              hintText: 'Search',
            ),
            onChanged: (text) {
              filteredChats = [];
              filteredGroups = [];
              if (text.length != 0) {
                setState(() {
                  _searching = true;
                });
              } else {
                setState(() {
                  _searching = false;
                });
              }
              if (_pageController.page == 0) {
                chats.forEach((chatItem) {
                  if (chatItem.name
                      .toLowerCase()
                      .contains(text.toLowerCase())) {
                    setState(() {
                      filteredChats.add(chatItem);
                    });
                  }
                });
              } else {
                groups.forEach((groupItem) {
                  if (groupItem.name
                      .toLowerCase()
                      .contains(text.toLowerCase())) {
                    setState(() {
                      filteredGroups.add(groupItem);
                    });
                  }
                });
              }
            },
          ),
          leading: Builder(
              builder: (context) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Icon(Icons.menu),
                    ),
                  )),
          actions: <Widget>[],
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                filteredGroups = [];
                filteredChats = [];
                _searching = false;
              });
              _searchController.clear();
              _pageController.animateToPage(index,
                  duration: Duration(milliseconds: 400), curve: Curves.easeIn);
            },
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: MyColors.darkGrey,
            unselectedLabelColor: Theme.of(context).textTheme.caption.color,
            isScrollable: false,
            tabs: <Widget>[
              Tab(
                text: "Friends",
              ),
              Tab(
                text: "Groups",
              ),
            ],
          ),
        ),
        floatingActionButton: _tabController.index == 1
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteList.newGroup);
                },
                child: Icon(
                  Icons.add,
                ))
            : null,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _tabController.index = index;
            });
          },
          children: <Widget>[
            chats.length > 0
                ? ListView.separated(
                    padding: EdgeInsets.all(10),
                    separatorBuilder: (BuildContext context, int index) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 0.5,
                          width: MediaQuery.of(context).size.width / 1.3,
                          child: Divider(),
                        ),
                      );
                    },
                    itemCount:
                        !_searching ? chats.length : filteredChats.length,
                    itemBuilder: !_searching
                        ? (BuildContext context, int index) {
                            ChatItem chat = chats[index];
                            return chat;
                          }
                        : (BuildContext context, int index) {
                            ChatItem chat = filteredChats[index];
                            return chat;
                          },
                  )
                : Center(
                    child: Text(
                    'No chats yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  )),
            groups.length > 0
                ? ListView.separated(
                    padding: EdgeInsets.symmetric(
                      vertical: 7,
                    ),
                    separatorBuilder: (BuildContext context, int index) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 0.5,
                          width: MediaQuery.of(context).size.width / 1.3,
                          child: Divider(),
                        ),
                      );
                    },
                    itemCount: !_searching && _tabController.index == 1
                        ? this.groups.length
                        : this.filteredGroups.length,
                    itemBuilder: (BuildContext context, int index) {
                      Group group = !_searching && _tabController.index == 1
                          ? this.groups[index]
                          : this.filteredGroups[index];

                      return ListTile(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              RouteList.groupConversation,
                              arguments: {'groupId': group.id});
                        },
                        leading: CacheThisImage(
                          imageUrl: group.image,
                          imageShape: BoxShape.circle,
                          width: 50.0,
                          height: 50.0,
                          defaultAssetImage: Strings.default_group_image,
                        ),
                        title: Text(group.name ?? 'Unnamed group'),
                      );
                    },
                  )
                : Center(
                    child: Text(
                    'No groups yet',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )),
          ],
        ),
        drawer: BuildDrawer(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<bool> _onBackPressed() {
    /// Navigate back to home page
    Navigator.of(context).pushReplacementNamed(RouteList.initialRoute);
  }
}

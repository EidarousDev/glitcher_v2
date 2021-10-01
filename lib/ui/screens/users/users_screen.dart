import 'package:flutter/material.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/data/models/user_model.dart';
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/ui/list_items/user_item.dart';
import 'package:glitcher/ui/widgets/gradient_appbar.dart';
import 'package:glitcher/utils/functions.dart';

class UsersScreen extends StatefulWidget {
  final String screenType;
  final String userId;
  const UsersScreen({Key key, @required this.screenType, @required this.userId})
      : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users;
  TextEditingController _searchController = TextEditingController();
  bool _searching = false;
  List<User> filteredUsers = [];
  ScrollController _scrollController = ScrollController();

  bool _isPageReady = false;

  @override
  Widget build(BuildContext context) {
    return _isPageReady
        ? Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  fillColor:
                      switchColor(context, Colors.black54, Colors.black12),
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
                  filteredUsers = [];
                  if (text.length != 0) {
                    setState(() {
                      _searching = true;
                    });
                  } else {
                    setState(() {
                      _searching = false;
                    });
                  }
                  _users.forEach((user) {
                    if (user.username
                        .toLowerCase()
                        .contains(text.toLowerCase())) {
                      setState(() {
                        filteredUsers.add(user);
                      });
                    }
                  });
                },
              ),
              flexibleSpace: gradientAppBar(context),
              leading: Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: new IconButton(
                      icon: new Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ),
            body: _users.length > 0
                ? ListView.separated(
                    controller: _scrollController,
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
                        !_searching ? _users.length : filteredUsers.length,
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      return !_searching
                          ? UserItem(
                              key: Key(_users[index].id),
                              user: _users[index],
                            )
                          : UserItem(
                              key: Key(filteredUsers[index].id),
                              user: filteredUsers[index],
                            );
                    })
                : Center(
                    child: Text(
                    'No ${widget.screenType} yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  )),
          )
        : Scaffold(
            appBar: AppBar(
              flexibleSpace: gradientAppBar(context),
              leading: Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: new IconButton(
                      icon: new Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ),
            body: Center(
                child: Image.asset(
              'assets/images/glitcher_loader.gif',
              height: 150,
              width: 150,
            )),
          );
  }

  getUsers() async {
    List<User> users;
    switch (widget.screenType) {
      case 'Friends':
        if (widget.userId == Constants.currentUserID) {
          users = await DatabaseService.getAllMyFriends();
        } else {
          users = await DatabaseService.getAllFriends(widget.userId);
        }

        setState(() {
          _users = users;
        });
        break;
      case 'Following':
        if (widget.userId == Constants.currentUserID) {
          users = await DatabaseService.getAllMyFollowing();
        } else {
          users = await DatabaseService.getAllFollowing(widget.userId);
        }
        setState(() {
          _users = users;
        });
        break;
      case 'Followers':
        if (widget.userId == Constants.currentUserID) {
          users = await DatabaseService.getAllMyFollowers();
        } else {
          users = await DatabaseService.getAllFollowers(widget.userId);
        }
        setState(() {
          _users = users;
        });
        break;
    }

    setState(() {
      _isPageReady = true;
    });
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        //print('reached the bottom');
      } else if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
        //print("reached the top");
      } else {}
    });
    getUsers();
    super.initState();
  }
}

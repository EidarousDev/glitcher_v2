import 'package:flutter/material.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/constants/strings.dart';
import 'package:glitcher/data/models/group_model.dart';
import 'package:glitcher/data/models/user_model.dart';
import 'package:glitcher/services/database_service.dart';
import 'package:glitcher/services/notification_handler.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/ui/widgets/common/caching_image.dart';
import 'package:glitcher/ui/widgets/common/gradient_appbar.dart';
import 'package:glitcher/utils/app_util.dart';

class AddMembersToGroup extends StatefulWidget {
  final String groupId;
  AddMembersToGroup(this.groupId);
  @override
  _AddMembersToGroupState createState() => _AddMembersToGroupState();
}

class _AddMembersToGroupState extends State<AddMembersToGroup>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Group group;
  List<User> friendsData = [];
  List<bool> chosens = [];
  List<String> existingMembersIds = [];

  TextEditingController textEditingController = TextEditingController();

  ScrollController _scrollController;

  getNonMembersFriends() async {
    existingMembersIds =
        await DatabaseService.getGroupMembersIds(widget.groupId);

    List<User> friends = await DatabaseService.getAllMyFriends();

    for (int i = 0; i < friends.length; i++) {
      User user =
          await DatabaseService.getUserWithId(friends[i].id, checkLocal: true);

      setState(() {
        if (!existingMembersIds.contains(user.id)) {
          friendsData.add(user);
          chosens.add(false);
        }
      });
    }

    return friends;
  }

  @override
  void initState() {
    super.initState();
    getNonMembersFriends();
    getGroupData();
  }

  getGroupData() async {
    group = await DatabaseService.getGroupWithId(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.done,
          ),
          onPressed: () async {
            AppUtil.showGlitcherLoader(context);
            for (int i = 0; i < chosens.length; i++) {
              if (chosens[i]) {
                await DatabaseService.addMemberToGroup(
                    widget.groupId, friendsData[i].id);
              }

              await NotificationHandler.sendNotification(
                  friendsData[i].id,
                  'New chat group',
                  'You\'ve been added to a new chat group: ${group.name}',
                  widget.groupId,
                  'new_group');
            }

            Navigator.of(context).pushReplacementNamed(RouteList.groupMembers,
                arguments: {'groupId': widget.groupId});
          },
        ),
        appBar: AppBar(
          flexibleSpace: gradientAppBar(context),
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_backspace,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: TextField(
            decoration: InputDecoration.collapsed(
              hintText: 'Search',
            ),
          ),
        ),
        body: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
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
          itemCount: friendsData.length,
          itemBuilder: (BuildContext context, int index) {
            //User user = groups[index];
            return ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: Stack(
                children: <Widget>[
                  CacheThisImage(
                    imageUrl: friendsData.elementAt(index).profileImageUrl,
                    imageShape: BoxShape.circle,
                    width: 50.0,
                    height: 50.0,
                    defaultAssetImage: Strings.default_group_image,
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 6.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      height: 11,
                      width: 11,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                friendsData.elementAt(index).online == 'online'
                                    ? Colors.greenAccent
                                    : Colors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          height: 7,
                          width: 7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                friendsData.elementAt(index).username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                friendsData.elementAt(index).description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Checkbox(
                  value: chosens[index],
                  activeColor: MyColors.darkPrimary,
                  onChanged: (value) {
                    setState(() {
                      chosens[index] = value;
                    });
                    //print(value);
                  }),
            );
          },
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

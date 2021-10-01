import 'package:flutter/material.dart';
import 'package:glitcher/constants/my_colors.dart';
import 'package:glitcher/constants/strings.dart';
import 'package:glitcher/data/models/notification_model.dart'
    as notification_model;
import 'package:glitcher/services/notification_handler.dart';
import 'package:glitcher/ui/widgets/caching_image.dart';
import 'package:glitcher/utils/functions.dart';

class NotificationItem extends StatefulWidget {
  final notification_model.Notification notification;
  final String image;
  final String senderName;
  final int counter;

  NotificationItem(
      {Key key,
      @required this.notification,
      this.image,
      this.senderName,
      this.counter})
      : super(key: key);

  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  NotificationHandler notificationHandler = NotificationHandler();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: InkWell(
        child: _buildItem(widget.notification),
        onTap: () {},
      ),
    );
  }

  _buildItem(notification_model.Notification notification) {
    return Container(
      color: notification.seen
          ? switchColor(context, MyColors.lightBG, MyColors.darkBG)
          : switchColor(context, MyColors.lightCardBG, MyColors.darkCardBG),
      child: Container(
        padding: EdgeInsets.all(7),
        child: ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: CacheThisImage(
            imageUrl: widget.image,
            imageShape: BoxShape.circle,
            width: 50.0,
            height: 50.0,
            defaultAssetImage: Strings.default_profile_image,
          ),
          title: Text(
            "${widget.notification.title}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Container(
            child: Text(
              "${widget.notification.body}",
              overflow: TextOverflow.ellipsis,
            ),
            height: 15,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(height: 10),
              Text(
                "${Functions.formatTimestamp(widget.notification.timestamp)}",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 11,
                ),
              ),
              SizedBox(height: 5),
              widget.counter == 0
                  ? SizedBox()
                  : Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: switchColor(context, MyColors.lightPrimary,
                            MyColors.darkPrimary),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 11,
                        minHeight: 11,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: 1, left: 5, right: 5),
                        child: Text(
                          "${widget.counter}",
                          style: TextStyle(
                            color: switchColor(
                                context, Colors.black87, Colors.white),
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ],
          ),
          onTap: () {
            NotificationHandler.makeNotificationSeen(widget.notification.id);
            NotificationHandler.navigateToScreen(context,
                widget.notification.type, widget.notification.objectId);
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

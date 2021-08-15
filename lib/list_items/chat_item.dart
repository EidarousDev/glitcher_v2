import 'package:flutter/material.dart';
import 'package:glitcher/constants/strings.dart';
import 'package:glitcher/models/message_model.dart';
import 'package:glitcher/services/route_generator.dart';
import 'package:glitcher/utils/functions.dart';
import 'package:glitcher/widgets/caching_image.dart';

class ChatItem extends StatefulWidget {
  final String dp;
  final String name;
  //final String time;
  Message msg;
  final bool isOnline;
  final int counter;
  final Function onClearNotifications;

  ChatItem({
    Key key,
    @required this.dp,
    @required this.name,
    //this.time,
    @required this.msg,
    @required this.isOnline,
    this.onClearNotifications,
    @required this.counter,
  }) : super(key: key);

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  int _counter;
  @override
  void initState() {
    super.initState();
    _counter = widget.counter;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: Stack(
          children: <Widget>[
            CacheThisImage(
              imageUrl: widget.dp,
              imageShape: BoxShape.circle,
              width: 50.0,
              height: 50.0,
              defaultAssetImage: Strings.default_profile_image,
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
                      color: widget.isOnline ? Colors.greenAccent : Colors.grey,
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
          "${widget.name}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: widget.msg.type == 'text'
            ? Text(
                "${widget.msg.message}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : Row(
                children: [
                  widget.msg.type == 'audio'
                      ? Icon(Icons.audiotrack)
                      : Icon(Icons.image),
                  widget.msg.type == 'audio'
                      ? Text("Voice massage")
                      : Text("image")
                ],
              ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SizedBox(height: 10),
            Text(
              "${Functions.formatTimestamp(widget.msg.timestamp)}",
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 11,
              ),
            ),
            SizedBox(height: 5),
            _counter == 0
                ? SizedBox()
                : Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 11,
                      minHeight: 11,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 1, left: 5, right: 5),
                      child: Text(
                        "$_counter",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ],
        ),
        onTap: () async {
          if (widget.onClearNotifications != null) {
            widget.onClearNotifications();
            setState(() {
              _counter = 0;
            });
          }
          ValueKey key = this.widget.key;
          String uid = key.value;
          var message = await Navigator.of(context)
              .pushNamed(RouteList.conversation, arguments: {'otherUid': uid});
          setState(() {
            widget.msg = message;
          });
        },
      ),
    );
  }
}

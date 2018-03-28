import 'dart:core';
import 'package:Massajor/chat-item.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ChatListItem extends StatefulWidget {
  const ChatListItem({
    Key key,
    @required this.item,
    @required this.animationController
  }) : super(key: key);

  final ChatItem item;
  final AnimationController animationController;

  @override
  State<StatefulWidget> createState() => new _ChatItemState();
}

class _ChatItemState extends State<ChatListItem> {
  String status;
  DateFormat dateFmtr = new DateFormat('yyyy-MM-dd hh:mm:ss');

  Widget get avatar {
    return new CircleAvatar(
      backgroundImage: new NetworkImage('https://s.gravatar.com/avatar/91570d43ae82b83b5d68f9b452f931db?s=80')
    );
  }

  TextAlign get textAlign {
    return widget.item.isIncoming ? TextAlign.left : TextAlign.right;
  }

  Widget _buildTitle() {
    if (widget.item.isText) {
      return new Text(widget.item.body, textAlign: textAlign);
    } else {
      return new Image.network(widget.item.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeOut
      ),
      axisAlignment: 0.0,
      child: new ListTile(
        leading: widget.item.isIncoming ? avatar : null,
        title: _buildTitle(),
        subtitle: new Text(dateFmtr.format(widget.item.createdAt), textAlign: textAlign)
      )
    );
  }
}

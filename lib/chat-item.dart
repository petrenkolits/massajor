import 'dart:core';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ChatItem extends StatefulWidget {
  const ChatItem({
    Key key,
    this.body,
    this.sender,
    this.addressee,
    this.isIncoming,
    this.animationController,
    this.createdAt
  }) : super(key: key);

  final String body;
  final String sender;
  final String addressee;
  final bool isIncoming;
  final AnimationController animationController;
  final DateTime createdAt;

  @override
  State<StatefulWidget> createState() => new _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  String status;
  DateFormat dateFmtr = new DateFormat('yyyy-MM-dd hh:mm:ss');

  Widget get avatar {
    return new CircleAvatar(
      backgroundImage: new NetworkImage('https://s.gravatar.com/avatar/91570d43ae82b83b5d68f9b452f931db?s=80')
    );
  }

  TextAlign get textAlign {
    return widget.isIncoming ? TextAlign.left : TextAlign.right;
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
        leading: widget.isIncoming ? avatar : null,
        title: new Text(widget.body, textAlign: textAlign),
        subtitle: new Text(dateFmtr.format(widget.createdAt ?? new DateTime.now()), textAlign: textAlign)
      )
    );
  }
}

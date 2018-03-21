import 'dart:core';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ChatItem extends StatefulWidget {
  const ChatItem({
    Key key,
    this.body,
    this.sender,
    this.currentUser
  }) : super(key: key);

  final String body;
  final String sender;
  final String currentUser;

  @override
  State<StatefulWidget> createState() => new _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  String status;
  bool incoming = false;
  DateFormat dateFmtr = new DateFormat('yyyy-MM-dd hh:mm:ss');

  void initState() {
    incoming = widget.currentUser == widget.sender;
    super.initState();
  }

  Widget get avatar {
    return new CircleAvatar(
      backgroundImage: new NetworkImage('https://s.gravatar.com/avatar/91570d43ae82b83b5d68f9b452f931db?s=80')
    );
  }

  TextAlign get textAlign {
    return incoming ? TextAlign.left : TextAlign.right;
  }

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: incoming ? avatar : null,
      title: new Text(widget.body, textAlign: textAlign),
      subtitle: new Text(dateFmtr.format(new DateTime.now()), textAlign: textAlign)
    );
  }
}

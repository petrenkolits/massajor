import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Massajor/chat-title-bar-data.dart';

class ChatTitleBar extends StatelessWidget {
  const ChatTitleBar({
    Key key,
    @required this.data
  }) : super(key: key);

  final ChatTitleBarData data;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Expanded(
          child: new Text(data.title, textAlign: TextAlign.center)
        ),
        new Text(data.status),
        new IconButton(
          icon: new Icon(Icons.settings),
          onPressed: () => Navigator.of(context).pushNamed('/settings')
        )
      ],
    );
  }
}

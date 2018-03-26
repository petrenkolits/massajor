import 'package:flutter/material.dart';

typedef OnContactTap(String nickname);

class RosterItem extends StatelessWidget {
  RosterItem({
    Key key,
    this.nickname,
    this.lastMessage,
    this.onTap
  }) : super(key: key);

  String nickname;
  String lastMessage;
  OnContactTap onTap;
  String status;

  void _handleTap() {
    if (onTap != null) {
      onTap(nickname);
    }
  }

  Widget _buildTile(BuildContext context) {
    return new ListTile(
      leading: new CircleAvatar(
        backgroundImage: new NetworkImage('https://s.gravatar.com/avatar/91570d43ae82b83b5d68f9b452f931db?s=80')
      ),
      title: new Text(nickname),
      subtitle: new Row(
        children: <Widget>[
          new Expanded(
            child: new Text(lastMessage)
          )
        ],
      ),
      trailing: new Text(status ?? 'onine', textAlign: TextAlign.end),
      onTap: _handleTap
    );
  }

  @override
  Widget build(BuildContext context) {
    return new DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(color: Theme.of(context).dividerColor, width: 0.0),
        ),
      ),
      child: _buildTile(context)
    );
  }
}

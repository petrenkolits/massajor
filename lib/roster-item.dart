import 'package:flutter/material.dart';

typedef OnContactTap(String nickname);

class RosterItem extends StatefulWidget {
  const RosterItem({
    Key key,
    this.nickname,
    this.lastMessage,
    this.onTap
  }) : super(key: key);

  final String nickname;
  final String lastMessage;
  final OnContactTap onTap;

  @override
  State<StatefulWidget> createState() => new _RosterItemState();
}

class _RosterItemState extends State<RosterItem> {
  String status;

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap(widget.nickname);
    }
  }

  Widget _buildTile(BuildContext context) {
    return new ListTile(
      leading: new CircleAvatar(
        backgroundImage: new NetworkImage('https://s.gravatar.com/avatar/91570d43ae82b83b5d68f9b452f931db?s=80')
      ),
      title: new Text(widget.nickname),
      subtitle: new Row(
        children: <Widget>[
          new Expanded(
            child: new Text(widget.lastMessage)
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
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:Massajor/roster-item.dart';

typedef void OnContactTap(String nickname);
typedef void OnRosterItemAction(RosterListItem item, RosterItemActions actions);
enum RosterItemActions { remove, info }

class RosterListItem extends StatelessWidget {
  RosterListItem({
    Key key,
    @required this.item,
    @required this.onTap,
    @required this.onAction
  }) : super(key: key);

  final RosterItem item;
  final OnContactTap onTap;
  final OnRosterItemAction onAction;

  void _handleTap() {
    if (onTap != null) {
      onTap(item.nickname);
    }
  }

  void _handleAction(RosterItemActions action) {
    if (onAction != null) {
      onAction(this, action);
    }
  }

  Widget _buildTile(BuildContext context) {
    return new ListTile(
      leading: new CircleAvatar(
        backgroundImage: new NetworkImage('https://s.gravatar.com/avatar/91570d43ae82b83b5d68f9b452f931db?s=80')
      ),
      title: new Text(item.nickname),
      subtitle: new Row(
        children: <Widget>[
          new Expanded(
            child: new Text(item.lastMessage ?? '')
          )
        ],
      ),
      trailing: new PopupMenuButton<RosterItemActions>(
        onSelected: _handleAction,
        itemBuilder: (BuildContext context) => <PopupMenuEntry<RosterItemActions>>[
          const PopupMenuItem<RosterItemActions>(
            value: RosterItemActions.info,
            child: const Text('Info'),
            enabled: false
          ),
          const PopupMenuItem<RosterItemActions>(
            value: RosterItemActions.remove,
            child: const Text('Remove')
          ),
        ]
      ),
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

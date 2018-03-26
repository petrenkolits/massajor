import 'package:Massajor/chat.dart';
import 'package:Massajor/roster-item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Roster extends StatefulWidget {
  const Roster({
    Key key,
    this.user
  }) : super(key: key);

  final String title = 'Title';
  final FirebaseUser user;

  @override
  State<StatefulWidget> createState() => new _RosterState();
}

class _RosterState extends State<Roster> {
  final List<RosterItem> _contacts = <RosterItem>[];

  void _rosterItemTap(String nickname) {
    Navigator.of(context).push(
      new MaterialPageRoute<Null>(
        builder: (BuildContext ctx) {
          return new Chat(user: widget.user, addressee: 'rrrrr');
        }
      )
    );
  }

  void _addItem() {
    RosterItem item = new RosterItem(
      nickname: 'Some nick ${new Random().nextInt(2000)}',
      lastMessage: 'Last msg',
      onTap: _rosterItemTap
    );
    setState(() {
      _contacts.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Expanded(
              child: new Text('Massajor', textAlign: TextAlign.center)
            ),
            new IconButton(
              icon: new Icon(Icons.person_add),
              onPressed: _addItem
            ),
            new IconButton(
              icon: new Icon(Icons.settings),
              onPressed: () => Navigator.of(context).pushNamed('/settings')
            )
          ],
        ),
      ),
      body: new ListView.builder(
        padding: new EdgeInsets.all(8.0),
        reverse: false,
        itemBuilder: (_, int idx) => _contacts[idx],
        itemCount: _contacts.length,
      )
    );
  }
}

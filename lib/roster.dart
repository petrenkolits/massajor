import 'package:Massajor/add-contact.dart';
import 'package:Massajor/chat.dart';
import 'package:Massajor/db-service.dart';
import 'package:Massajor/roster-item.dart';
import 'package:Massajor/roster-list-item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Roster extends StatefulWidget {
  const Roster({
    Key key,
    this.user
  }) : super(key: key);

  final FirebaseUser user;

  @override
  State<StatefulWidget> createState() => new _RosterState();
}

class _RosterState extends State<Roster> {
  final List<RosterItem> _contacts = <RosterItem>[];
  final DbService dbService = new DbService();

  get storeKey {
    return 'contacts_${widget.user.uid}';
  }

  RosterItem _buildRosterItem(String uid) {
    return new RosterItem(uid);
  }

  RosterListItem _buildRosterListItemFromItem(RosterItem item) {
    return new RosterListItem(
      item: item,
      onTap: _rosterItemTap
    );
  }

  RosterListItem _buildRosterListItem(String uid) {
    return _buildRosterListItemFromItem(_buildRosterItem(uid));
  }

  void _storeItemToPrefs(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uids = prefs.getStringList(storeKey) ?? <String>[];
    uids.add(uid);
    prefs.setStringList(storeKey, uids);
  }

  void _loadRosterFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    (prefs.getStringList(storeKey) ?? <String>[]).forEach((String uid) {
      RosterListItem item = _buildRosterListItem(uid);
      setState(() {
        _contacts.add(item.item);
        item.item.lastMessage = '';
      });
    });
  }

  void _rosterItemTap(String nickname) {
    Navigator.of(context).push(
      new MaterialPageRoute<Null>(
        builder: (BuildContext ctx) {
          return new Chat(user: widget.user, addressee: nickname);
        }
      )
    );
  }

  void _addContact() {
    Navigator.of(context).push(
      new MaterialPageRoute<Null>(
        builder: (BuildContext ctx) {
          return new AddContact(onContactAdd: (String nickname) {
            RosterListItem item = _buildRosterListItem(nickname);
            _storeItemToPrefs(nickname);
            setState(() {
              _contacts.add(item.item);
            });
            Navigator.of(context).pop();
          });
        }
      )
    );
  }

  void _handleIncomingMessages(List<DocumentSnapshot> documents) {
    documents.forEach((DocumentSnapshot d) {
      RosterItem item = _contacts.firstWhere((RosterItem i) => i.nickname == d.data['sender']);
      if (item != null) {
        setState(() {
          item.lastMessage = d.data['body'];
        });
      }
    });
  }

  @override
  void initState() {
    _loadRosterFromPrefs();
    dbService.getRosterListener(widget.user.uid).listen((QuerySnapshot s) {
      _handleIncomingMessages(s.documents);
    });
    super.initState();
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
              icon: new Icon(Icons.settings),
              onPressed: () => Navigator.of(context).pushNamed('/settings')
            )
          ],
        ),
      ),
      body: new ListView.builder(
        padding: new EdgeInsets.all(8.0),
        reverse: false,
        itemBuilder: (_, int idx) => _buildRosterListItemFromItem(_contacts[idx]),
        itemCount: _contacts.length
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _addContact,
        child: new Icon(Icons.person_add)
      )
    );
  }
}

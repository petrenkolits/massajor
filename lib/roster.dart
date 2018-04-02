import 'dart:async';
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
  final List<RosterListItem> _contacts = <RosterListItem>[];
  final DbService dbService = new DbService();

  get storeKey => 'contacts_${widget.user.uid}';

  RosterItem _buildRosterItem(String uid) {
    return new RosterItem(uid);
  }

  RosterListItem _buildRosterListItemFromItem(RosterItem item) {
    return new RosterListItem(
      item: item,
      onTap: _rosterItemTap,
      onAction: _handleRosterItemAction
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

  void _removeItemFromPrefs(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uids = prefs.getStringList(storeKey);
    uids.remove(uid);
    prefs.setStringList(storeKey, uids);
  }

  Future _loadRosterFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    (prefs.getStringList(storeKey) ?? <String>[]).forEach((String uid) {
      RosterListItem item = _buildRosterListItem(uid);
      setState(() {
        _contacts.add(item);
        item.item.lastMessage = '';
      });
    });
    return;
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

  void _handleRosterItemAction(RosterListItem item, RosterItemActions action) {
    var actionsMap = <RosterItemActions, Function>{
      RosterItemActions.info: _rosterItemInfo,
      RosterItemActions.remove: _rosterItemRemove
    };
    actionsMap[action](item);
  }

  void _rosterItemInfo(RosterListItem item) {
    print("Info for $item");
  }

  void _rosterItemRemove(RosterListItem item) {
    showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text("Remove '${item.item.nickname}'?"),
        actions: <Widget>[
          new FlatButton(
            child: new Text('REMOVE'),
            onPressed: () {
              _handleRemoveAlert(item);
              Navigator.of(context).pop();
            },
          ),
          new FlatButton(
            child: new Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _handleRemoveAlert(RosterListItem item) {
    setState(() {
      _contacts.remove(item);
    });
    _removeItemFromPrefs(item.item.nickname);
  }

  void _handleAddContact() {
    Navigator.of(context).push(
      new MaterialPageRoute<Null>(
        builder: (BuildContext ctx) {
          return new AddContact(onContactAdd: (String nickname) {
            _addContact(nickname);
            Navigator.of(context).pop();
          });
        }
      )
    );
  }

  RosterListItem _addContact(String nickname) {
    RosterListItem item = _buildRosterListItem(nickname);
    _storeItemToPrefs(nickname);
    setState(() {
      _contacts.add(item);
    });
    return item;
  }

  void _handleIncomingMessages(List<DocumentSnapshot> documents) {
    documents.forEach((DocumentSnapshot d) {
      RosterListItem item = _contacts.firstWhere(
        (RosterListItem i) => i.item.nickname == d.data['sender'],
        orElse: () => _addContact(d.data['sender'])
      );
      setState(() {
        item.item.lastMessage = d.data['type'] == 'text' ? d.data['body'] : '<file>';
      });
    });
  }

  @override
  void initState() {
    _loadRosterFromPrefs().then((_) {
      dbService.getRosterListener(widget.user.uid).listen((QuerySnapshot s) {
        _handleIncomingMessages(s.documents);
      });
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
        itemBuilder: (_, int idx) => _contacts[idx],
        itemCount: _contacts.length
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _handleAddContact,
        child: new Icon(Icons.person_add)
      )
    );
  }
}

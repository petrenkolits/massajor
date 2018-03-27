import 'dart:async';

import 'package:Massajor/chat-item.dart';
import 'package:Massajor/chat-list-item.dart';
import 'package:Massajor/db-service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({
    Key key,
    this.user,
    this.addressee
  }) : super(key: key);

  final FirebaseUser user;
  final String addressee;

  @override
  State<StatefulWidget> createState() => new _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  final List<ChatItem> _messages = <ChatItem>[];
  final TextEditingController _textController = new TextEditingController();
  final DbService dbService = new DbService();
  final List<AnimationController> _animationControllers = <AnimationController>[];

  ChatItem _buildItem({
    @required String sender,
    @required String addressee,
    @required String body,
    @required DateTime createdAt
  }) {
    return new ChatItem(
      sender: sender,
      addressee: addressee,
      currentUserUID: widget.user.uid,
      body: body,
      createdAt: createdAt
    );
  }

  ChatItem _buildItemFromDocumentSnapshot(DocumentSnapshot d) {
    return _buildItem(
      sender: d.data['sender'],
      addressee: d.data['addressee'],
      body: d.data['body'],
      createdAt: d.data['createdAt']
    );
  }

  ChatListItem _buildChatListItemFromChatItem(ChatItem chatItem) {
    ChatListItem item = new ChatListItem(
      item: chatItem,
      animationController: _getAnimationController()
    );
    item.animationController.forward();
    return item;
  }

  ChatListItem _buildChatListItem({
    @required String sender,
    @required String addressee,
    @required String body,
    DateTime createdAt
  }) {
    return _buildChatListItemFromChatItem(
      _buildItem(sender: sender, addressee: addressee, body: body, createdAt: createdAt ?? new DateTime.now()));
  }

  AnimationController _getAnimationController() {
    AnimationController c = new AnimationController(
      duration: new Duration(milliseconds: 250),
      vsync: this
    );
    _animationControllers.add(c);
    return c;
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    dbService.sendMessage(widget.user.uid, widget.addressee, text);
    ChatListItem item = _buildChatListItem(sender: widget.user.uid, addressee: widget.addressee, body: text);
    setState(() {
      _messages.insert(0, item.item);
    });
  }

  void _handleIncomingMessages(List<DocumentSnapshot> documents) {
    documents.forEach((DocumentSnapshot d) {
      setState(() {
        _messages.insert(0, _buildItemFromDocumentSnapshot(d));
      });
    });
  }


  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: new InputDecoration.collapsed(
                  hintText: "Send a message"),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBody(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Flexible(
          child: new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => _buildChatListItemFromChatItem(_messages[index]),
            itemCount: _messages.length,
          ),
        ),
        new Divider(height: 1.0),
        new Container(
          decoration: new BoxDecoration(
            color: Theme.of(context).cardColor),
          child: _buildTextComposer(),
        ),
      ],
    );
  }

  Widget _buildChatHeader(BuildContext context) {
    return new AppBar(
      title: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Expanded(
            child: new Text("Chat with ${widget.addressee}", textAlign: TextAlign.center)
          ),
          new IconButton(
            icon: new Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings')
          )
        ],
      ),
    );
  }

  @override
  initState() {
    dbService.loadMessages(widget.user.uid, widget.addressee).then((QuerySnapshot s) {
      _handleIncomingMessages(s.documents);
    });
    dbService.loadMessages(widget.addressee, widget.user.uid).then((QuerySnapshot s) {
      _handleIncomingMessages(s.documents);
    });
    dbService.getChatListener(widget.addressee, widget.user.uid).listen((QuerySnapshot s) {
      _handleIncomingMessages(s.documents);
    });
    dbService.getChatListener(widget.user.uid, widget.addressee).listen((QuerySnapshot s) {
      _handleIncomingMessages(s.documents);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildChatHeader(context),
      body: _buildChatBody(context)
    );
  }

  @override
  void dispose() {
    _animationControllers.forEach((AnimationController c) => c.dispose());
    super.dispose();
  }
}

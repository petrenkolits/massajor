import 'package:Massajor/chat-item.dart';
import 'package:Massajor/db-service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  initState() {
    dbService.loadMessages(widget.user.uid, widget.addressee)
      .then((QuerySnapshot s) {
        s.documents.forEach((DocumentSnapshot d) {
          setState(() {
            _messages.insert(0, _buildItem(
              d.data['sender'],
              d.data['addressee'],
              d.data['body'],
              d.data['createdAt']
            ));
          });
        });
      });
    super.initState();
  }

  ChatItem _buildItem(String sender, String addressee, String body, DateTime createdAt) {
    ChatItem item = new ChatItem(
      sender: sender,
      addressee: addressee,
      body: body,
      createdAt: createdAt,
      isIncoming: widget.user.uid == addressee,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 250),
        vsync: this
      )
    );
    item.animationController.forward();
    return item;
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    dbService.sendMessage(widget.user.uid, widget.addressee, text);
    ChatItem item = _buildItem(widget.user.uid, widget.addressee, text, new DateTime.now());
    setState(() {
      _messages.insert(0, item);
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
            itemBuilder: (_, int index) => _messages[index],
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
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildChatHeader(context),
      body: _buildChatBody(context)
    );
  }

  @override
  void dispose() {
    for (ChatItem message in _messages)
      message.animationController.dispose();
    super.dispose();
  }
}

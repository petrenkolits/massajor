import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Massajor/chat-item.dart';
import 'package:Massajor/chat-list-item.dart';
import 'package:Massajor/db-service.dart';
import 'package:Massajor/cloud-storage.dart';

class Chat extends StatefulWidget {
  const Chat({
    Key key,
    @required this.user,
    @required this.addressee
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
  final CloudStorage cloudStorage = new CloudStorage();
  final List<AnimationController> _animationControllers = <AnimationController>[];
  final Comparator<ChatItem> comparator =
    (ChatItem a, ChatItem b) => b.createdAt.compareTo(a.createdAt);
  RestartableTimer _typingTimer;
  bool _isTyping = false;

  RestartableTimer get typingTimer {
    _typingTimer ??= new RestartableTimer(const Duration(seconds: 3), _disposeTypingEvent);
    return _typingTimer;
  }

  ChatItem _buildItem({
    String id,
    @required String sender,
    @required String addressee,
    @required String body,
    String type,
    DateTime createdAt
  }) {
    return new ChatItem(
      id: id,
      sender: sender,
      addressee: addressee,
      currentUserUID: widget.user.uid,
      body: body,
      type: type ?? 'text',
      createdAt: createdAt ?? new DateTime.now()
    );
  }

  ChatItem _buildItemFromDocumentSnapshot(DocumentSnapshot d) {
    return _buildItem(
      id: d.documentID,
      sender: d.data['sender'],
      addressee: d.data['addressee'],
      body: d.data['body'],
      type: d.data['type'],
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
    String type,
    DateTime createdAt
  }) {
    return _buildChatListItemFromChatItem(
      _buildItem(sender: sender, addressee: addressee, body: body, type: type,
        createdAt: createdAt));
  }

  AnimationController _getAnimationController() {
    AnimationController c = new AnimationController(
      duration: new Duration(milliseconds: 250),
      vsync: this
    );
    _animationControllers.add(c);
    return c;
  }

  void _sendMessage(text, [String type = 'text']) {
    dbService.sendMessage(widget.user.uid, widget.addressee, text, type);
    // ChatListItem item = _buildChatListItem(sender: widget.user.uid,
    //   addressee: widget.addressee, body: text, type: type);
    // setState(() {
    //   _messages.insert(0, item.item);
    // });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    _sendMessage(text);
  }

  void _handleTyping(String text) {
    text.length > 0 ? _sendTypingEvent() : _disposeTypingEvent();
  }

  void _sendTypingEvent() {
    print('typing...');
    typingTimer.reset();
    dbService.sendEvent(widget.user.uid, widget.addressee, 'typing');
  }

  void _disposeTypingEvent() {
    print('typing stopped;');
    typingTimer.cancel();
    dbService.deleteEvent(widget.user.uid, widget.addressee, 'typing');
  }

  void _handleAttachment() async {
    File _fileName = await ImagePicker.pickImage();
    if (_fileName != null) {
      Uri uri = await cloudStorage.uploadFile(widget.user.uid, _fileName);
      _sendMessage(uri.toString(), 'photo');
    }
  }

  void _handleIncomingMessages(List<DocumentChange> dcl) {
    dcl.forEach((DocumentChange dc) {
      if (dc.type == DocumentChangeType.added) {
        if (_messages.indexWhere((ChatItem i) => i.id == dc.document.documentID) == -1) {
          setState(() {
            _isTyping = false;
            _messages.insert(0, _buildItemFromDocumentSnapshot(dc.document));
            _messages.sort(comparator);
          });
        }
      }
    });
  }

  void _handleIncomingEvents(List<DocumentChange> dcl) {
    print('handle incoming events...');
    dcl.forEach((DocumentChange dc) {
      if (dc.document.data['type'] == 'typing') {
        if (dc.type == DocumentChangeType.added) {
          setState(() {
            _isTyping = true;
          });
        } else if (dc.type == DocumentChangeType.removed) {
          setState(() {
            _isTyping = false;
          });
        }
      }
    });
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(Icons.attach_file),
                onPressed: _handleAttachment
              ),
            ),
            // new Container(
            //   margin: new EdgeInsets.symmetric(horizontal: 4.0),
            //   child: new IconButton(
            //     icon: new Icon(Icons.location_on),
            //     onPressed: _handleAttachment
            //   ),
            // ),
            new Flexible(
              child: new TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                onChanged: _handleTyping,
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
          new Text(_isTyping ? 'typing...' : 'idle'),
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
      _handleIncomingMessages(s.documentChanges);
    });
    dbService.loadMessages(widget.addressee, widget.user.uid).then((QuerySnapshot s) {
      _handleIncomingMessages(s.documentChanges);
    });
    dbService.getChatListener(widget.addressee, widget.user.uid).listen((QuerySnapshot s) {
      _handleIncomingMessages(s.documentChanges);
    });
    dbService.getChatListener(widget.user.uid, widget.addressee).listen((QuerySnapshot s) {
      _handleIncomingMessages(s.documentChanges);
    });
    dbService.getChatEventsListener(widget.addressee, widget.user.uid).listen((QuerySnapshot s) {
      _handleIncomingEvents(s.documentChanges);
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

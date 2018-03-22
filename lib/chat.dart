import 'package:Massajor/chat-item.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({
    Key key,
    this.currentUser,
    this.addressee
  }) : super(key: key);

  final String currentUser;
  final String addressee;

  @override
  State<StatefulWidget> createState() => new _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  final List<ChatItem> _messages = <ChatItem>[];
  final TextEditingController _textController = new TextEditingController();

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatItem item = new ChatItem(
      body: text,
      sender: 'xxxx',
      currentUser: widget.currentUser,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 250),
        vsync: this
      )
    );
    setState(() {
      _messages.insert(0, item);
    });
    item.animationController.forward();
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
                onPressed: () => _handleSubmitted(_textController.text)),
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
            child: new Text(widget.addressee, textAlign: TextAlign.center)
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

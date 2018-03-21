import 'package:Massajor/chat-item.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({
    Key key,
    this.title
  }) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => new _ChatState();
}

class _ChatState extends State<Chat> {
  final List<ChatItem> _messages = <ChatItem>[];
  final TextEditingController _textController = new TextEditingController();

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatItem item = new ChatItem(body: text);
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
            child: new Text(widget.title, textAlign: TextAlign.center)
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
}

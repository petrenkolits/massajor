import 'package:flutter/material.dart';

typedef void OnConcactAdd(String uid);

class AddContact extends StatelessWidget {
  AddContact({
    Key key,
    this.onContactAdd
  }) : super(key: key);

  final OnConcactAdd onContactAdd;
  final TextEditingController _usernameController = new TextEditingController();

  void _handleAdd() {
    if (onContactAdd != null) {
      onContactAdd(_usernameController.text);
    }
    _usernameController.clear();
  }

  Widget _buildForm() {
    return new Form(
      child: new Column(
        children: <Widget>[
          new TextFormField(
            decoration: const InputDecoration(
              border: const UnderlineInputBorder(),
              filled: true,
              labelText: 'Username'
            ),
            controller: _usernameController,
          ),
          const SizedBox(height: 24.0),
          new RaisedButton(
            onPressed: _handleAdd,
            child: new Text('Add contact'),
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Row(
          children: <Widget>[
            new Expanded(
              child: new Text('Add new contact'),
            ),
            new IconButton(icon: new Icon(Icons.check), onPressed: _handleAdd)
          ]
        )
      ),
      body: new Container(
        padding: const EdgeInsets.all(32.0),
        child: _buildForm()
      )
    );
  }
}

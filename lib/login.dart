import 'package:flutter/material.dart';

typedef void OnLoginCallback(String username, String pwd);

class Login extends StatelessWidget {
  Login({
    Key key,
    this.onLogin
  }) : super(key: key);

  final OnLoginCallback onLogin;
  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _pwdController = new TextEditingController();

  void _handleSignIn() {
    if (onLogin != null) {
      onLogin(_usernameController.text, _pwdController.text);
    }
    _usernameController.clear();
    _pwdController.clear();
  }

  Widget _buildForm() {
    return new Form(
      child: new Column(
        children: <Widget>[
          new Text(
            'Massajor',
            style: new TextStyle(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 24.0),
          new TextFormField(
            decoration: const InputDecoration(
              border: const UnderlineInputBorder(),
              filled: true,
              labelText: 'Username'
            ),
            controller: _usernameController,
          ),
          const SizedBox(height: 24.0),
          new TextFormField(
            decoration: const InputDecoration(
              border: const UnderlineInputBorder(),
              filled: true,
              labelText: 'Password'
            ),
            obscureText: true,
            controller: _pwdController,
          ),
          const SizedBox(height: 24.0),
          new RaisedButton(
            onPressed: _handleSignIn,
            child: new Text('SIGN IN'),
          ),
          const SizedBox(height: 12.0),
          new FlatButton(
            onPressed: null,
            child: new Text('SIGN UP'),
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        body: new Container(
          decoration: new BoxDecoration(
            color: Colors.white
          ),
          padding: const EdgeInsets.all(32.0),
          child: new Row(
            children: <Widget>[
              new Expanded(
                child: new Column(
                  children: <Widget>[
                    _buildForm()
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max
                )
              )
            ]
          )
        )
      )
    );
  }
}

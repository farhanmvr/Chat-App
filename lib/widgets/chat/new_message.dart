import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  NewMessage({Key key}) : super(key: key);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessege = '';
  final _controller = TextEditingController();

  void _sendMessage() async {
    FocusScope.of(context).unfocus(); //Unfocus keyboard
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final userData = await Firestore.instance.collection('users').document(user.uid).get();

    // Create a new message
    Firestore.instance.collection('chat').add({
      'text': _enteredMessege,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData['username'],
      'userImage':userData['imageUrl'],
    });

    setState(() {
      _controller.clear();
      _enteredMessege = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 5),
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                autocorrect: false,
                enableSuggestions: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _enteredMessege = value;
                  });
                },
              ),
            ),
          ),
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(Icons.send),
            onPressed: _enteredMessege.trim().isEmpty ? null : _sendMessage,
          )
        ],
      ),
    );
  }
}

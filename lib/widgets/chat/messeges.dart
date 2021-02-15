import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './message_bubble.dart';

class Messeges extends StatelessWidget {
  const Messeges({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder(
            stream: Firestore.instance.collection('chat').orderBy('createdAt', descending: true).snapshots(),
            builder: (ctx, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final chatDocs = chatSnapshot.data.documents;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                reverse: true,
                itemCount: chatSnapshot.data.documents.length,
                itemBuilder: (ctx, index) => MessageBubble(
                  key: ValueKey(chatDocs[index].documentID),
                  username: chatDocs[index]['username'],
                  message: chatDocs[index]['text'],
                  userImage: chatDocs[index]['userImage'],
                  isMe: chatDocs[index]['userId'] == futureSnapshot.data.uid,
                ),
              );
            });
      },
    );
  }
}

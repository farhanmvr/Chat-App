import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({Key key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  Future<void> _submitAuthForm({
    String email,
    String password,
    String username,
    bool isLogin,
    BuildContext ctx,
    File image,
  }) async {
    AuthResult authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        // Login user with email and password
        authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        // Create account with email and password
        authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);

        // Image upload
        final ref = FirebaseStorage.instance.ref().child('user_images').child(authResult.user.uid + '.jpg');
        await ref.putFile(image).onComplete;
        // Get image url
        final imageUrl = await ref.getDownloadURL();

        // Storing extra user information
        await Firestore.instance.collection('users').document(authResult.user.uid).setData({
          'username': username,
          'email': email,
          'imageUrl': imageUrl,
        });
      }
    } on PlatformException catch (error) {
      var message = 'An unknown error occured, please try again';
      if (error.message != null) {
        message = error.message;
      }
      // Show error snackbar
      Scaffold.of(ctx).showSnackBar(SnackBar(content: Text(message), backgroundColor: Theme.of(ctx).errorColor));
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}

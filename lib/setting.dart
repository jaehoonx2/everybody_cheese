import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'main.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  var _finish;
  FirebaseUser user;

  @override
  void initState() {
    super.initState();

    _getUserInfo().then((finish) {
      setState(() {
        _finish = finish;
      });
    });
  }

  Future _getUserInfo() async => user = await _auth.currentUser();

  void _signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (_finish == null)
      return Text(
        'LOADING...',
        style: theme.textTheme.title,
      );
    else
      return Scaffold(
        appBar: AppBar(
          title: const Text('설정', style: TextStyle(fontFamily: 'HangeulNuri', color: Colors.black),),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                children: <Widget>[
                  Align(
                    child: Text(
                      '<Your Profile>',
                      style: TextStyle(
                        fontSize: 20,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: user.photoUrl != null
                  ? Image.network(user.photoUrl, fit: BoxFit.fitWidth)
                  : SizedBox(
                      height: (MediaQuery.of(context).size.width / 3),
                      child: Image.asset('assets/logo.png')),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                children: <Widget>[
                  Align(
                    child: Text(
                      '<Your UID>',
                      style: TextStyle(
                        fontSize: 20,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user.uid,
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              indent: 20,
              endIndent: 20,
              color: theme.primaryColor,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                children: <Widget>[
                  Align(
                    child: Text(
                      '<Your email>',
                      style: TextStyle(
                        fontSize: 20,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user.email != null ? user.email : 'anonymous',
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80.0),
            SignInButtonBuilder(
              icon: Icons.exit_to_app,
              text: 'Sign Out',
              width: 120.0,
              onPressed: () async {
                if (user == null) {
                  print('No one has signed in.');
                  return;
                }

                _signOut();
                print(user.uid + ' has successfully signed out.');

                // go to first
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EverybodyCheeseApp(),
                    ));
              },
              backgroundColor: Colors.blueGrey[700],
            ),
          ],
        ),
      );
  }
}
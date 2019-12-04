import 'dart:async';
import 'package:everybody_cheese/mail.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final myController = TextEditingController();

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
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  withdrawalAccount() async {
    var tempUser = await _auth.currentUser();

    if (user == tempUser) {
      await user.delete();
      user = null;
    }
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
          title: const Text('설정',
            style: TextStyle(fontFamily: 'HangeulNuri', color: Colors.black),),
          backgroundColor: Colors.white,
        ),
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Card(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Column(
                        children: <Widget>[
                          Align(
                            child: Text(
                              '프로필',
                              style: TextStyle(
                                fontFamily: 'HangeulNuri',
                                fontSize: 20,
                                color: Colors.black,
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
                          height: (MediaQuery
                              .of(context)
                              .size
                              .width / 3),
                          child: Image.asset('assets/logo.png')),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Column(
                        children: <Widget>[
                          Align(
                            child: Text(
                              '이메일 주소',
                              style: TextStyle(
                                fontFamily: 'HangeulNuri',
                                fontSize: 20,
                                color: Colors.black,
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
                              user.email,
                              style: TextStyle(
                                fontFamily: 'HangeulNuri',
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            '로그아웃',
                            style: TextStyle(
                              fontFamily: 'HangeulNuri',
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: theme.primaryColor,
                            ),
                          ),
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
//              GestureDetector(
//                child: Card(
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      FlatButton(
//                        child: Text(
//                          '프로필 사진 등록 / 변경',
//                          style: TextStyle(
//                            fontFamily: 'HangeulNuri',
//                            fontSize: 15.0,
//                            fontWeight: FontWeight.w400,
//                            color: theme.primaryColor,
//                          ),
//                        ),
//                        onPressed: null,
//                      ),
//                    ],
//                  ),
//                ),
//                onTap: null,
//              ),
              GestureDetector(
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          '비밀번호 변경',
                          style: TextStyle(
                            fontFamily: 'HangeulNuri',
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: theme.primaryColor,
                          ),
                        ),
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          "가입하신 메일을 입력하세요.",
                          style: TextStyle(
                            fontFamily: 'HangeulNuri',
                            color: Colors.black,
                          ),
                        ),
                        content: TextField(controller: myController),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              '인증',
                              style: TextStyle(
                                fontFamily: 'HangeulNuri',
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () async {
                              if (myController.text == user.email) {
                                await resetPassword(myController.text);
                                myController.clear();
                                Navigator.of(context).pop();
                              } else {
                                print('failed');
                              }
                            },
                          ),
                          FlatButton(
                            child: Text(
                              '취소',
                              style: TextStyle(
                                fontFamily: 'HangeulNuri',
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () {
                              myController.clear();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              GestureDetector(
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          '문의하기',
                          style: TextStyle(
                            fontFamily: 'HangeulNuri',
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: theme.primaryColor,
                          ),
                        ),
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MailPage(),
                      ));
                },
              ),
              GestureDetector(
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          '회원 탈퇴',
                          style: TextStyle(
                            fontFamily: 'HangeulNuri',
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: theme.primaryColor,
                          ),
                        ),
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          "정말로 탈퇴하시겠습니까?",
                          style: TextStyle(
                            fontFamily: 'HangeulNuri',
                            color: Colors.black,
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              '탈퇴',
                              style: TextStyle(
                                fontFamily: 'HangeulNuri',
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () async {
                              if (user == null) {
                                print('No one has signed in.');
                                return;
                              }

                              withdrawalAccount();
                              print('Withdrawal is done.');

                              // go to first
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EverybodyCheeseApp(),
                                  ));
                            },
                          ),
                          FlatButton(
                            child: Text(
                              '취소',
                              style: TextStyle(
                                fontFamily: 'HangeulNuri',
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
  }
}

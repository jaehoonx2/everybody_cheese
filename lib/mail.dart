import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:image_picker/image_picker.dart';

class MailPage extends StatefulWidget {
  @override
  _MailPageState createState() => new _MailPageState();
}

class _MailPageState extends State<MailPage> {
  List<String> attachment = <String>[];
  final TextEditingController _subjectController =
  TextEditingController(text: "제목을 적어주세요.",);
  final TextEditingController _bodyController = TextEditingController(
      text: "불편 사항, 에러 발견, 건의사항 등을 적어주세요.");
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> send() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    final MailOptions mailOptions = MailOptions(
      subject: _subjectController.text,
      body: _bodyController.text,
      recipients: <String>['21300698@handong.edu'],
      isHTML: true,
      // bccRecipients: ['other@example.com'],
      // ccRecipients: <String>['third@example.com'],
      attachments: attachment,
    );

    String platformResponse;

    try {
      await FlutterMailer.send(mailOptions);
      platformResponse = '메일 앱을 실행합니다.';
    } on PlatformException catch (error) {
      platformResponse = error.toString();
      print(error);
      if (!mounted){
        return;
      }
      await showDialog<void>(
          context: _scafoldKey.currentContext,
          builder: (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Message',
                  style: Theme.of(context).textTheme.subhead,
                ),
                Text(error.message),
              ],
            ),
            contentPadding: const EdgeInsets.all(26),
            title: Text(error.code),
          ));
    } catch (error) {
      platformResponse = error.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted){
      return;
    }
    _scafoldKey.currentState.showSnackBar(SnackBar(
      content: Text(platformResponse),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final Widget imagePath = Column(
        children: attachment.map((String file) => Text('$file')).toList());

    return Scaffold(
      key: _scafoldKey,
      appBar: new AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          '문의하기',
          style: TextStyle(fontFamily: 'HangeulNuri', color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actionsIconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            onPressed: send,
            icon: const Icon(Icons.send),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: new Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '제목',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _bodyController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                        labelText: '내용', border: OutlineInputBorder()),
                  ),
                ),
                imagePath,
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.photo),
        label: const Text('스크린샷', style: TextStyle(fontFamily: 'HangeulNuri'),),
        onPressed: _picker,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 4.0,
        // shape: CircularNotchedRectangle(),
        // color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Builder(
              builder: (BuildContext context) => FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: const Text(
                  '소중한 의견 감사드립니다.',
                  style: TextStyle(
                    fontFamily: 'HangeulNuri',
                    color: Colors.black,
                  ),
                ),
                onPressed: null,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _picker() async {
    final File pick = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      attachment.add(pick.path);
    });
  }
}

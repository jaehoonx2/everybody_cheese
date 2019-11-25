import 'dart:io';
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:device_info/device_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:path/path.dart' as Path;

final FirebaseAuth _auth = FirebaseAuth.instance;

DateTime _takenDate = DateTime.now();
final formatter = new DateFormat('yyyy.MM.dd (E)');

class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '사진 업로드',
          style: TextStyle(fontFamily: 'HangeulNuri', color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: <Widget>[
          Image.asset(
            'assets/paris.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SignInButtonBuilder(
                  text: '촬영하기',
                  icon: Icons.photo_camera,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UploadPage(mode: 0)),
                    );
                  },
                  backgroundColor: Colors.blue,
                  width: 110.0,
                ),
                SizedBox(height: 20.0),
                SignInButtonBuilder(
                  text: '불러오기',
                  icon: Icons.photo,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UploadPage(mode: 1)),
                    );
                  },
                  backgroundColor: Colors.blue,
                  width: 110.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UploadPage extends StatefulWidget {
  final int mode; // 0: camera, 1: gallery

  const UploadPage({Key key, this.mode}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  int _mode;
  var _finish;
  FirebaseUser user;

  final locationController = TextEditingController();
  final descController = TextEditingController();
  final camController = TextEditingController();

  File _image;
  String _imageURL;

  String _device = "";
  static final DeviceInfoPlugin plugin = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();

    _mode = this.widget.mode;

    if (_mode == 0) {
      initPlatform();

      _getGalleryImage().then((mode) {
        setState(() {});
      });
    }

    _getUserInfo().then((finish) {
      setState(() {
        _finish = finish;
      });
    });
  }

  Future<void> initPlatform() async {
    if (Platform.isAndroid) {
      setState(() async {
        _device = getAndroidDevice(await plugin.androidInfo);
      });
    }

    if (Platform.isIOS) {
      setState(() async {
        _device = getIOSDevice(await plugin.iosInfo);
      });
    }
  }

  getAndroidDevice(AndroidDeviceInfo device) => '${device.model}';

  getIOSDevice(IosDeviceInfo device) => '${device.utsname.machine}';

  Future _getGalleryImage() async {
    var image = await ImagePicker.pickImage(
        source: _mode == 0 ? ImageSource.camera : ImageSource.gallery);

    setState(() {
      _image = image;
      camController.text = _device;
      print('Image Path $_image');
    });
  }

  Future _getUserInfo() async => user = await _auth.currentUser();

  Future _getImageURL() async {
    if (_image != null) {
      StorageReference ref = FirebaseStorage.instance
          .ref()
          .child('posts/${Path.basename(_image.path)}');
      StorageUploadTask uploadTask = ref.putFile(_image);
      await uploadTask.onComplete;
      print('File Uploaded');
      await ref.getDownloadURL().then((fileURL) {
        setState(() {
          _imageURL = fileURL;
        });
      });
    } else {
      setState(() {
        _imageURL = null;
      });
    }
  }

  Future<Null> _setTakenDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _takenDate,
        firstDate: DateTime(2014, 1),
        lastDate: DateTime(2100));
    if (picked != null && picked != _takenDate)
      setState(() {
        _takenDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          _mode == 0 ? '촬영하기' : '불러오기',
          style: TextStyle(fontFamily: 'HangeulNuri', color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Upload',
              style: TextStyle(fontSize: 15.0, fontFamily: 'RoundedElegance'),
            ),
            onPressed: () async {
              if (locationController.text.isNotEmpty &&
                  descController.text.isNotEmpty &&
                  camController.text.isNotEmpty) {
                await _getImageURL();

                if (_imageURL != null) {
                  final collRef = Firestore.instance.collection('posts');
                  DocumentReference docReferance = collRef.document();
                  docReferance.setData({
                    'location': locationController.text,
                    'description': descController.text,
                    'camera': camController.text,
                    'imgURL': _imageURL,
                    'docID': docReferance.documentID,
                    'authorID': user.uid,
                    'taken': Timestamp.fromDate(_takenDate),
                    'votes': 0,
                    'clickedID': [
                      null,
                    ],
                  });

                  print('success');

                  _image = null;
                  await _getImageURL();
                  locationController.clear();
                  camController.clear();
                  descController.clear();
                } else {
                  print('failed');
                }
              } else {
                print('failed');
              }
            },
          ),
        ],
      ),
      resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 3,
              child: _image != null
                  ? Image.file(_image)
                  : Image.asset('assets/logo.png'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  icon: Icon(Icons.camera_alt), onPressed: _getGalleryImage),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        '어디서 찍으셨나요?',
                        style: TextStyle(
                          fontFamily: 'RoundedElegance',
                          fontSize: 10.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          SignInButtonBuilder(
                              mini: true,
                              icon: Icons.location_on,
                              text: 'Location',
                              backgroundColor: Colors.blue,
                              onPressed: () {},
                          ),
                          Text(
                            'under the development',
                            style: TextStyle(
                              fontFamily: 'RoundedElegance',
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(width: 10.0,),
                  Column(
                    children: <Widget>[
                      Text(
                        '언제 찍으셨나요?',
                        style: TextStyle(
                          fontFamily: 'RoundedElegance',
                          fontSize: 10.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          SignInButtonBuilder(
                              mini: true,
                              icon: Icons.calendar_today,
                              text: 'Calendar',
                              backgroundColor: Colors.blue,
                              onPressed: () => _setTakenDate(context)),
                          Text(
                            formatter.format(_takenDate),
                            style: TextStyle(
                              fontFamily: 'RoundedElegance',
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: false,
                  labelText: '어디서 찍은 사진인가요?',
                ),
                controller: locationController,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: false,
                  labelText: '촬영에 사용된 기종은 무엇인가요?',
                ),
                controller: camController,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: false,
                  labelText: '특별한 촬영방법이나 팁이 있으신가요?',
                ),
                controller: descController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

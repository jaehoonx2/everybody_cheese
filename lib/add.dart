import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart' as prefix0;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:device_info/device_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:path/path.dart' as Path;
import 'package:geolocator/geolocator.dart';

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

  // Start of the geolocator
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  Position _currentPosition;
  String _currentAddress;

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
  // End of the geolocator

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

      _getCurrentLocation();
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
              if (_currentAddress.isNotEmpty &&
                  descController.text.isNotEmpty &&
                  camController.text.isNotEmpty) {
                await _getImageURL();

                if (_imageURL != null) {
                  final collRef = Firestore.instance.collection('posts');
                  DocumentReference docReferance = collRef.document();
                  docReferance.setData({
                    'location': _currentAddress,
                    'longitude': _currentPosition.longitude,
                    'latitude': _currentPosition.latitude,
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
              child: Column(
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
                      Padding(
                        padding: prefix0.EdgeInsets.only(left: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SignInButtonBuilder(
                              mini: true,
                              icon: _mode == 0 ? Icons.my_location : Icons.location_on,
                              text: 'Location',
                              backgroundColor: Colors.blue,
                              onPressed: () async {
//                                if(_mode == 0)
                                  await _getCurrentLocation();
//                                else {
//
//                                }
                              }
                            ),
                            Text(
                              _currentPosition != null ? _currentAddress : (_mode == 0 ? 'Current Location' : 'Select Location'),
                              style: TextStyle(
                                fontFamily: 'RoundedElegance',
                                fontSize: 10.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 20.0,),
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
                      Padding(
                        padding: prefix0.EdgeInsets.only(left: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 20.0,),
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
            SizedBox(width: 20.0,),
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

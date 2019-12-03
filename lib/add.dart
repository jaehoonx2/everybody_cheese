import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;
import 'package:everybody_cheese/key.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

DateTime _takenDate = DateTime.now();
final formatter = new DateFormat('yyyy.MM.dd (E)');

// const kGoogleApiKey is in key.dart
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

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
            'assets/bg_upload.png',
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
  FirebaseUser user;

  Position _currentPosition;
  String _currentAddress;

  // Start of the geolocator
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

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

  // Start of the flutter_google_places
  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      var address = await Geocoder.local.findAddressesFromQuery(p.description);

      if(lat != null && lng != null) {
        setState(() {
          _currentAddress = p.description;
          _currentPosition = Position(latitude: lat, longitude: lng);
        });
      }
    }
  }
  // End of the flutter_google_places

  final titleController = TextEditingController();
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
    } else {
      _currentPosition = null;
      _currentAddress = null;
    }

    _getUserInfo().then((finish) {
      setState(() {});
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
      if(_mode == 0)
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
                  titleController.text.isNotEmpty &&
                  descController.text.isNotEmpty &&
                  camController.text.isNotEmpty) {
                await _getImageURL();

                if (_imageURL != null) {
                  final collRef = Firestore.instance.collection('posts');
                  DocumentReference docReferance = collRef.document();
                  docReferance.setData({
                    'title': titleController.text,
                    'location': _currentAddress,
                    'longitude': _currentPosition.longitude,
                    'latitude': _currentPosition.latitude,
                    'description': descController.text,
                    'camera': camController.text,
                    'imgURL': _imageURL,
                    'docID': docReferance.documentID,
                    'userEmail': user.email,
                    'authorID': user.uid,
                    'taken': Timestamp.fromDate(_takenDate),
                    'votes': 0,
                    'clickedID': [null,],
                  });

                  print('success');

                  _image = null;
                  await _getImageURL();
                  titleController.clear();
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
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: SingleChildScrollView(
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
                    Text(
                      '어디서 찍으셨나요?',
                      style: TextStyle(
                        fontFamily: 'HangeulNuri',
                        fontSize: 15.0,
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
                            onPressed: () async {
                              if(_mode == 0)
                                await _getCurrentLocation();
                              else {
                                Prediction p = await PlacesAutocomplete.show(
                                    context: context, apiKey: kGoogleApiKey);
                                displayPrediction(p);
                              }
                            }
                        ),
                        Flexible(
                          child: Text(
                            _currentPosition != null ? _currentAddress : 'Select Location',
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                              fontFamily: 'RoundedElegance',
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '언제 찍으셨나요?',
                      style: TextStyle(
                        fontFamily: 'HangeulNuri',
                        fontSize: 15.0,
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
              ),
              SizedBox(width: 20.0,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  decoration: InputDecoration(
                    filled: false,
                    labelText: '사진 제목은 무엇인가요?',
                  ),
                  controller: titleController,
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
      ),
    );
  }
}

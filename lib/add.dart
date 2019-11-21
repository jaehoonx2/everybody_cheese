import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as Path;

final FirebaseAuth _auth = FirebaseAuth.instance;

class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 업로드', style: TextStyle(fontFamily: 'HangeulNuri', color: Colors.black),),
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
                      MaterialPageRoute(builder: (context) => UploadPage(mode: 0)),
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
                      MaterialPageRoute(builder: (context) => UploadPage(mode: 1)),
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
  final int mode;   // 0: camera, 1: gallery

  const UploadPage({Key key, this.mode}): super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  int _mode;
  var _finish;
  FirebaseUser user;

  final locationController = TextEditingController();
  final descController = TextEditingController();

  File _image;
  String _imageURL;

  @override
  void initState() {
    super.initState();

    _mode = this.widget.mode;

    if(_mode == 0) {
      getGalleryImage().then((mode){
        setState(() {});
      });
    }

    _getUserInfo().then((finish) {
      setState(() {
        _finish = finish;
      });
    });
  }

  Future _getUserInfo() async => user = await _auth.currentUser();

  Future getGalleryImage() async {
    var image = await ImagePicker.pickImage(
        source: _mode == 0
        ? ImageSource.camera
        : ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  Future getImageURL() async {
    if(_image != null) {
      StorageReference ref = FirebaseStorage.instance.ref().child(
          'posts/${Path.basename(_image.path)}');
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
        _imageURL = 'http://handong.edu/site/handong/res/img/logo.png';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          _mode == 0 ? '촬영하기' : '불러오기',
          style: TextStyle(
              fontFamily: 'HangeulNuri',
              color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Upload',
              style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'RoundedElegance'
              ),
            ),
            onPressed: () async {
              if (locationController.text.isNotEmpty
                  && descController.text.isNotEmpty) {

                await getImageURL();

                final collRef = Firestore.instance.collection('posts');
                DocumentReference docReferance = collRef.document();
                docReferance.setData({
                  'location': locationController.text,
                  'description': descController.text,
                  'imgURL' : _imageURL,
                  'docID' : docReferance.documentID,
                  'authorID' : user.uid,
                  'created' : FieldValue.serverTimestamp(),
                  'votes' : 0,
                  'clickedID' : [null,],
                });

//                Fluttertoast.showToast(
//                    msg: "Product uploaded successfully!",
//                    toastLength: Toast.LENGTH_SHORT,
//                    gravity: ToastGravity.CENTER,
//                    timeInSecForIos: 1,
//                    backgroundColor: Colors.blue,
//                    textColor: Colors.white,
//                    fontSize: 16.0
//                );

                _image = null;
                await getImageURL();
                locationController.clear();
                descController.clear();
              } else {
//                Fluttertoast.showToast(
//                    msg: "PLEASE ENTER THE PRODUCT INFO!",
//                    toastLength: Toast.LENGTH_SHORT,
//                    gravity: ToastGravity.CENTER,
//                    timeInSecForIos: 1,
//                    backgroundColor: Colors.red,
//                    textColor: Colors.white,
//                    fontSize: 16.0
//                );
              }
            },
          ),
        ],
      ),
      body: Column(
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
            child: IconButton(icon: Icon(Icons.camera_alt), onPressed: getGalleryImage),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: InputDecoration(
                filled: false,
                labelText: 'Location',
              ),
              controller: locationController,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: InputDecoration(
                filled: false,
                labelText: 'Description',
              ),
              controller: descController,
            ),
          ),
        ],
      ),
    );
  }
}
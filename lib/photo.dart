import 'package:everybody_cheese/detail.dart';
import 'package:flutter/material.dart';
import 'package:everybody_cheese/model/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PhotoPage extends StatefulWidget {
  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  var _finish;
  var stream;
  FirebaseUser user;

  @override
  void initState() {
    super.initState();

    _getUserInfo().then((finish) {
      setState(() {
        stream = Firestore.instance.collection('posts').where('authorID', isEqualTo: user.uid).snapshots();
        _finish = finish;
      });
    });
  }

  Future _getUserInfo() async => user = await _auth.currentUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 사진', style: TextStyle(fontFamily: 'HangeulNuri', color: Colors.black),),
        backgroundColor: Colors.white,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return GridView.count(
      crossAxisCount: 1,
      padding: EdgeInsets.all(16.0),
      children: snapshot.map((data) => _buildGridCards(context, data)).toList(),
    );
  }

  Widget _buildGridCards(BuildContext context, DocumentSnapshot data) {
    final post = Post.fromSnapshot(data);
    final ThemeData theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 18 / 11,
            child: Image.network(
              post.imgURL,
              fit: BoxFit.fitWidth,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 10.0),
                        Row(
                          children: <Widget>[
                            Icon(Icons.location_on, color: theme.primaryColor,),
                            Text(
                              post.location,
                              style: TextStyle(
                                fontFamily: 'HangeulNuri',
                                fontSize: 20.0,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: <Widget>[
                            Icon(Icons.camera_alt, color: theme.primaryColor,),
                            Text(
                              post.camera,
                              style: TextStyle(
                                fontFamily: 'HanguelNuri',
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0,),
                        Row(
                          children: <Widget>[
                            Icon(Icons.favorite, color: Colors.red,),
                            Text(
                              post.votes.toString(),
                              style: TextStyle(
                                fontFamily: 'HanguelNuri',
                                fontSize: 15.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(post: post,),
                              ));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => Firestore.instance.collection('posts').document(data.documentID).delete(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
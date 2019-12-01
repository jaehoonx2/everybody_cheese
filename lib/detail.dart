import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everybody_cheese/model/post.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final formatter = new DateFormat('yyyy.MM.dd (E)');

class DetailPage extends StatelessWidget {
  final Post post;

  DetailPage({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          '상세 정보',
          style: TextStyle(fontFamily: 'HangeulNuri', color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('posts').where('docID', isEqualTo: post.docID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
//      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final ThemeData theme = Theme.of(context);
    final post = Post.fromSnapshot(data);

    return SingleChildScrollView(
      key: ValueKey(post.docID),
      child: Column(
        children: <Widget>[
          Card(
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 3,
              child: Image.network(post.imgURL),
            ),
          ),
          SizedBox(height: 3.0),
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Align(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          size: 25.0,
                        ),
                        Text(
                          post.location,
                          maxLines: 2,
                          style: TextStyle(
                            fontFamily: 'HanguelNuri',
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                ),
                Align(
                  child: _buildVotes(context, data),
                  alignment: Alignment.centerRight,
                ),
              ],
            ),
          ),
          SizedBox(height: 3.0),
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            alignment: Alignment.topLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.calendar_today,
                  size: 20.0,
                ),
                Text(
                  ' ' + formatter.format(post.taken.toDate()),
                  style: TextStyle(
                    fontFamily: 'HanguelNuri',
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  Text(
                    'Creator: ',
                    style: TextStyle(
                      fontFamily: 'HanguelNuri',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    post.authorID,
                    style: theme.textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            indent: 30,
            endIndent: 30,
            color: Colors.black,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            alignment: Alignment.topLeft,
            child: Row(
              children: <Widget>[
                Icon(Icons.camera_alt),
                Text(
                  post.camera,
                  style: TextStyle(
                    fontFamily: 'RoundedElegance',
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
            alignment: Alignment.topLeft,
            child: Text(
              'How to take?',
              style: TextStyle(
                fontFamily: 'RoundedElegance',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            alignment: Alignment.topLeft,
            child: Text(
              post.description,
              style: TextStyle(
                fontFamily: 'HanguelNuri',
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotes(BuildContext context, DocumentSnapshot data) {
    final post = Post.fromSnapshot(data);

    return FittedBox(
      child: Row(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.favorite),
                  color: Colors.red,
                  onPressed: () async {
                    bool alreadySaved = false;

                    final FirebaseUser currentUser = await _auth.currentUser();
                    String uuid = currentUser.uid;

                    for(int idx = 0; idx < post.clickedID.length; idx++) {
                      if(uuid == post.clickedID[idx]){
                        alreadySaved = true;
                        break;
                      }
                    }

                    if(alreadySaved == false) {   // 처음 누르는 거면
                      var list = List<dynamic>();
                      list.add(uuid);

                      post.reference.updateData({
                        'votes': FieldValue.increment(1),
                        'clickedID' : FieldValue.arrayUnion(list),
                      });

                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('I LIKE IT!!!')));
                    } else {                      // 아니면
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('You can only do it once!!!')));
                    }
                  }),
              Text(post.votes.toString()),
            ],
          ),
        ],
      ),
    );
  }
}
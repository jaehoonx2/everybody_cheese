import 'package:flutter/cupertino.dart';
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
      stream: Firestore.instance
          .collection('posts')
          .where('docID', isEqualTo: post.docID)
          .snapshots(),
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
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.title, size: 25.0,),
                      SizedBox(width: 10.0,),
                      Flexible(
                        child: Text(
                          post.title,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(
                            fontFamily: 'HangeulNuri',
                            fontSize: 25.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
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
            child: Row(
              children: <Widget>[
                Icon(Icons.location_on, size: 25.0,),
                SizedBox(width: 10.0,),
                Flexible(
                  child: Text(
                    post.location,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: 'HangeulNuri',
                      fontSize: 15.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.0),
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  Text(
                    'Taken by',
                    style: TextStyle(
                      fontFamily: 'RoundedElegance',
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  Text(
                    post.userEmail,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: 'HangeulNuri',
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.0),
          Divider(
            indent: 30,
            endIndent: 30,
            color: Colors.black,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            alignment: Alignment.topLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon( Icons.calendar_today),
                SizedBox(width: 10.0,),
                Text(
                  formatter.format(post.taken.toDate()),
                  style: TextStyle(
                    fontFamily: 'HangeulNuri',
                    fontSize: 13.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.0),
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            alignment: Alignment.topLeft,
            child: Row(
              children: <Widget>[
                Icon(Icons.camera_alt),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  post.camera,
                  style: TextStyle(
                    fontFamily: 'HangeulNuri',
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.0),
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            alignment: Alignment.topLeft,
            child: Row(
              children: <Widget>[
                Icon(Icons.note),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  '촬영 기법 및 팁',
                  style: TextStyle(
                    fontFamily: 'HangeulNuri',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.0),
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            alignment: Alignment.topLeft,
            child: Text(
              post.description,
              style: TextStyle(
                fontFamily: 'HangeulNuri',
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

                    for (int idx = 0; idx < post.clickedID.length; idx++) {
                      if (uuid == post.clickedID[idx]) {
                        alreadySaved = true;
                        break;
                      }
                    }

                    if (alreadySaved == false) {
                      // 처음 누르는 거면
                      var list = List<dynamic>();
                      list.add(uuid);

                      post.reference.updateData({
                        'votes': FieldValue.increment(1),
                        'clickedID': FieldValue.arrayUnion(list),
                      });

                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text('좋아요를 눌렀습니다.')));
                    } else {
                      // 아니면
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('한번만 클릭할 수 있습니다.')));
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

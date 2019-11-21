import 'package:flutter/material.dart';
import 'package:everybody_cheese/model/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoPage extends StatefulWidget {
  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  var stream = Firestore.instance.collection('posts').snapshots();

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
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: snapshot.map((data) => _buildGridCards(context, data)).toList(),
    );
  }

  Widget _buildGridCards(BuildContext context, DocumentSnapshot data) {
    final post = Post.fromSnapshot(data);
    final ThemeData theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 3/4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 1/3,
            child: Image.network(
              post.imgURL,
              fit: BoxFit.fitWidth,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    post.location,
                    style: theme.textTheme.title,
                    maxLines: 1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    post.description,
                    style: theme.textTheme.title,
                  ),
                  SizedBox(height: 8.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      child: Text('more', style: TextStyle(color: theme.primaryColor, fontSize: 10.0),),
                      onTap: () {
//                        Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                              builder: (context) => DetailPage(product: product,),
//                            )
//                        );
                      },
                    ),
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
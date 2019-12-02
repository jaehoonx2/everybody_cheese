import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:everybody_cheese/detail.dart';
import 'package:everybody_cheese/model/post.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var stream;
  StreamBuilder streamBuilder;

  @override
  void initState() {
    super.initState();
    setState(() {
      stream = Firestore.instance.collection('posts').where('votes', isGreaterThanOrEqualTo: 0).snapshots();
    });
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator();

        return _buildSlider(context, snapshot.data.documents);
      },
    );
  }

  Route _createRoute(Post post) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => DetailPage(post: post,),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Widget _buildSlider(BuildContext context, List<DocumentSnapshot> snapshot) {
    List<Post> imgList = snapshot.map((data)=>_buildPosts(context, data)).toList();

    if(imgList.length == 0)
      return Image.asset(
        'assets/404.jpeg',
        fit: BoxFit.fitWidth,
      );
    else
      return CarouselSlider(
        viewportFraction: 0.9,
        aspectRatio: 2.0,
        autoPlay: true,
        enlargeCenterPage: true,
        items: imgList.map((post) {
          return Builder(
            builder: (BuildContext context) {
              return ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    Container(
                      child: GestureDetector(
                        child: Image.network(post.imgURL, fit: BoxFit.cover, width: 1000.0,),
                        onTap: () => Navigator.of(context).push(_createRoute(post)),
                      ),
                    ),
                    FittedBox(
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
                                          SnackBar(content: Text('좋아요를 눌렀습니다.')));
                                    } else {                      // 아니면
                                      Scaffold.of(context).showSnackBar(
                                          SnackBar(content: Text('한번만 클릭할 수 있습니다.')));
                                    }
                                  }),
                              Text(
                                  post.votes.toString(),
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color.fromARGB(200, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        child: Text(
                            post.location,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'HangeulNuri',
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                            )
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      );
  }

  Post _buildPosts(BuildContext context, DocumentSnapshot data) {
    final post = Post.fromSnapshot(data);
    return post;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            children: <Widget>[
              SizedBox(height: 20.0),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: (MediaQuery.of(context).size.height / 4),
                    child: Image.asset('assets/logo.png'),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'EVERYBODY CHEESE! ',
                    style: TextStyle(
                      fontFamily: 'RoundedElegance',
                      fontSize: 25.0,
                    ),
                  ),
                  Text(
                    '명예의 전당',
                    style: TextStyle(
                      fontFamily: 'HangeulNuri',
                      fontSize: 25.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              _buildBody(context),
              SizedBox(height: 20.0),
              Text(
                '베스트 사진작가는 누구?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'HangeulNuri',
                  fontSize: 25.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '좋아요를 일정수 이상 획득한 사진들에 대해 진행합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'HangeulNuri',
                  fontSize: 10.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          )
      ),
    );
  }
}
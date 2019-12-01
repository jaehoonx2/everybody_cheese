import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'model/post.dart';

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
                      child: Image.network(post.imgURL, fit: BoxFit.cover, width: 1000.0,),
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
                      fontSize: 20.0,
                    ),
                  ),
                  Text(
                    '명예의 전당',
                    style: TextStyle(
                      fontFamily: 'HangeulNuri',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50.0),
              _buildBody(context),
            ],
          )
      ),
    );
  }
}
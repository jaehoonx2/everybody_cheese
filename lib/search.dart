import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 검색', style: TextStyle(fontFamily: 'HangeulNuri', color: Colors.black),),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: <Widget>[
          ConstrainedBox(
            child: Image.asset(
              'assets/bg_search.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fitHeight,
            ),
            constraints: BoxConstraints.expand(),
          ),
          Container(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100.withOpacity(0.2),
                  )
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SignInButtonBuilder(
                  text: '지역명으로 찾기',
                  icon: Icons.search,
                  onPressed: () {

                  },
                  backgroundColor: Colors.blue,
                  width: 160.0,
                ),
                SizedBox(height: 20.0),
                SignInButtonBuilder(
                  text: '내 주변 명소 찾기',
                  icon: Icons.my_location,
                  onPressed: () {

                  },
                  backgroundColor: Colors.blue,
                  width: 160.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

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
    );
  }
}
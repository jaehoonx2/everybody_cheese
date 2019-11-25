import 'package:flutter/material.dart';

List<Widget> showList;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            children: <Widget>[
              SizedBox(height: 10.0),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: (MediaQuery.of(context).size.height / 4),
                    child: Image.asset('assets/logo.png'),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'EVERYBODY CHEESE! ',
                    style: TextStyle(
                      fontFamily: 'RoundedElegance',
                      fontSize: 20.0,
                    ),
                  ),
                  Text(
                    '베스트 사진전',
                    style: TextStyle(
                      fontFamily: 'HangeulNuri',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
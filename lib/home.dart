import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '홈',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              SizedBox(height: 80.0),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: (MediaQuery.of(context).size.width / 3),
                    child: Image.asset('assets/logo.png'),
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'EVERYBODY CHEESE! ',
                        style: TextStyle(
                          fontFamily: 'RoundedElegance',
                          fontSize: 20.0,
                        ),
                      ),
                      Text(
                        '공지사항',
                        style: TextStyle(
                          fontFamily: 'HangeulNuri',
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
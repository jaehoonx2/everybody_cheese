import 'package:flutter/material.dart';

import 'package:everybody_cheese/home.dart';
import 'package:everybody_cheese/photo.dart';
import 'package:everybody_cheese/upload.dart';
import 'package:everybody_cheese/search.dart';
import 'package:everybody_cheese/setting.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  int _selectedIndex = 0;

  PageController pageController = PageController(initialPage: 0, keepPage: true);

  @override
  void initState() => super.initState();

  void pageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      onPageChanged: (index) => pageChanged(index),
      children: <Widget>[
        HomePage(),
        PhotoPage(),
        UploadPage(),
        SearchPage(),
        SettingPage(),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: buildPageView(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: theme.primaryColor,
        onTap: (index) => _onItemTapped(index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('홈'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            title: Text('내 사진'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera),
            title: Text('업로드'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            title: Text('주변위치'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('설정'),
          ),
        ],
      ),
    );
  }
}
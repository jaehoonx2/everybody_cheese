import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:everybody_cheese/key.dart';

// const kGoogleApiKey is in key.dart
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Position _targetPosition;
  String _targetAddress;

  // Start of the geolocator
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _targetPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _targetPosition.latitude, _targetPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _targetAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
  // End of the geolocator

  // Start of the flutter_google_places
  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      var address = await Geocoder.local.findAddressesFromQuery(p.description);

      setState(() {
        _targetAddress = p.description;
        _targetPosition = Position(latitude: lat, longitude: lng);
      });
    }
  }
  // End of the flutter_google_places

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
                  onPressed: () async {
                    Prediction p = await PlacesAutocomplete.show(
                        context: context, apiKey: kGoogleApiKey);
                    displayPrediction(p);
                  },
                  backgroundColor: Colors.blue,
                  width: 160.0,
                ),
                SizedBox(height: 20.0),
                SignInButtonBuilder(
                  text: '내 주변 명소 찾기',
                  icon: Icons.my_location,
                  onPressed: () async {
                    await _getCurrentLocation();
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
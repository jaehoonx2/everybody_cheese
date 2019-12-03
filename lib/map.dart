import 'dart:async';
import 'package:everybody_cheese/detail.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everybody_cheese/model/post.dart';

class MapPage extends StatefulWidget {
  final Position position;

  const MapPage({Key key, this.position}): super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Firestore database = Firestore.instance;
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition _myLocation;
  Position _position;

  @override
  void initState() {
    _position = this.widget.position;
    _myLocation = CameraPosition(
      target: LatLng(_position.latitude, _position.longitude),
      zoom: 15.0,
    );
    callMarkers();
    super.initState();
  }

  callMarkers(){
    database.collection('posts')
//    .where('latitude', isGreaterThan: _position.latitude - 0.01)
//    .where('latitude', isLessThan: _position.latitude + 0.01)
//    .where('longitude', isGreaterThan: _position.longitude - 0.01)
//    .where('longitude', isLessThan: _position.longitude + 0.01)
        .getDocuments().then((docs) {
      if(docs.documents.isNotEmpty){
        for(int i = 0; i < docs.documents.length; i++) {
          initMarker(docs.documents[i].data, docs.documents[i].documentID);
        }
      }
    });
  }

  void initMarker(data, docID) {
    var markerIdVal = docID;
    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(data['latitude'], data['longitude']),
      infoWindow: InfoWindow(
          title: data['title'],
          snippet: data['userEmail'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailPage(post: Post.fromMap(data))),
            );
          }
      ),
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          '지도',
          style: TextStyle(fontFamily: 'HangeulNuri', color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actionsIconTheme: IconThemeData(color: Colors.black),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _myLocation,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
        markers: Set<Marker>.of(markers.values),
      ),
    );
  }
}
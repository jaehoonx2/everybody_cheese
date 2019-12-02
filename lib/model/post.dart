import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String title;
  final String docID;
  final String authorID;
  final String userEmail;
  final String imgURL;
  final String location;
  final double latitude;
  final double longitude;
  final String description;
  final String camera;
  final Timestamp taken;
  final int votes;
  final List<dynamic> clickedID;

  final DocumentReference reference;

  Post.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['title'] != null),
        assert(map['docID'] != null),
        assert(map['authorID'] != null),
        assert(map['userEmail'] != null),
        assert(map['imgURL'] != null),
        assert(map['location'] != null),
        assert(map['longitude'] != null),
        assert(map['latitude'] != null),
        assert(map['description'] != null),
        assert(map['votes'] != null),
        title = map['title'],
        docID = map['docID'],
        authorID = map['authorID'],
        userEmail = map['userEmail'],
        imgURL = map['imgURL'],
        location = map['location'],
        latitude = map['latitude'],
        longitude = map['longitude'],
        description = map['description'],
        camera = map['camera'],
        taken = map['taken'],
        votes = map['votes'],
        clickedID = map['clickedID'];

  Post.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}
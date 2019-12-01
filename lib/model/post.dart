import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String docID;
  final String authorID;
  final String imgURL;
  final String location;
  final double longitude;
  final double latitude;
  final String description;
  final String camera;
  final Timestamp taken;
  final int votes;
  final List<dynamic> clickedID;

  final DocumentReference reference;

  Post.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['docID'] != null),
        assert(map['authorID'] != null),
        assert(map['imgURL'] != null),
        assert(map['location'] != null),
        assert(map['longitude'] != null),
        assert(map['latitude'] != null),
        assert(map['description'] != null),
        assert(map['votes'] != null),
        docID = map['docID'],
        authorID = map['authorID'],
        imgURL = map['imgURL'],
        location = map['location'],
        longitude = map['longitude'],
        latitude = map['latitude'],
        description = map['description'],
        camera = map['camera'],
        taken = map['taken'],
        votes = map['votes'],
        clickedID = map['clickedID'];

  Post.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}
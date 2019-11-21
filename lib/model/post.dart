import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String docID;
  final String authorID;
  final String imgURL;
  final String location;
  final String description;
  final Timestamp created;
  final int votes;
  final List<dynamic> clickedID;

  final DocumentReference reference;

  Post.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['docID'] != null),
        assert(map['authorID'] != null),
        assert(map['imgURL'] != null),
        assert(map['location'] != null),
        assert(map['description'] != null),
        assert(map['votes'] != null),
        docID = map['docID'],
        authorID = map['authorID'],
        imgURL = map['imgURL'],
        location = map['location'],
        description = map['description'],
        created = map['created'],
        votes = map['votes'],
        clickedID = map['clickedID'];

  Post.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}
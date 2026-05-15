import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/models/user.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  // collection reference
  final CollectionReference babyCollection = FirebaseFirestore.instance
      .collection('babies');

  Future updateUserData(
    String name,
    String gender,
    int age,
    double weight,
    double height,
  ) async {
    return await babyCollection.doc(uid).set({
      'name': name,
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
    });
  }

  // baby list from snapshot
  List<Baby> _babyListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Baby(
        name: data['name'] ?? '',
        gender: data['gender'] ?? '',
        age: data['age'] ?? 0,
        weight: data['weight'] ?? 0,
        height: data['height'] ?? 0,
      );
    }).toList();
  }

  // userData from snapshot
UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  return UserData(
    uid: uid,
    name: data['name'],
    gender: data['gender'],
    age: data['age'],
    weight: (data['weight'] as num).toDouble(),
    height: (data['height'] as num).toDouble(),
  );
}

  // get baby stream
  Stream<List<Baby>> get babies {
    return babyCollection.snapshots().map(_babyListFromSnapshot);
  }

  // get user doc stream
  Stream<UserData> get userData {
    return babyCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
}

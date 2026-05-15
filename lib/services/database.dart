import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumi/models/baby.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  // reference to user's baby subcollection
  CollectionReference get babyCollection => FirebaseFirestore.instance
      .collection('babies')
      .doc(uid)
      .collection('babyList');

  // add a new baby
  Future addBaby(
    String name,
    String gender,
    int age,
    double weight,
    double height,
  ) async {
    return await babyCollection.add({
      'name': name,
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
    });
  }

  // update existing baby
  Future updateBaby(
    String babyId,
    String name,
    String gender,
    int age,
    double weight,
    double height,
  ) async {
    return await babyCollection.doc(babyId).set({
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
        weight: (data['weight'] as num).toDouble(),
        height: (data['height'] as num).toDouble(),
      );
    }).toList();
  }

  // get babies stream (only current user's babies)
  Stream<List<Baby>> get babies {
    return babyCollection.snapshots().map(_babyListFromSnapshot);
  }
}
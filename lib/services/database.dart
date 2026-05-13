import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumi/models/baby.dart';

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
    int weight,
    int height,
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

  // get baby stream
  Stream<List<Baby>> get babies {
    return babyCollection.snapshots().map(_babyListFromSnapshot);
  }
}

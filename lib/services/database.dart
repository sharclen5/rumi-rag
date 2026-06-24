import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/models/recommendation.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  // reference to user's profile document
  DocumentReference get userDocument =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  // save or update user profile
  Future updateUserProfile(
    String firstName,
    String lastName,
    String phone,
    String gender,
    String email,
  ) async {
    return await userDocument.set({
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'gender': gender,
      'email': email,
    }, SetOptions(merge: true));
  }

  // update user profile photo
  Future updateProfilePicture(String base64Image) async {
    return await userDocument.set({
      'photoUrl': base64Image,
    }, SetOptions(merge: true));
  }

  // convert snapshot to UserProfile object
  UserProfile? _userProfileFromSnapshot(DocumentSnapshot snapshot) {
    if (!snapshot.exists) return null;
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return UserProfile(
      uid: uid,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'] ?? '',
      gender: data['gender'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  // get user profile as a stream (auto-updates if data changes)
  Stream<UserProfile?> get userProfile {
    return userDocument.snapshots().map(_userProfileFromSnapshot);
  }

  // reference to user's baby subcollection
  CollectionReference get babyCollection => FirebaseFirestore.instance
      .collection('babies')
      .doc(uid)
      .collection('babyList');

  // add a new baby
  Future addBaby(
    String firstName,
    String? middleName,
    String lastName,
    String gender,
    DateTime dateOfBirth,
    double weight,
    double height,
    List<String> allergyIds,
    bool isPremature,
    int? gestationalAgeWeeks,
    bool isActivelyBreastfed,
    int? toothCount,
    String? medicalHistory,
  ) async {
    return await babyCollection.add({
      'firstName': firstName,
      if (middleName != null && middleName.isNotEmpty) 'middleName': middleName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'weight': weight,
      'height': height,
      'isActive': false,
      'allergyIds': allergyIds,
      'isPremature': isPremature,
      // simpan kalo ada valuenya doang
      if (gestationalAgeWeeks != null)
        'gestationalAgeWeeks': gestationalAgeWeeks,
      'isActivelyBreastfed': isActivelyBreastfed,
      if (toothCount != null) 'toothCount': toothCount,
      if (medicalHistory != null && medicalHistory.isNotEmpty)
        'medicalHistory': medicalHistory,
    });
  }

  Future setActiveBaby(String babyId) async {
    final batch = FirebaseFirestore.instance
        .batch(); // uses a batch write to atomically set all babies to false, then the selected one to true

    // set jadi inactive semua
    final allBabies = await babyCollection.get();
    for (final doc in allBabies.docs) {
      batch.update(doc.reference, {'isActive': false});
    }

    // set selected jadi active
    batch.update(babyCollection.doc(babyId), {'isActive': true});

    return await batch.commit();
  }

  // update existing baby
  Future updateBaby(
    String babyId,
    String firstName,
    String? middleName,
    String lastName,
    String gender,
    DateTime dateOfBirth,
    double weight,
    double height,
    List<String> allergyIds,
    bool isPremature,
    int? gestationalAgeWeeks,
    bool isActivelyBreastfed,
    int? toothCount,
    String? medicalHistory,
  ) async {
    return await babyCollection.doc(babyId).set({
      'firstName': firstName,
      if (middleName != null && middleName.isNotEmpty) 'middleName': middleName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'weight': weight,
      'height': height,
      'allergyIds': allergyIds,
      'isPremature': isPremature,
      if (gestationalAgeWeeks != null)
        'gestationalAgeWeeks': gestationalAgeWeeks,
      'isActivelyBreastfed': isActivelyBreastfed,
      if (toothCount != null) 'toothCount': toothCount,
      if (medicalHistory != null && medicalHistory.isNotEmpty)
        'medicalHistory': medicalHistory,
    });
  }

  // delete a baby
  Future deleteBaby(String babyId) async {
    return await babyCollection.doc(babyId).delete();
  }

  // baby list from snapshot
  List<Baby> _babyListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Baby(
        id: doc.id,
        firstName: data['firstName'] ?? '',
        middleName: data['middleName'] ?? '',
        lastName: data['lastName'] ?? '',
        gender: data['gender'] ?? '',
        dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
        weight: (data['weight'] as num).toDouble(),
        height: (data['height'] as num).toDouble(),
        isActive: data['isActive'] ?? false,
        // ID alergi, default kosong kalo belum ada datanya
        allergyIds: List<String>.from(data['allergyIds'] ?? []),
        // status prematur, default false
        isPremature: data['isPremature'] ?? false,
        // usia gestasi, null kalo ga prematur
        gestationalAgeWeeks: data['gestationalAgeWeeks'],
        isActivelyBreastfed: data['isActivelyBreastfed'] ?? true,
        toothCount: data['toothCount'],
        medicalHistory: data['medicalHistory'],
      );
    }).toList();
  }

  // get babies stream (only current user's babies)
  Stream<List<Baby>> get babies {
    return babyCollection.snapshots().map(_babyListFromSnapshot);
  }

  // reference to user's recommendations subcollection
  CollectionReference get recommendationCollection =>
      userDocument.collection('recommendations');

  // save recommendation to Firestore
  Future saveRecommendation(Recommendation recommendation) async {
    final docId = '${recommendation.babyId}_${recommendation.date}';
    return await recommendationCollection
        .doc(docId)
        .set(recommendation.toJson());
  }

  // get recommendation for a specific baby and date
  Future<Recommendation?> getRecommendation(String babyId, String date) async {
    final docId = '${babyId}_${date}';
    final doc = await recommendationCollection.doc(docId).get();
    if (!doc.exists) return null;
    return Recommendation.fromFirestore(doc.data() as Map<String, dynamic>);
  }
}

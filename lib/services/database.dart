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

  // cek apakah user ini udah pernah liat intro slides
  Future<bool> hasSeenIntro() async {
    final doc = await userDocument.get();
    final data = doc.data() as Map<String, dynamic>?;
    return data?['hasSeenIntro'] ?? false;
  }

  // tandain user ini udah liat intro slides
  Future<void> markIntroAsSeen() async {
    return await userDocument.set({
      'hasSeenIntro': true,
    }, SetOptions(merge: true));
  }

  // cek apakah user ini udah pernah liat coach mark tour di Home
  Future<bool> hasSeenHomeTour() async {
    final doc = await userDocument.get();
    final data = doc.data() as Map<String, dynamic>?;
    return data?['hasSeenHomeTour'] ?? false;
  }

  // tandain user ini udah liat coach mark tour di Home
  Future<void> markHomeTourAsSeen() async {
    return await userDocument.set({
      'hasSeenHomeTour': true,
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
      role:
          data['role'] ??
          'user', // ← baca dari Firestore, fallback 'user' kalo field-nya belum ada
    );
  }

  // ambil role user sekali aja, buat route guarding di wrapper
  Future<String> getUserRole() async {
    final doc = await userDocument.get();
    final data = doc.data() as Map<String, dynamic>?;
    return data?['role'] ?? 'user'; // fallback 'user' kalo field belum ada
  }

  // ambil semua user buat admin dashboard — query langsung ke collection 'users'
  Stream<List<UserProfile>> getAllUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return UserProfile(
              uid: doc.id,
              firstName: data['firstName'] ?? '',
              lastName: data['lastName'] ?? '',
              phone: data['phone'] ?? '',
              gender: data['gender'] ?? '',
              email: data['email'] ?? '',
              photoUrl: data['photoUrl'],
              role:
                  data['role'] ??
                  'user', // fallback 'user' kalo belum ada field-nya
            );
          }).toList(),
        );
  }

  // [ADMIN] ambil semua bayi milik user tertentu — one-shot, bukan stream
  Future<List<Baby>> getBabiesForUser(String targetUid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('babies')
        .doc(targetUid)
        .collection('babyList')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
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
        allergyIds: List<String>.from(data['allergyIds'] ?? []),
        isPremature: data['isPremature'] ?? false,
        gestationalAgeWeeks: data['gestationalAgeWeeks'],
        isActivelyBreastfed: data['isActivelyBreastfed'] ?? true,
        toothCount: data['toothCount'],
        medicalHistory: data['medicalHistory'],
      );
    }).toList();
  }

  // [ADMIN] ambil rekomendasi milik bayi tertentu dari user tertentu
  Stream<List<Recommendation>> getRecommendationsForBaby(
    String targetUid,
    String babyId,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid)
        .collection('recommendations')
        .where('baby_id', isEqualTo: babyId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Recommendation.fromFirestore(doc.data()))
              .toList(),
        );
  }

  // [ADMIN] update data user lain — termasuk role
  Future<void> updateUserAsAdmin(
    String targetUid,
    String firstName,
    String lastName,
    String email,
    String phone,
    String gender,
    String role,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(targetUid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'role': role,
    }, SetOptions(merge: true));
  }

  // [ADMIN] hapus semua data user — recommendations, babies, user doc
  Future<void> deleteUserData(String targetUid) async {
    final batch = FirebaseFirestore.instance.batch();

    // hapus semua recommendations
    final recs = await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid)
        .collection('recommendations')
        .get();
    for (final doc in recs.docs) {
      batch.delete(doc.reference);
    }

    // hapus semua bayi
    final babies = await FirebaseFirestore.instance
        .collection('babies')
        .doc(targetUid)
        .collection('babyList')
        .get();
    for (final doc in babies.docs) {
      batch.delete(doc.reference);
    }

    // hapus doc babies/{targetUid} dan users/{targetUid}
    batch.delete(
      FirebaseFirestore.instance.collection('babies').doc(targetUid),
    );
    batch.delete(FirebaseFirestore.instance.collection('users').doc(targetUid));

    await batch.commit();
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
    final existing = await babyCollection.limit(1).get();
    final isFirstBaby = existing.docs.isEmpty;

    return await babyCollection.add({
      'firstName': firstName,
      if (middleName != null && middleName.isNotEmpty) 'middleName': middleName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'weight': weight,
      'height': height,
      'isActive': isFirstBaby,
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

  // get recommendation for a specific baby and date
  Future<Recommendation?> getRecommendation(
    String babyId,
    String date,
    String source,
  ) async {
    final docId = '${babyId}_${date}_$source';
    final doc = await recommendationCollection.doc(docId).get();
    if (!doc.exists) return null;
    return Recommendation.fromFirestore(doc.data() as Map<String, dynamic>);
  }

  // toggle isEaten for a single meal within a day's doc
  Future<void> toggleMealEaten(
    String babyId,
    String date,
    int mealIndex,
    String source,
  ) async {
    final docId = '${babyId}_${date}_$source';
    final docRef = recommendationCollection.doc(docId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final meals = List<Map<String, dynamic>>.from(
      (data['meals'] as List).map((m) => Map<String, dynamic>.from(m)),
    );

    if (mealIndex < 0 || mealIndex >= meals.length) return;

    final currentValue = meals[mealIndex]['isEaten'] ?? false;
    meals[mealIndex]['isEaten'] = !currentValue;

    await docRef.update({'meals': meals});
  }

  Future<void> updateMealTime(
    String babyId,
    String date,
    int mealIndex,
    String newTime,
    String source,
  ) async {
    final docId = '${babyId}_${date}_$source';
    final docRef = recommendationCollection.doc(docId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final meals = List<Map<String, dynamic>>.from(
      (data['meals'] as List).map((m) => Map<String, dynamic>.from(m)),
    );

    if (mealIndex < 0 || mealIndex >= meals.length) return;

    meals[mealIndex]['time'] = newTime;

    await docRef.update({'meals': meals});
  }

  // ADDED: stream of all recommendations for a baby, most recent first
  Stream<List<Recommendation>> getRecommendationHistory(
    String babyId,
    String source,
  ) {
    // CHANGED: filter juga by source, biar history rag app cuma nampilin data rag, begitu juga baseline
    return recommendationCollection
        .where('baby_id', isEqualTo: babyId)
        .where('source', isEqualTo: source)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Recommendation.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }
}

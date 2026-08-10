import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:rumi/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  // "_" sebelum auth menandakan variabel ini sifatnya private, cuma bisa diakses dalam class ini saja.

  // ADDED: flag buat ngasih tau Wrapper "woi, lagi proses register, jangan buru-buru pindah screen dulu"
  static bool isRegistering = false;

  // create user obj based on Firebase User
  User? _userFromFirebase(firebase_auth.User? user) {
    return user != null ? User(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  // Sign in anonymously
  Future<User?> signInAnon() async {
    try {
      firebase_auth.UserCredential result = await _auth.signInAnonymously();
      firebase_auth.User? user = result.user;
      return _userFromFirebase(user);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      firebase_auth.UserCredential result = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? user = result.user;
      return _userFromFirebase(user);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Register with email and password
  Future<dynamic> registerWithEmailAndPassword(
    // CHANGED: User? -> dynamic, biar bisa return String error
    String email,
    String firstName,
    String lastName,
    String phone,
    String gender,
    String password,
  ) async {
    isRegistering =
        true; // ADDED: nyalain flag SEBELUM createUser dipanggil, biar Wrapper langsung tau dari awal
    try {
      firebase_auth.UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? user = result.user;

      // existing: parent doc for baby data
      await FirebaseFirestore.instance.collection('babies').doc(user!.uid).set({
        'exists': true,
      });

      // new: store user profile data
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'gender': gender,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _auth.signOut();
      // DITAMBAH: ini yang ilang dari awal — tanpa return, function auto return null,
      // jadi di register.dart, result != null ga pernah kena, popup ga pernah muncul
      return _userFromFirebase(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      // CHANGED: catch spesifik FirebaseAuthException
      debugPrint(e.code);
      switch (e.code) {
        // ADDED: mapping error code Firebase ke pesan yang user-friendly
        case 'email-already-in-use':
          return 'Email sudah terdaftar, silakan gunakan email lain.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'network-request-failed':
          return 'Koneksi gagal, periksa internet kamu.';
        default:
          return 'Registrasi gagal: ${e.message}';
      }
    } catch (e) {
      // ADDED: catch-all untuk error di luar Firebase (Firestore, dll)
      debugPrint(e.toString());
      return 'Terjadi kesalahan, coba lagi.';
    } finally {
      isRegistering = false; // ADDED: matiin flag di sini, di dalam "finally"
      // "finally" ini jalan APAPUN yang terjadi -- sukses, error kena catch, error ga kena catch, apapun --
      // jadi flag ini dijamin balik ke false, ga bakal nyangkut true selamanya kalau misal ada error tak terduga
    }
  }

  // Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}

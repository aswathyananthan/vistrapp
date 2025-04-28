import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:core';

class AuthService {
  final FirebaseAuth _authService = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get userStatus {
    return _authService.authStateChanges().map((e) => e!);
  }

  Future signUpWithEmailAndPass(
      {required String email, required String password,required String name}) async {
    try {
      UserCredential res = await _authService.createUserWithEmailAndPassword(
          email: email, password: password,);
      User? user = res.user;
      
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithEmailAndPass(
      {required String email, required String password}) async {
    try {
      UserCredential res = await _authService.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = res.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
Future<String> getBuildingForUser(String email) async {
    try {
      // Query Firestore to find the document where email matches
      QuerySnapshot querySnapshot = await _firestore
          .collection('admin')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.get('building') ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print("Error fetching building name: $e");
      return 'Unknown';
    }
  }
}

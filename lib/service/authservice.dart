import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signupUser(
      {required String email,
      required String password,
      required String name}) async {
    String result = "Invalid credentials";
    try {
      if (email.isNotEmpty && name.isNotEmpty && email.isNotEmpty) {
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        await _firestore
            .collection("users")
            .doc(credential.user!.uid)
            .set({"name": name, "email": email, "uid": credential.user!.uid});
        result = "Success";
      } else {
        result = "Please enter all fields";
      }
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    String result = "Invalid credentials";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        result = "Success";
      } else {
        result = "Please enter all fields";
      }
    } catch (e) {
      print(e.toString());
    }

    return result;
  }

  Future<void> signout() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

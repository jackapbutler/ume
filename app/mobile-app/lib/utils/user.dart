import 'package:app/api.dart';
import 'package:app/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> signOut(BuildContext context) async {
  // sign out of Firebase Auth
  await FirebaseAuth.instance.signOut();
  // clear Firestore cache
  await FirebaseFirestore.instance.terminate();
  await FirebaseFirestore.instance.clearPersistence();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => AuthGate()),
  );
}

Future<void> deleteUser(BuildContext context) async {
  // delete profile data
  await deleteUserData();
  signOut(context);
}

User? currentUser() {
  return FirebaseAuth.instance.currentUser;
}

String? currentUserId() {
  final User? auth = currentUser();
  if (auth != null) {
    return auth.uid;
  } else {
    return null;
  }
}

bool isNewUser(User user) {
  final creationTime = user.metadata.creationTime;
  if (creationTime != null) {
    return DateTime.now().difference(creationTime).inMinutes < 1;
  }
  return false;
}

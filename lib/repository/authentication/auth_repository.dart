import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> registerWithEmailAndPassword(String email, String password);
  Future<User?> logIn(String emailAddress, String password);
  Future<String?> uploadToFirebase(File file, {bool isVideo = false, bool isHeadShot=false});
  Future<bool> sendPasswordOnEmail(String email);
  Future<void> signOut();
}

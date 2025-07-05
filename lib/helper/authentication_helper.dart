import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/repository/authentication/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  // ===================================== Sign In ======================================= //
  @override
  Future<User?> logIn(String emailAddress, String password) async {
    try {
      final authUser = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailAddress, password: password);
      if (authUser.user != null) {
        'User verified successfully'.showSuccessToast();
        return authUser.user;
      }
    } on FirebaseAuthException catch (e) {
      'Catch FirebaseAuthException in logIn --> ${e.message}'.errorLogs();
      'Invalid email or password'.showErrorToast();
    }
    return null;
  }

  // ===================================== Sign out ======================================= //
  @override
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      'Successfully logout'.showSuccessToast();
    } catch (e) {
      'SignOut Error: $e'.errorLogs();
    }
  }

  // ===================================== Register ======================================= //
  @override
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential authUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      return authUser.user;
    } on FirebaseAuthException catch (e) {
      'Catch FirebaseAuthException in registerWithEmailAndPassword --> ${e.message}'.errorLogs();
      if(e.code=='email-already-in-use')
      {
        "The email you entered is already in use".showErrorToast();
      }
    }
    return null;
  }

  // ===================================== Forgot Password ======================================= //

  @override
  Future<bool> sendPasswordOnEmail(String email) async {
    try {
      if (await doesUserExist(email)) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      'FirebaseAuthException: Failed to send password reset email. Reason: ${e.message}'.errorLogs();
      return false;
    } on SocketException catch (e) {
      'SocketException: Network issue detected while attempting to send password reset email. Reason: ${e.message}'.errorLogs();
      return false;
    } catch (e) {
      'Unexpected Error: Unable to send password reset email. Reason: $e'.errorLogs();
      return false;
    }
  }

  Future<bool> doesUserExist(String email) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection(AppCollectionConstants.usersCollection).where(StringConstant.email, isEqualTo: email).limit(1).get();
      return userDoc.docs.isNotEmpty;
    } catch (e) {
      'Error: Unable to verify user existence. Reason: $e'.errorLogs();
      return false;
    }
  }

  // ===================================== Upload to Firebase ======================================= //
  @override
  Future<String?> uploadToFirebase(File file, {bool isVideo = false, bool isHeadShot=false}) async {
    try {
      final String fileName = file.path.split('/').last;
      'File name --> $fileName'.infoLogs();

      final folderRef = FirebaseStorage.instance.ref().child('${FirebaseAuth.instance.currentUser?.uid}/${isVideo ? 'videos' : 'image'}');
      final Uint8List imageData = await file.readAsBytes();
      final Reference ref = folderRef.child(isVideo?'introductionVideo':isHeadShot?'headShotImage':'fullBodyImage');
      await ref.putData(imageData, SettableMetadata(contentType: isVideo ? 'video/mp4' : 'image/png', cacheControl: 'no-store'));

      final String downloadUrl = (await ref.getDownloadURL()).split('&token').first;
      'File uploaded successfully! Download URL: $downloadUrl'.logs();
      return downloadUrl;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in uploadToFirebase --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return null;
  }
}

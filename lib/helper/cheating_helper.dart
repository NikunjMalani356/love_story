import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/repository/cheating/cheating_repository.dart';
import 'package:love_story_unicorn/serialized/message_model.dart';

class CheatingImpl extends CheatingRepository {
  CollectionReference roomsCollection = FirebaseFirestore.instance.collection(AppCollectionConstants.rooms);

  @override
  Stream<QuerySnapshot> messageStream(String roomId) {
    return FirebaseFirestore.instance.collection("rooms").doc(roomId).collection('chats').orderBy('time', descending: false).snapshots();
  }

  @override
  Future<String?> findExistingRoom(String? userId ,{String? appositeUserId}) async {
    final currentUser =appositeUserId?? FirebaseAuth.instance.currentUser?.uid;

    if (currentUser == null || userId == null) {
      "Error: Current user or userId is null.".logs();
      return null;
    }

    final querySnapshot = await FirebaseFirestore.instance.collection("rooms").get();

    for (final doc in querySnapshot.docs) {
      final users = List<Map<String, dynamic>>.from(doc['users']);

      final containsCurrentUser = users.any((user) => user['uid'] == currentUser);
      final containsUserId = users.any((user) => user['uid'] == userId);

      if (containsCurrentUser && containsUserId) {
        return doc.id;
      }
    }
    return null;
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getRoomsStream(String? roomId) {
    return FirebaseFirestore.instance
        .collection("rooms")
        .doc(roomId)
        .collection('chats')
        .orderBy('time', descending: false)
        .snapshots();
  }

  @override
  Future<bool> sendMessage(MessageModel messageModel, String roomId) async {
    try {
      final DocumentReference<Map<String, dynamic>> messageRef = await roomsCollection.doc(roomId).collection('chats').add(messageModel.toJson());
      await messageRef.update({'messageId': messageRef.id});
      return true;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in sendMessage --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return false;
  }

  @override
  Future<void> updateMessageStatus(String roomId, String messageId, Map<String, dynamic> updates) async {
    try {
      await FirebaseFirestore.instance.collection('rooms').doc(roomId).collection('chats').doc(messageId).update(updates);
    } catch (e) {
      'Error updating message status: $e'.errorLogs();
    }
  }

  @override
  Future<void> deleteChatRoom(String roomId) async {
    try {
      // Reference to the room document
      final DocumentReference<Map<String, dynamic>> roomRef =
      FirebaseFirestore.instance.collection("rooms").doc(roomId);

      // Delete subcollection 'chats' if it exists
      final QuerySnapshot<Map<String, dynamic>> chatsSnapshot =
      await roomRef.collection('chats').get();

      for (final chatDoc in chatsSnapshot.docs) {
        await chatDoc.reference.delete();
      }

      // Delete the room document
      await roomRef.delete();
      "Room with ID $roomId deleted successfully.".logs();
    } catch (e) {
      "Error deleting room: $e".errorLogs();
    }
  }


  @override
  Future<String> createNewRoom({required String id, required String message, bool isOnline = false}) async {
    final currentUser = FirebaseAuth.instance.currentUser?.uid;

      final List<Map<String, dynamic>> users = [
        {"uid": currentUser, "isOnline": isOnline},
        {"uid": id, "isOnline": isOnline},
      ];

      final DocumentReference<Map<String, dynamic>> roomRef = await FirebaseFirestore.instance.collection("rooms").add({
        "users": users,
        "createdAt": FieldValue.serverTimestamp(),
      });

      await roomRef.update({'roomId': roomRef.id});

      await roomRef.collection('chats').add(
        MessageModel(
          messageId: roomRef
              .collection('chats')
              .doc()
              .id,
          senderId: currentUser,
          message: message,
          time: DateTime.now().toUtc(),
        ).toJson(),
      );

      return roomRef.id;
    }

    @override
  Stream<Map<String, dynamic>?> getUserOnlineStatus(String roomId, String userId) {
      return FirebaseFirestore.instance.collection('rooms').doc(roomId).snapshots().map((snapshot) {
        if (snapshot.exists) {
          final users = List<Map<String, dynamic>>.from(snapshot.data()?['users'] ?? []);
          return users.firstWhere((user) => user['uid'] != userId);
        }
        return null;
      });
    }
  }

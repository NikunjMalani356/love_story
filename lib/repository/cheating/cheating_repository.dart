import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:love_story_unicorn/serialized/message_model.dart';

abstract class CheatingRepository {
  Stream<QuerySnapshot> messageStream(String roomId);

  Future<String?> findExistingRoom(String? userId ,{String? appositeUserId});

  Stream<QuerySnapshot<Map<String, dynamic>>> getRoomsStream(String? roomId);

  Future<void> sendMessage(MessageModel messageModel, String roomId);

  Future<String> createNewRoom({required String id,required String message});

  Future<void> updateMessageStatus(String roomId, String messageId, Map<String, dynamic> updates);
  Future<void> deleteChatRoom(String roomId);

  Stream<Map<String, dynamic>?> getUserOnlineStatus(String roomId, String userId);
}

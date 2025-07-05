import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/cheating/cheating_repository.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';

class ChatController extends GetxController {
  UserRepository userRepository = getIt<UserRepository>();
  CheatingRepository cheatingRepository = getIt<CheatingRepository>();

  Future<UserModel?> getUserData(String? userId) async => await userRepository.getUserData(userId: userId);

  Future<String?> findExistingRoom(String? userId) async => await cheatingRepository.findExistingRoom(userId);

  Future<String?> createNewRoom({String? id, required String message}) async =>
      await cheatingRepository.createNewRoom(id: id ?? '', message: message);

  Stream<QuerySnapshot<Map<String, dynamic>>> getRoomsStream(String? roomId) =>
      cheatingRepository.getRoomsStream(roomId);

  Future<void> markMessageAsSeen({String? roomId, String? messageId, Map<String, dynamic>? updates}) async =>
      await cheatingRepository.updateMessageStatus(roomId ?? '', messageId ?? '', updates ?? {});
}

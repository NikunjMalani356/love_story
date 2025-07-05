import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';

abstract class UserRepository {
  Future<bool> createUser(UserModel userModel);

  Future<bool> checkUserSubscription();

  Future<bool> checkUserData();

  Stream<String?> rejectionTimeStream();

  Future<UserModel?>? getUserData({String? userId});

  Future<List<UserModel>> getAllUsers();

  Future<List<UserModel>> getFilteredDataForTimer();

  Future<QuerySnapshot<Object?>?> getQueriesData({bool isScroll = false, DocumentSnapshot<Object?>? lastQuerySnapshot});

  Future<String?> getLatestData();

  Future<bool> updateUserMap(String key, dynamic value, {String? userId});

  Future<bool> updateIntroMessageStatus(String targetUserId, bool status);

  Future<bool> updateUser(Map<String, dynamic> updatedFields, {String? userId});

  Future addUserToList(String listType, dynamic user, {String? userid});

  Future<void> addUserToLikedList(String listType, dynamic user);

  Future<void> addUserToFollowing(dynamic user);

  Future<void> removeUserFromFollowingList(FollowingModel followingModel, bool isForCurrentUser);

  Future<bool> updateMultiData(dynamic updateData);

  Future<void> updateVideoCallTiming(String userId);

  Future<bool> deleteUser({String? userId});

  Future<bool> deleteUserFolder({String? userId});
}

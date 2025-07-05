import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';

class UserRepositoryImpl extends UserRepository {
  CollectionReference userCollection = FirebaseFirestore.instance.collection(AppCollectionConstants.usersCollection);

  // ===================================== Create user ======================================= //
  @override
  Future<bool> createUser(UserModel userModel) async {
    try {
      await userCollection.doc(userModel.userId).set(userModel.toMap());
      return true;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in createUser --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return false;
  }

  @override
  Future<bool> deleteUser({String? userId}) async {
    final String? user = userId ?? FirebaseAuth.instance.currentUser?.uid;
    try {
      await userCollection.doc(user).delete();
      await FirebaseAuth.instance.currentUser?.delete();
      return true;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in deleteUser --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return false;
  }

  @override
  Future<bool> updateUser(Map<String, dynamic> updatedFields, {String? userId}) async {
    final String? user = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (user == null) {
      return false;
    }
    'UserId in updateUser --> $user'.infoLogs();
    try {
      await userCollection.doc(user).update(updatedFields);
      return true;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in updateUser --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return false;
  }

  @override
  Future<bool> checkUserSubscription() async {
    try {
      final UserModel? userModel = await getUserData();
      return userModel?.subscription != null;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in checkUserSubscription --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return false;
  }

  @override
  Future<bool> checkUserData() async {
    try {
      final UserModel? userModel = await getUserData();
      return userModel?.userCoins != null && (userModel?.userCoins ?? 0) > 0;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in checkUserData --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return false;
  }

  @override
  Stream<String?> rejectionTimeStream() {
    try {
      return userCollection.doc(FirebaseAuth.instance.currentUser?.uid).snapshots().map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final Map<String, dynamic> jsonData = snapshot.data()! as Map<String, dynamic>;
          final rejectionTime = jsonData['rejectionTime'];
          if (rejectionTime is String && DateTime.tryParse(rejectionTime) != null) {
            return rejectionTime;
          }
          return null;
        }
        return null;
      });
    } on FirebaseException catch (e) {
      'Catch FirebaseException in rejectionTimeStream --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
      return Stream.value(null);
    }
  }

  @override
  Future<UserModel?>? getUserData({String? userId}) async {
    final String? user = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (user == null) {
      return null;
    }
    'userId --> $user'.infoLogs();
    try {
      final DocumentSnapshot snapshot = await userCollection.doc(user).get();
      if (snapshot.exists && snapshot.data() != null) {
        final Map<String, dynamic> jsonData = snapshot.data()! as Map<String, dynamic>;
        return UserModel.fromJson(jsonData);
      }
    } on FirebaseException catch (e) {
      'Catch FirebaseException in getUserData --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return null;
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final QuerySnapshot allUsersSnapshot = await userCollection.get();

      return allUsersSnapshot.docs.map((doc) {
        final data = doc.data()! as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      'Catch FirebaseException in getAllUsers --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
      return [];
    }
  }

  @override
  Future<List<UserModel>> getFilteredDataForTimer() async {
    final List<UserModel> userData = [];
    try {
      final QuerySnapshot<Object?> querySnapshot = await userCollection.where('following', isNotEqualTo: null).where('following', isGreaterThan: []).get();

      'getFilteredDataForTimer --> ${querySnapshot.docs.length}'.logs();

      for (final element in querySnapshot.docs) {
        final data = element.data()! as Map<String, dynamic>;
        final UserModel userModel = UserModel.fromJson(data);
        if (userModel.following.isNotEmpty) {
          userData.add(userModel);
        }
      }

      'UserData --> ${userData.map((e) => e.fullName)}'.logs();
    } on FirebaseException catch (e) {
      'Catch FirebaseException in getFilteredDataForTimer --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return userData;
  }

  @override
  Future<QuerySnapshot<Object?>?> getQueriesData({bool isScroll = false, DocumentSnapshot<Object?>? lastQuerySnapshot}) async {
    try {
      'lastQuerySnapshot --> ${lastQuerySnapshot?.data()}'.infoLogs();

      final query = userCollection.orderBy('createdAt', descending: false);

      final QuerySnapshot<Object?> querySnapshot = lastQuerySnapshot?.data() != null ? await query.startAfterDocument(lastQuerySnapshot!).limit(20).get() : await query.limit(20).get();
      return querySnapshot;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in getQueriesData --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
      return null;
    }
  }

  @override
  Future<String?> getLatestData() async {
    final QuerySnapshot<Object?> dataLastQuerySnapshot = await userCollection.orderBy('createdAt', descending: false).limitToLast(1).get();

    if (dataLastQuerySnapshot.docs.isNotEmpty) {
      final UserModel userModel = UserModel.fromJson(dataLastQuerySnapshot.docs.first.data()! as Map<String, dynamic>);
      return userModel.userId;
    }
    return null;
  }

  @override
  Future<bool> updateUserMap(String key, dynamic value, {String? userId}) async {
    final String? user = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (user == null) {
      return false;
    }
    try {
      await userCollection.doc(user).update({key: value});
      return true;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in updateUserMap --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return false;
  }

  @override
  Future<bool> updateIntroMessageStatus(String targetUserId, bool status) async {
    try {
      final UserModel? currentUserData = await getUserData();
      if (currentUserData == null) {
        "Failed to fetch current user data.".errorLogs();
        return false;
      }

      final List<dynamic> followingList = currentUserData.toMap()['following'] ?? [];

      final int index = followingList.indexWhere((entry) => entry['userId'] == targetUserId);
      if (index == -1) {
        "User with ID $targetUserId not found in following list.".errorLogs();
        return false;
      }

      followingList[index]['isIntroMessageSent'] = status;

      await userCollection.doc(currentUserData.userId).update({
        'following': followingList,
      });

      "Updated isIntroMessageSent for user $targetUserId.".logs();
      return true;
    } catch (e) {
      "Error updating isIntroMessageSent: $e".errorLogs();
      return false;
    }
  }

  @override
  Future<void> addUserToList(String listType, dynamic user, {String? userid}) async {
    if (user != null) {
      try {
        final currentUserRef = userCollection.doc(userid ?? FirebaseAuth.instance.currentUser?.uid);

        await currentUserRef.update({
          listType: FieldValue.arrayUnion([user]),
        });

        if (listType == 'rejectedFrom') {
          await currentUserRef.update({
            'following': [],
          });
        }
        if (listType == 'rejected') {
          await currentUserRef.update({
            'followers': [],
          });
        }

        "User ID added to $listType list".logs();
      } catch (e) {
        "Error adding user to $listType list: $e".errorLogs();
      }
    }
  }

  @override
  Future<void> addUserToLikedList(String listType, dynamic user) async {
    try {
      final UserModel? currentUserData = await getUserData();
      if (currentUserData == null) {
        "Failed to fetch current user data.".errorLogs();
        return;
      }
      final List<dynamic> currentList = currentUserData.toMap()[listType] ?? [];
      "currentList --> $currentList".infoLogs();

      currentList.removeWhere((entry) => entry['userId'] == user.userId);

      currentList.add(user.toMap());

      await userCollection.doc(currentUserData.userId).update({
        listType: currentList,
      });

      "User ID added to $listType list with old data removed".logs();
    } catch (e) {
      "Error adding user to $listType list: $e".errorLogs();
    }
  }

  @override
  Future<void> addUserToFollowing(dynamic user) async {
    try {
      final UserModel? currentUserData = await getUserData();
      if (currentUserData == null) {
        "Failed to fetch current user data.".errorLogs();
        return;
      }
      final List<dynamic> currentList = currentUserData.toMap()['following'] ?? [];
      "currentList --> $currentList".infoLogs();

      currentList.removeWhere((entry) => entry['userId'] == user.userId);

      currentList.add(user.toMap());

      await userCollection.doc(currentUserData.userId).update({
        'following': currentList,
      });

      final UserModel? userData = await getUserData(userId: user.userId);
      if (userData == null) {
        "Failed to fetch user data.".errorLogs();
        return;
      }
      final FollowingModel followingModel = FollowingModel(
        userId: currentUserData.userId ?? '',
        followedTime: DateTime.now().toUtc(),
      );

      final List<dynamic> followingList = userData.toMap()['followers'] ?? [];
      followingList.add(followingModel.toMap());

      await userCollection.doc(user.userId).update({
        'followers': followingList,
      });

      "User ID added to following list with old data removed".logs();
    } catch (e) {
      "Error adding user to following list: $e".errorLogs();
    }
  }

  @override
  Future<void> removeUserFromFollowingList(FollowingModel followingModel, bool isForCurrentUser) async {
    try {
      final currentUserRef = userCollection.doc(!isForCurrentUser ? followingModel.userId : FirebaseAuth.instance.currentUser?.uid);
      await currentUserRef.update({
        'following': [],
      });
      final UserModel? userData = await getUserData(userId: followingModel.userId);
      if (userData == null) {
        "Failed to fetch user data.".errorLogs();
        return;
      }
      await userCollection.doc(!isForCurrentUser ? FirebaseAuth.instance.currentUser?.uid : followingModel.userId).update({
        'followers': [],
      });
      "User ID removed from following list".logs();
    } catch (e) {
      "Error removing user from following list: $e".errorLogs();
    }
  }

  @override
  Future<bool> updateMultiData(dynamic updateData) async {
    final String? user = FirebaseAuth.instance.currentUser?.uid;
    if (user == null) {
      return false;
    }
    try {
      await FirebaseFirestore.instance.collection('users').doc(user).update(updateData);
      return true;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in updateMultiData --> ${e.message}'.errorLogs();
    }
    return false;
  }

  @override
  Future<void> updateVideoCallTiming(String userId) async {
    final String? user = FirebaseAuth.instance.currentUser?.uid;
    if (user == null) {}
    try {
      final String videoCallTime = DateTime.now().toString();
      await userCollection.doc(user).update({'videoCallTime': videoCallTime});
      await userCollection.doc(userId).update({'videoCallTime': videoCallTime});
    } on FirebaseException catch (e) {
      'Catch FirebaseException in updateVideoCallTiming --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
  }

  @override
  Future<bool> deleteUserFolder({String? userId}) async {
    final String? uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      "No user is signed in".logs();
      return false;
    }
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final Reference userFolderRef = storage.ref().child(uid);
      await deleteFolderRecursively(userFolderRef);
      "User folder deleted successfully".infoLogs();
      return true;
    } on FirebaseException catch (e) {
      "Error deleting user folder: ${e.message}".errorLogs();
      e.message?.showErrorToast();
    }

    return false;
  }

  Future<void> deleteFolderRecursively(Reference folderRef) async {
    try {
      final ListResult listResult = await folderRef.listAll();
      for (final Reference fileRef in listResult.items) {
        await fileRef.delete();
        "Deleted file: ${fileRef.name}".infoLogs();
      }
      for (final Reference subFolderRef in listResult.prefixes) {
        await deleteFolderRecursively(subFolderRef);
      }
    } catch (e) {
      "Error during recursive folder deletion: $e".errorLogs();
    }
  }
}

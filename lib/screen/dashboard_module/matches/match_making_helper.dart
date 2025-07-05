import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/screen/dashboard_module/matches/match_making_screen.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';
import 'package:love_story_unicorn/service/config_service.dart';

class MatchMakingScreenHelper {
  MatchMakingScreenState state;
  double? itemWidth;
  double? itemHeight;
  double? aspectRatio;
  List<UserModel>? allUsers;
  UserModel? currentUserData;
  bool isLoading = true;
  bool isPageLoading = false;
  ScrollController scrollController = ScrollController();
  List<UserModel> usersFollowingCurrentUser = [];
  List<UserModel> currentUserFollowedUsers = [];
  double hours = 0.0;
  int rejectionTime = 0;
  List<String> infoList = [];
  bool isCurrentMutuallyFollowing = false;
  final StreamController<List<UserModel>> _userStreamController = StreamController<List<UserModel>>.broadcast();

  Stream<List<UserModel>> get userStream => _userStreamController.stream;
  DocumentSnapshot? lastQuerySnapshot;
  List<UserModel> filteredUsers = [];
  List<UserModel> tempFilteredUsers = [];

  MatchMakingScreenHelper(this.state) {
    Future.delayed(const Duration(milliseconds: 100), () async {
      await removeFollowerAndFollowingUsers();
      scrollToBottom();
      await getCurrentUserData();
      return getAllMatches();
    });
    itemWidth = Get.width / 2.27;
    itemHeight = Get.width / 1.5;
    aspectRatio = itemWidth! / itemHeight!;
    hours = ConfigService.instance.getHourAsSeconds().toDouble();
    rejectionTime = ConfigService.instance.getRejectTimeHourAsSeconds();
    // getMatch();
  }

  void updateState() => state.matchMakingController?.update();

  void scrollToBottom() {
    scrollController.addListener(
      () async {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          await getAllMatches(isScroll: true, isPage: true);
        }
      },
    );
  }

  Future<void> refreshMatches() async {
    isLoading = true;
    lastQuerySnapshot = null;
    allUsers = [];
    filteredUsers = [];
    updateState();
    await removeFollowerAndFollowingUsers();
    await getAllMatches(isPage: true);
    updateState();
  }

  Future<void> getCurrentUserData() async {
    isLoading = true;
    updateState();
    currentUserData = await state.matchMakingController?.userRepository.getUserData(userId: FirebaseAuth.instance.currentUser!.uid);
  }

  Future<void> getAllMatches({bool isScroll = false, bool isPage = false}) async {
    currentUserFollowedUsers = [];
    usersFollowingCurrentUser = [];
    isPageLoading = isPage;
    updateState();

    final List<UserModel> users = await convertToUserModel(isScroll: isScroll);
    'unfiltered users ---> ${users.length}'.logs();
    if (currentUserData == null) {
      throw Exception("Current user data is missing.");
    }

    for (final user in users) {
      await validateRejectionTime(user);
    }

    await getFollowersOrFollowingUser();
    for (final user in users) {
      if (isMutuallyFollowing(user, currentUserData!)) {
        isCurrentMutuallyFollowing = true;
      }
    }
    tempFilteredUsers.addAll(
      users.where((user) {
        final bool notCurrentUser = user.userId != FirebaseAuth.instance.currentUser?.uid;
        final bool notInRejected = !currentUserData!.rejected.contains(user.userId);
        final bool notInRejectedFrom = !user.rejectedFrom.contains(currentUserData?.userId);
        final bool notFollowed = !currentUserFollowedUsers.contains(user);
        final bool notFollowing = !usersFollowingCurrentUser.contains(user);
        final bool notInLikedOrBlocked = (currentUserData?.likedUser ?? []).any((element) => element.userId == user.userId && element.isLiked == false);
        final bool matchesPartnerPrefs = currentUserData!.partnerPrefs.contains(user.gender) && user.partnerPrefs.contains(currentUserData!.gender);
        final bool followListEmpty = !isUserFollowingListEmptyInLastHours(user);
        final bool followedListEmpty = !isUserFollowersListEmptyInLastHours(user);
        final bool hasSameIdInFollowLists = user.following.any((follow) => user.followers.any((follower) => follower.userId == follow.userId));
        final bool matchesLocationPrefs = checkLocationPreferences(
          currentUserData?.relocation,
          currentUserData?.userLocation,
          user.userLocation,
          user.relocation,
        );
        final bool withinAgeRange = isWithinAgeRange(user);
        final bool matchesChildPrefs = matchesChildPreferences(currentUserData?.childPref ?? ChildPreference(), user.childPref ?? ChildPreference());
        final bool notMutuallyFollowing = !user.following.any((followModel) => followModel.userId == currentUserData!.userId) || !currentUserData!.following.any((followModel) => followModel.userId == user.userId);

        return notCurrentUser &&
            followedListEmpty &&
            followListEmpty &&
            !hasSameIdInFollowLists &&
            notMutuallyFollowing &&
            notInRejected &&
            !notInLikedOrBlocked &&
            notFollowing &&
            notInRejectedFrom &&
            notFollowed &&
            matchesPartnerPrefs &&
            matchesLocationPrefs &&
            withinAgeRange &&
            // isUserRejectionTimerRunning &&
            matchesChildPrefs;
      }).toList(),
    );
    final String? lastId = await state.matchMakingController?.userRepository.getLatestData();
    if (users.isNotEmpty && tempFilteredUsers.length < 8 && lastId != users.last.userId) {
      'lastId --> $lastId'.logs();
      await getAllMatches();
    } else {
      filteredUsers.addAll(tempFilteredUsers);
      tempFilteredUsers.clear();
    }

    if (usersFollowingCurrentUser.isNotEmpty) filteredUsers.removeWhere((user) => user.userId == usersFollowingCurrentUser.first.userId);
    if (currentUserFollowedUsers.isNotEmpty) filteredUsers.removeWhere((user) => user.userId == currentUserFollowedUsers.first.userId);
    allUsers = [...usersFollowingCurrentUser, ...currentUserFollowedUsers, ...filteredUsers];
    allUsers = removeDuplicateUsersById(allUsers ?? []);

    await getInformation();
    isLoading = false;
    isPageLoading = false;
    updateState();
  }

  List<UserModel> removeDuplicateUsersById(List<UserModel> users) {
    final uniqueUsers = users.fold<Map<String, UserModel>>({}, (map, user) {
      map[user.userId ?? ''] = user;
      return map;
    });

    return uniqueUsers.values.toList();
  }

  Future<void> getFollowersOrFollowingUser() async {
    bool isFollowingEachOther = false;
    if (currentUserData?.following.isNotEmpty == true) {
      final oppositeUser = await state.matchMakingController?.userRepository.getUserData(userId: currentUserData?.following.first.userId);
      if (oppositeUser?.following.isNotEmpty == true && oppositeUser?.following.first.userId == currentUserData?.userId) {
        isFollowingEachOther = true;
      } else {
        isFollowingEachOther = false;
      }
    }
    if (!isFollowingEachOther) {
      if (currentUserData?.following.isNotEmpty ?? false) {
        'currentUserData.following.first.userId --> ${currentUserData?.following.first.userId}'.logs();
        final UserModel user = await state.matchMakingController?.userRepository.getUserData(userId: currentUserData?.following.first.userId) ?? UserModel();
        currentUserFollowedUsers = [user];
        updateState();
      }
      if (currentUserData?.followers.isNotEmpty ?? false) {
        'currentUserData.followers.first.userId --> ${currentUserData?.followers.first.userId}'.logs();
        final UserModel user = await state.matchMakingController?.userRepository.getUserData(userId: currentUserData?.followers.first.userId) ?? UserModel();
        usersFollowingCurrentUser = [user];
        updateState();
      }
    } else {
      currentUserFollowedUsers = [];
      usersFollowingCurrentUser = [];
    }
    updateState();
  }

  Future<List<UserModel>> convertToUserModel({bool isScroll = false}) async {
    final List<UserModel> users = [];
    final QuerySnapshot<Object?>? querySnapshot = await state.matchMakingController?.userRepository.getQueriesData(isScroll: isScroll, lastQuerySnapshot: lastQuerySnapshot);

    if (querySnapshot != null && querySnapshot.docs.isNotEmpty) {
      lastQuerySnapshot = querySnapshot.docs.last;

      for (final element in querySnapshot.docs) {
        final data = (element.data() ?? {}) as Map<String, dynamic>;
        users.add(UserModel.fromJson(data));
      }
    }
    return users;
  }

  Future<void> removeFollowerAndFollowingUsers() async {
    final List<UserModel> allUser = await state.matchMakingController?.userRepository.getFilteredDataForTimer() ?? [];
    'allUser --> ${allUser.length}'.logs();
    for (final UserModel users in allUser) {
      final UserModel user = users;
      if (user.following.isNotEmpty == true) {
        final UserModel? oppositeUser = allUser.firstWhereOrNull((element) => element.userId == user.following.first.userId);
        if (oppositeUser?.following.isNotEmpty == true && oppositeUser?.following.first.userId == users.userId) {
          '====> followed each other'.logs();
        } else {
          final time = user.following.first.followedTime;
          final difference = DateTime.now().toUtc().toUtc().difference(time).inSeconds;
          if (difference >= hours) {
            '====> remove this user diff is $difference'.logs();
            final Map<String, dynamic> oppositeUserMap = oppositeUser?.toMap() ?? {};
            oppositeUserMap['followers'] = [];
            oppositeUserMap['following'] = [];
            final Map<String, dynamic> userMap = user.toMap();
            userMap['followers'] = [];
            userMap['following'] = [];
            final roomId = await state.matchMakingController?.chattingRepository.findExistingRoom(user.userId, appositeUserId: oppositeUser?.userId);
            await state.matchMakingController?.userRepository.updateUser(userMap, userId: user.userId);
            await state.matchMakingController?.userRepository.updateUser(oppositeUserMap, userId: oppositeUser?.userId);
            if (roomId != null) await state.matchMakingController!.chattingRepository.deleteChatRoom(roomId);
          }
        }
      }
    }
  }

  Future<void> validateRejectionTime(UserModel user) async {
    final DateTime currentDateTime = DateTime.now().toUtc();
    final int differenceInMinutes = user.rejectionTime != null ? currentDateTime.difference(DateTime.parse(user.rejectionTime!)).inSeconds : 0;
    if (differenceInMinutes >= rejectionTime) {
      if (user.following.isNotEmpty) {
        final String? roomId = await state.matchMakingController?.chattingRepository.findExistingRoom(user.userId, appositeUserId: user.following.first.userId);
        "room id 0:- $roomId".logs();
        if (roomId != null) {
          final Map<String, dynamic> updatedUserMap = {
            'following': [],
            'followers': [],
            'rejectionTime': null,
            // 'rejectedFrom': FieldValue.arrayUnion([user.userId]),
            'rejected': FieldValue.arrayUnion([user.userId]),
          };

          final Map<String, dynamic> updatedCurrentUserMap = {
            'following': [],
            'followers': [],
            'rejectionTime': null,
            // 'rejected': FieldValue.arrayUnion([user.following.first.userId]),
            'rejectedFrom': FieldValue.arrayUnion([user.following.first.userId]),
          };

          await state.matchMakingController?.userRepository.updateUser(updatedCurrentUserMap, userId: user.userId);
          await state.matchMakingController?.userRepository.updateUser(updatedUserMap, userId: user.following.first.userId);
          await state.matchMakingController?.chattingRepository.deleteChatRoom(roomId);
        }
      }
    }
  }

  bool isUserFollowingListEmptyInLastHours(UserModel user) {
    if (user.following.isNotEmpty) {
      final now = DateTime.now().toUtc();
      final difference = now.difference(user.following.first.followedTime).inSeconds;
      return difference <= hours;
    }
    return false;
  }

  bool isUserFollowersListEmptyInLastHours(UserModel user) {
    if (user.followers.isNotEmpty) {
      final now = DateTime.now().toUtc();
      final difference = now.difference(user.followers.first.followedTime).inSeconds;
      return difference <= hours;
    }
    return false;
  }

  bool isMutuallyFollowing(UserModel userFirst, UserModel userSecond) {
    final isUserFirstFollowingUserSecond = userFirst.following.any((follow) => follow.userId == userSecond.userId);
    final isUserSecondFollowingUserFirst = userSecond.following.any((follow) => follow.userId == userFirst.userId);

    return isUserFirstFollowingUserSecond && isUserSecondFollowingUserFirst;
  }

  bool isFollowedAndTimerRunning(UserModel? user) {
    return currentUserData?.following.any((follow) {
          final now = DateTime.now().toUtc();
          final difference = now.difference(follow.followedTime).inSeconds;
          return follow.userId == user?.userId && difference <= hours;
        }) ??
        false;
  }

  bool isFollowersAndTimerRunning(UserModel? user) {
    return currentUserData!.followers.any((follow) {
      final now = DateTime.now().toUtc();
      final difference = now.difference(follow.followedTime).inSeconds;
      return follow.userId == user?.userId && difference <= hours;
    });
  }

  bool followingWithin48Hours() {
    return currentUserData!.following.isNotEmpty &&
        currentUserData!.following.any((follow) {
          final now = DateTime.now().toUtc();
          final difference = now.difference(follow.followedTime).inSeconds;
          return difference <= hours;
        });
  }

  bool followersWithin48Hours() {
    return currentUserData!.followers.isNotEmpty &&
        currentUserData!.followers.any((follow) {
          final now = DateTime.now().toUtc();
          final difference = now.difference(follow.followedTime).inSeconds;
          return difference <= hours;
        });
  }

  bool matchesChildPreferences(ChildPreference currentUserWantPrefs, ChildPreference otherUserWantPrefs) {
    if (currentUserWantPrefs.iWant?.isEmpty == true || otherUserWantPrefs.iWant?.isEmpty == true) return false;

    final bool caseOne = currentUserWantPrefs.iWant?.first == ListConstant.childPreIWantList[0] && (otherUserWantPrefs.iWant?.first == ListConstant.childPreIWantList[0] || otherUserWantPrefs.iWant?.first == ListConstant.childPreIWantList[2]);
    final bool caseTwo = currentUserWantPrefs.iWant?.first == ListConstant.childPreIWantList[1] && (otherUserWantPrefs.iWant?.first == ListConstant.childPreIWantList[1] || otherUserWantPrefs.iWant?.first == ListConstant.childPreIWantList[2]);
    final bool caseThree = currentUserWantPrefs.iWant?.first == ListConstant.childPreIWantList[2] && (otherUserWantPrefs.iWant?.first == ListConstant.childPreIWantList[0] || otherUserWantPrefs.iWant?.first == ListConstant.childPreIWantList[2]);
    if (caseOne || caseTwo || caseThree) {
      return true;
    } else {
      return false;
    }
  }

  bool checkLocationPreferences(
    List<String>? relocationPrefs,
    UserLocation? currentUserCountry,
    UserLocation? otherUserCountry,
    List<String>? otherRelocationPrefs,
  ) {
    // Return false if either user's preferences are null or empty
    if (relocationPrefs == null || relocationPrefs.isEmpty || otherRelocationPrefs == null || otherRelocationPrefs.isEmpty) {
      return false;
    }

    // Check if either user is willing to relocate "Anywhere for love"
    final bool currentUserWillingAnywhere = relocationPrefs.contains(ListConstant.relocationList[0]);
    final bool otherUserWillingAnywhere = otherRelocationPrefs.contains(ListConstant.relocationList[0]);

    // If both users prefer "Anywhere for love", return true
    if (currentUserWillingAnywhere && otherUserWillingAnywhere) {
      return true;
    }

    // Handle the scenario where one user prefers "Anywhere for love" and the other prefers "My Country"
    if (currentUserWillingAnywhere && otherRelocationPrefs.contains(ListConstant.relocationList[1])) {
      if (currentUserCountry?.country != null && currentUserCountry?.country == otherUserCountry?.country) {
        return true;
      }
    }
    if (otherUserWillingAnywhere && relocationPrefs.contains(ListConstant.relocationList[1])) {
      if (currentUserCountry?.country != null && currentUserCountry?.country == otherUserCountry?.country) {
        return true;
      }
    }

    // Check if both users prefer to stay in the same country
    final bool bothPreferSameCountry = relocationPrefs.contains(ListConstant.relocationList[1]) &&
        otherRelocationPrefs.contains(ListConstant.relocationList[1]) &&
        currentUserCountry?.country != null &&
        otherUserCountry?.country != null &&
        currentUserCountry?.country == otherUserCountry?.country;

    if (bothPreferSameCountry) {
      return true;
    }

    // Handle the scenario where one user prefers "My State" and the other prefers "My Country"
    if (relocationPrefs.contains(ListConstant.relocationList[2]) && otherRelocationPrefs.contains(ListConstant.relocationList[1])) {
      if (currentUserCountry?.state != null && otherUserCountry?.state != null && currentUserCountry?.state == otherUserCountry?.state && currentUserCountry?.country == otherUserCountry?.country) {
        return true;
      }
    }
    if (otherRelocationPrefs.contains(ListConstant.relocationList[2]) && relocationPrefs.contains(ListConstant.relocationList[1])) {
      if (currentUserCountry?.state != null && otherUserCountry?.state != null && currentUserCountry?.state == otherUserCountry?.state && currentUserCountry?.country == otherUserCountry?.country) {
        return true;
      }
    }

    // Check if both users prefer to stay in the same state
    final bool bothPreferSameState = relocationPrefs.contains(ListConstant.relocationList[2]) &&
        otherRelocationPrefs.contains(ListConstant.relocationList[2]) &&
        currentUserCountry?.state != null &&
        otherUserCountry?.state != null &&
        currentUserCountry?.state == otherUserCountry?.state;

    return bothPreferSameState;
  }

  bool isWithinAgeRange(UserModel? user) {
    if (user?.fullName != null && user?.userId != FirebaseAuth.instance.currentUser?.uid) {
      if (currentUserData?.dateOfBirth == null || user?.dateOfBirth == null) return false;

      // Calculate ages
      final int currentUserAge = currentUserData?.dateOfBirth != null ? calculateAge(currentUserData?.dateOfBirth ?? DateTime.now()) : 0;
      final int otherUserAge = user?.dateOfBirth != null ? calculateAge(user?.dateOfBirth ?? DateTime.now()) : 0;

      // Parse constraints for current user
      final int? currentMinAge = (currentUserData?.youngerAge != null && currentUserData?.youngerAge != ListConstant.youngerAges[3]) ? currentUserAge + int.parse(currentUserData?.youngerAge ?? '0') : null;
      final int? currentMaxAge = (currentUserData?.olderAge != null && currentUserData?.olderAge != ListConstant.olderAges[3]) ? currentUserAge + int.parse(currentUserData?.olderAge ?? '0') : null;

      // Parse constraints for other user
      final int? otherMinAge = (user?.youngerAge != null && user?.youngerAge != ListConstant.youngerAges[3]) ? otherUserAge + int.parse(user?.youngerAge ?? '0') : null;
      final int? otherMaxAge = (user?.olderAge != null && user?.olderAge != ListConstant.olderAges[3]) ? otherUserAge + int.parse(user?.olderAge ?? '0') : null;

      // Check current user's constraints (check if other user fits within the age range)
      final bool matchesCurrentUserConstraints = (currentMinAge == null || otherUserAge >= currentMinAge) && (currentMaxAge == null || otherUserAge <= currentMaxAge);

      // Check other user's constraints (check if current user fits within the age range)
      final bool matchesOtherUserConstraints = (otherMinAge == null || currentUserAge >= otherMinAge) && (otherMaxAge == null || currentUserAge <= otherMaxAge);

      // Return true if both constraints match
      final bool result = matchesCurrentUserConstraints && matchesOtherUserConstraints;
      return result;
    }
    return false;
  }

  int calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;

    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Stream<Map<String, int>> followedTimeStream(FollowingModel followingModel) async* {
    final followedTime = followingModel.followedTime;
    final durationToAdd = Duration(seconds: hours.toInt());

    final endTime = followedTime.add(durationToAdd);

    while (true) {
      final now = DateTime.now().toUtc();
      if (now.isAfter(endTime)) {
        yield {'hours': 0, 'minutes': 0, 'seconds': 0};
        break;
      }

      final remaining = endTime.difference(now);
      final hoursLeft = remaining.inHours;
      final minutesLeft = remaining.inMinutes % 60;
      final secondsLeft = remaining.inSeconds % 60;

      yield {
        'hours': hoursLeft,
        'minutes': minutesLeft,
        'seconds': secondsLeft,
      };

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> onOpenProfile({UserModel? user}) async {
    final bool isQuestionExist = await state.matchMakingController?.queAnsRepository.checkQuestionExist() ?? false;

    if (isQuestionExist) {
      isLoading = true;
      updateState();
      if (currentUserData?.likedUser?.any((element) => element.userId == user?.userId) ?? false) {
        RouteHelper.instance.gotoPartnerProfile(currentUser: user);
      } else {
        RouteHelper.instance.gotoPartnerImages(currentUser: user);
      }
      isLoading = false;
      updateState();
    } else {
      RouteHelper.instance.gotoMandatory(currentUser: user);
    }
  }

  Future<void> getInformation() async {
    final Map<String, dynamic> utillsData = await state.matchMakingController?.utillsRepository.getUtillsData('app_information') ?? {};
    if (utillsData.containsKey('information')) {
      final List<dynamic> infoData = utillsData['information'];
      infoList = infoData.map((item) => item.toString()).toList();
    }
  }
}

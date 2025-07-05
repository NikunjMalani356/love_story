import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/screen/dashboard_module/swipe/swipe_screen.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:video_player/video_player.dart';

class SwipeHelper {
  SwipeScreenState state;
  int swipedCount = 0;
  VideoPlayerController? videoController;
  bool isVideoPlaying = false;
  bool isShimmerVisible = true;
  List<UserModel>? allUsers;
  bool isLoading = false;
  int currentPage = 0;
  int currentSwipeIndex = 0;
  Timer? autoSlideTimer;
  bool isAutoSlideEnabled = true;
  final Map<int, PageController> pageControllers = {};
  SwipableStackController swipeStackController = SwipableStackController();
  bool showForwardGif = false;
  bool showBackwardGif = false;

  SwipeHelper(this.state) {
    Future.delayed(
      const Duration(milliseconds: 100),
      () async {
        await getAllMatches();
        if (allUsers != null) {
          swipedCount = allUsers!.length;
        }
        setupControllerForNewCard(0);
      },
    );
  }

  void updateState() => state.swipeController?.update();

  void setupControllerForNewCard(int index) {
    pageControllers[index] = PageController();
    currentSwipeIndex = index;
    startAutoSlide(index);
  }

  void startAutoSlide(int index) {
    autoSlideTimer?.cancel();
    autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (isAutoSlideEnabled && pageControllers[index]?.hasClients == true && !isShimmerVisible) {
        final nextPage = (pageControllers[index]!.page?.round() ?? 0) + 1;
        if (nextPage < 3) {
          pageControllers[index]!.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          pageControllers[index]!
              .animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
              .then((_) {
            isAutoSlideEnabled = true;
            timer.cancel();
            updateState();
          });
        }
      }
    });
  }

  void disposeController(int index) {
    pageControllers[index]?.dispose();
    pageControllers.remove(index);
  }

  void disposeVideoController() {
    videoController?.pause();
    videoController?.dispose();
    videoController = null;
  }

  void dispose() {
    disposeVideoController();
    autoSlideTimer?.cancel();
    for (final controller in pageControllers.values) {
      controller.dispose();
    }
  }

  void pauseAutoSlide() {
    autoSlideTimer?.cancel();
  }

  Future<void> getAllMatches() async {
    isLoading = true;
    updateState();

    try {
      final UserModel? currentUserData = await state.swipeController?.userRepository.getUserData(userId: FirebaseAuth.instance.currentUser?.uid);

      final users = await state.swipeController?.userRepository.getAllUsers();
      if (currentUserData == null || currentUserData.dateOfBirth == null) {
        throw Exception("Current user data or date of birth is missing.");
      }

      allUsers = users?.where((user) {
        final bool notCurrentUser = user.userId != FirebaseAuth.instance.currentUser?.uid;
        final bool notInFollowing =
            !currentUserData.following.any((followModel) => followModel.userId == user.userId) && !user.following.any((followModel) => followModel.userId == currentUserData.userId) && !currentUserData.rejected.contains(user.userId);
        final bool notInRejected = !currentUserData.rejected.contains(user.userId);
        final bool matchesPartnerPrefs = currentUserData.partnerPrefs.contains(user.gender);
        final bool matchesLocationPrefs = checkLocationPreferences(
          currentUserData.relocation,
          currentUserData.userLocation,
          user.userLocation,
        );
        final bool withinAgeRange = isWithinAgeRange(
          currentUserData.dateOfBirth!,
          user.dateOfBirth,
          currentUserData.youngerAge,
          currentUserData.olderAge,
        );
        final bool matchesChildPrefs = matchesChildPreferences(
          currentUserData.childPref?.iWant,
          user.childPref?.iWant,
        );
        return notCurrentUser && notInFollowing && notInRejected && matchesPartnerPrefs && matchesLocationPrefs && withinAgeRange && matchesChildPrefs;
      }).toList();

      if (allUsers != null && allUsers!.isNotEmpty) {
        await initializeVideoForCurrentUser();
      }
    } catch (e) {
      'Error getting matches: $e'.errorLogs();
    } finally {
      isLoading = false;
      updateState();
    }
  }

  bool matchesChildPreferences(List<String>? currentUserPrefs, List<String>? otherUserPrefs) {
    if (currentUserPrefs == null || otherUserPrefs == null) {
      return false;
    }
    return currentUserPrefs.every((pref) => otherUserPrefs.contains(pref));
  }

  bool checkLocationPreferences(List<String>? relocationPrefs, UserLocation? currentUserCountry, UserLocation? otherUserCountry) {
    if (relocationPrefs == null || relocationPrefs.isEmpty) {
      return false;
    }

    if (relocationPrefs.contains(ListConstant.relocationList.first)) {
      return true;
    }

    if (relocationPrefs.contains(ListConstant.relocationList[1])) {
      return currentUserCountry?.country != null && otherUserCountry?.country != null && currentUserCountry?.country == otherUserCountry?.country;
    }
    if (relocationPrefs.contains(ListConstant.relocationList[2])) {
      return currentUserCountry?.state != null && otherUserCountry?.state != null && currentUserCountry?.state == otherUserCountry?.state;
    }

    return false;
  }

  bool isWithinAgeRange(
    DateTime currentUserDob,
    DateTime? otherUserDob,
    String? youngerAge,
    String? olderAge,
  ) {
    if (otherUserDob == null) return false;
    final int ageGap = calculateAgeGap(currentUserDob, otherUserDob);

    final int? minAge = int.tryParse(youngerAge ?? '');
    final int? maxAge = int.tryParse(olderAge ?? '');

    final bool matchesMinAge = minAge == null || ageGap >= minAge;
    final bool matchesMaxAge = maxAge == null || ageGap <= maxAge;
    if (matchesMinAge && matchesMaxAge) {}
    return matchesMinAge && matchesMaxAge;
  }

  int calculateAgeGap(DateTime currentUserDob, DateTime otherUserDob) {
    final int currentUserAge = calculateAge(currentUserDob);
    final int otherUserAge = calculateAge(otherUserDob);
    final int difference = otherUserAge - currentUserAge;

    return difference;
  }

  int calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;

    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  void onSwipeCompleted(int index, SwipeDirection direction) {
    if (videoController?.value.isPlaying == true) {
      videoController?.pause();
      isVideoPlaying = false;
    }
    swipedCount--;
    currentPage = 0;
    isShimmerVisible = false;
    disposeController(index);
    setupControllerForNewCard(index + 1);
    updateState();
  }

  void onPageChanged(int index, UserModel? user) {
    currentPage = index;
    if (index == 2 && user != null) {
      startVideo(user);
      isAutoSlideEnabled = true;
    } else {
      videoController?.pause();
      isVideoPlaying = false;
      isAutoSlideEnabled = true;
    }
  }

  Future<void> initializeVideoForCurrentUser() async {
    if (allUsers != null && allUsers!.isNotEmpty && allUsers!.first.introductionVideo != null) {
      isShimmerVisible = true;
      updateState();

      videoController = VideoPlayerController.networkUrl(
        Uri.parse(allUsers!.first.introductionVideo!),
      );
      await videoController?.initialize();

      isShimmerVisible = false;
      updateState();
    }
  }

  void manageVideoPlayer() {
    if (videoController?.value.isPlaying == true) {
      videoController?.pause();
      isVideoPlaying = false;
    } else {
      videoController?.play();
      isVideoPlaying = true;
      pauseAutoSlide();
    }
    updateState();
  }

  Future<void> startVideo(UserModel user) async {
    if (user.introductionVideo != null) {
      if (videoController == null || videoController?.dataSource != user.introductionVideo) {
        await videoController?.dispose();
        videoController = VideoPlayerController.networkUrl(
          Uri.parse(user.introductionVideo!),
        );

        isShimmerVisible = true;
        updateState();

        await videoController?.initialize();
        isShimmerVisible = false;
        videoController?.play();
        isVideoPlaying = true;
        updateState();

        Future.delayed(const Duration(seconds: 5), () {
          isAutoSlideEnabled = true;
          updateState();
        });
      } else if (!isVideoPlaying) {
        videoController?.play();
        isVideoPlaying = true;
        updateState();

        Future.delayed(const Duration(seconds: 5), () {
          isAutoSlideEnabled = true;
          updateState();
        });
      }
    }
  }

  Future<void> onNegativeSwipe(BuildContext context) async {
    if (showBackwardGif == false) {
      showBackwardGif = !showBackwardGif;
      updateState();
    }
    final bool shouldReject = await state.showConfirmationDialog(context, "are you sure you want to remove this potential match?");
    showBackwardGif = false;
    updateState();
    if (shouldReject) {
      final currentIndex = swipeStackController.currentIndex;
      await state.swipeController?.userRepository.addUserToList('rejected', allUsers?[currentIndex].userId);
      swipeStackController.next(swipeDirection: SwipeDirection.left);
      updateState();
    }
  }

  Future<void> onPositiveSwipe(BuildContext context) async {
    final bool? isQuestionExist = await state.swipeController?.queAnsRepository.checkQuestionExist();
    if (isQuestionExist!) {
      if (showForwardGif == false) {
        showForwardGif = !showForwardGif;
        updateState();
      }
      final bool shouldFollow = await state.showConfirmationDialog(context, "are you sure you want more information on this person?");
      showForwardGif = false;
      updateState();
      if (shouldFollow) {
        final currentIndex = swipeStackController.currentIndex;
        await state.swipeController?.userRepository.addUserToList('following', allUsers?[currentIndex].userId);
        swipeStackController.next(swipeDirection: SwipeDirection.right);
        updateState();
      }
    } else {
      RouteHelper.instance.gotoMandatory();
    }
  }
}

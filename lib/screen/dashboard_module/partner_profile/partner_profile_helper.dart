import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/screen/dashboard_module/partner_profile/partner_profile_screen.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';
import 'package:love_story_unicorn/service/config_service.dart';
import 'package:love_story_unicorn/service/send_notification_service.dart';
import 'package:video_player/video_player.dart';

class PartnerProfileHelper {
  PartnerProfileScreenState state;
  UserModel? partnerProfile;
  bool isLoading = true;
  Map<String, dynamic> questionAnswer = {};
  VideoPlayerController? videoController;
  bool isVideoPlaying = false;
  final CarouselSliderController carouselSliderController = CarouselSliderController();
  bool isFullDetails = false;
  bool showForwardGif = false;
  bool showBackwardGif = false;
  bool isDragonShow = true;
  Timer? autoSlideTimer;
  int currentPage = 0;
  UserModel? currentUserData;
  double hours = 0;

  PartnerProfileHelper(this.state) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      await getProfile();
      await getAllQuestions();
      await getCurrentUser();
      isLoading = false;
      updateState();
    });
    hours = ConfigService.instance.getHourAsSeconds().toDouble();
    "hours --> $hours".logs();
  }

  void updateState() => state.partnerProfileController?.update();

  void onPageChanged(int index) {
    currentPage = index;
    updateState();
  }

  Future<void> getProfile() async {
    partnerProfile = Get.arguments['currentUser'];
    'current profile --> ${partnerProfile?.userId}'.logs();
    isDragonShow = Get.arguments['isDragonShow']??true;
  }

  Future<void> getCurrentUser() async {
    currentUserData = await state.partnerProfileController?.userRepository.getUserData();
    'current user --> ${currentUserData?.userId}'.logs();
    isLoading = false;
    updateState();
  }

  Future<void> getAllQuestions() async {
    try {
      final Map<String, dynamic>? allQuestionAnswer = await state.partnerProfileController?.queAnsRepository.getQuestion(userId: partnerProfile?.userId);
      'allQuestionAnswer --> $allQuestionAnswer'.logs();
      questionAnswer = {'questions_and_answers': []};
      if (allQuestionAnswer != null) {
        if (allQuestionAnswer.containsKey('mandatory')) {
          questionAnswer['questions_and_answers'].addAll(allQuestionAnswer['mandatory']);
        }
        if (allQuestionAnswer.containsKey('optional')) {
          questionAnswer['questions_and_answers'].addAll(allQuestionAnswer['optional']);
        }
      }
      'questionAnswer --> ${questionAnswer['questions_and_answers'].length}'.logs();
      await initializeVideoForCurrentUser();
    } catch (e) {
      'Catch exception in getAllQuestions --> $e'.errorLogs();
    }
  }

  void manageVideoPlayer() {
    if (videoController?.value.isPlaying == true) {
      videoController?.pause();
      isVideoPlaying = false;
    } else {
      videoController?.play();
      isVideoPlaying = true;
    }
    updateState();
  }

  Future<void> initializeVideoForCurrentUser() async {
    videoController = VideoPlayerController.networkUrl(
      Uri.parse(partnerProfile!.introductionVideo!),
    );
    await videoController?.initialize();
    videoController?.addListener(() {
      if (videoController?.value.position == videoController?.value.duration) {
        isVideoPlaying = false;
        updateState();
      }
    });
    updateState();
  }

  Future<void> onNegativeSwipe(BuildContext context) async {
    if (showBackwardGif == false) {
      showBackwardGif = !showBackwardGif;
      updateState();
    }

    final bool isAlreadyFollowed = await isUserFollowedWithin48Hours();
    "isAlreadyFollowed --> $isAlreadyFollowed".logs();

    if (isAlreadyFollowed) {
      await showFollowCooldownDialog(context);

      showBackwardGif = false;
      updateState();
      return;
    }
    final bool shouldReject = await state.showConfirmationDialog(context, "are you sure you want to remove this potential match?");
    showBackwardGif = false;
    updateState();
    if (shouldReject) {
      isLoading = true;
      updateState();
      await state.partnerProfileController?.userRepository.addUserToList('rejected', partnerProfile?.userId);
      await state.partnerProfileController?.userRepository.addUserToList('rejectedFrom', currentUserData?.userId, userid: partnerProfile?.userId);
      if (partnerProfile!.following.firstWhere((follow) => follow.userId == currentUserData?.userId, orElse: () => FollowingModel(userId: '', followedTime: DateTime.now().toUtc())).userId.isNotEmpty) {
        if (partnerProfile?.fcmToken != null) {
          SendNotificationService.instance.sendNotification(fcmToken: partnerProfile?.fcmToken ?? '', senderMessage: '${currentUserData?.fullName} rejected your request', senderName: partnerProfile?.fullName ?? '');
        }
      }
      final String? roomId = await state.partnerProfileController?.chattingRepository.findExistingRoom(partnerProfile?.userId);
      "roomId --> $roomId".logs();
      if (roomId != null) {
        await state.partnerProfileController?.chattingRepository.deleteChatRoom(roomId);
      }
      "You Rejected this person ${partnerProfile?.fullName}".showSuccessToast();
      isLoading = false;
      updateState();
      RouteHelper.instance.gotoDashboard();
    }
  }

  Future<void> onPositiveSwipe(BuildContext context) async {
    if (!showForwardGif) {
      showForwardGif = true;
      updateState();
    }

    final bool? isIntroMessageAlreadySent = await isIntroMessageSent();
    final bool isAlreadyFollowed = await isUserFollowedWithin48Hours();
    if (isAlreadyFollowed) {
      if (isIntroMessageAlreadySent == false) {
        RouteHelper.instance.gotoIntroMessage(userid: partnerProfile?.userId ?? '');
        showForwardGif = false;
        updateState();
        return;
      } else {
        await showFollowCooldownDialog(context);
        showForwardGif = false;
        updateState();
        return;
      }
    }
    if (currentUserData!.rejectedFrom.any((userId) => userId == partnerProfile?.userId)) {
      await state.showRejectionDialog(context, "You have already rejected by this person, you're not able to double dragon them");
      showForwardGif = false;
      updateState();
      return;
    }

    final bool isAlreadyFollowedByUser = currentUserData!.followers.any((user) => user.userId == partnerProfile?.userId);

    final isAlreadyUserFollowedByUserInHours = await isUserFollowersListEmptyInLastHours();
    "isAlreadyUserFollowedByUserInHours --> $isAlreadyUserFollowedByUserInHours".logs();
    final bool shouldFollow = await state.showConfirmationDialog(
      context,
      isAlreadyFollowedByUser && isAlreadyUserFollowedByUserInHours == true
          ? "confirmation are you sure you want to double green dragon this person back? if yes, you will not be able to access other potential options and others cannot access your profile in the time you are getting to know this person."
          : "Are you sure you want to double dragon this person? If yes, they will be notified and have 48 hours to like you back or you disappear for them",
    );

    showForwardGif = false;
    updateState();

    if (shouldFollow) {
      isLoading = true;
      updateState();
      final FollowingModel followingModel = FollowingModel(
        userId: partnerProfile!.userId ?? '',
        followedTime: DateTime.now().toUtc(),
      );
      await state.partnerProfileController?.userRepository.removeUserFromFollowingList(followingModel, true);
      await state.partnerProfileController?.userRepository.addUserToFollowing(followingModel);
      if (partnerProfile?.fcmToken != null) SendNotificationService.instance.sendNotification(fcmToken: partnerProfile?.fcmToken ?? '', senderMessage: '${currentUserData?.fullName} started following you', senderName: partnerProfile?.fullName ?? '');
      if(isAlreadyFollowedByUser) {
        await state.partnerProfileController?.userRepository.updateVideoCallTiming(partnerProfile!.userId ?? '');
      }
      "You followed this person ${partnerProfile?.fullName}".showSuccessToast();
      isLoading = false;
      updateState();
      RouteHelper.instance.gotoIntroMessage(userid: partnerProfile?.userId ?? '');
    }
  }

  Future<void> showFollowCooldownDialog(
    BuildContext context,
  ) async {
    await Get.dialog<bool>(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(StringConstant.confirmation, fontSize: Dimens.textSizeVeryLarge, fontWeight: FontWeight.w700),
            const SizedBox(height: Dimens.heightSmall),
            const AppText("You have already followed this person in last 48 hours. You can do any action after", fontSize: Dimens.size20, textAlign: TextAlign.center),
            const SizedBox(height: Dimens.heightSmallMedium),
            StreamBuilder<Map<String, int>>(
              stream: followedTimeStream(currentUserData!.following.firstWhere((follow) => follow.userId == partnerProfile?.userId, orElse: () => FollowingModel(userId: '', followedTime: DateTime.now().toUtc()))),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final timeRemaining = snapshot.data ?? {'hours': 0, 'minutes': 0, 'seconds': 0};
                final hours = timeRemaining['hours'] ?? 0;
                final minutes = timeRemaining['minutes'] ?? 0;
                final seconds = timeRemaining['seconds'] ?? 0;
                if (hours > 0 || minutes > 0 || seconds > 0) {
                  return Text(
                    '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: AppColorConstant.appBlack, fontWeight: FontWeight.bold),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    title: StringConstant.okText,
                    onTap: () {
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
      if (hoursLeft == 0 && minutesLeft == 0 && secondsLeft == 0) {
        updateState();
      }

      yield {
        'hours': hoursLeft,
        'minutes': minutesLeft,
        'seconds': secondsLeft,
      };

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<bool?> isIntroMessageSent() async {
    if (currentUserData != null) {
      final followedUser = currentUserData!.following.firstWhere(
        (follow) => follow.userId == partnerProfile?.userId,
        orElse: () => FollowingModel(userId: '', followedTime: DateTime.now().toUtc()),
      );

      if (followedUser.userId.isNotEmpty) {
        return followedUser.isIntroMessageSent;
      }
    }
    return false;
  }

  Future<bool> isUserFollowedWithin48Hours() async {
    if (currentUserData != null) {
      final followedUser = currentUserData!.following.firstWhere(
        (follow) => follow.userId == partnerProfile?.userId,
        orElse: () => FollowingModel(userId: '', followedTime: DateTime.now().toUtc()),
      );

      if (followedUser.userId.isNotEmpty) {
        final difference = DateTime.now().toUtc().difference(followedUser.followedTime).inSeconds;
        return difference <= hours;
      }
    }
    return false;
  }

  Future<bool> isUserFollowersListEmptyInLastHours() async {
    if (currentUserData != null && partnerProfile != null) {
      final followedUser = currentUserData!.followers.firstWhere(
        (follower) => follower.userId == partnerProfile!.userId,
        orElse: () => FollowingModel(userId: '', followedTime: DateTime.now().toUtc()),
      );

      if (followedUser.userId.isNotEmpty) {
        final timeDifference = DateTime.now().toUtc().difference(followedUser.followedTime).inSeconds;

        if (timeDifference <= hours) {
          return true;
        } else {
          await state.partnerProfileController?.userRepository.removeUserFromFollowingList(followedUser, false);
          "Follow request removed for userId: ${followedUser.userId}".logs();
          updateState();
        }
      }
    }
    return false;
  }
}

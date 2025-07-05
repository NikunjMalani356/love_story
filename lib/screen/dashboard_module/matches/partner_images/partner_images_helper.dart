import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/screen/dashboard_module/matches/partner_images/partner_images_screen.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';
import 'package:love_story_unicorn/service/send_notification_service.dart';
import 'package:video_player/video_player.dart';

class PartnerImagesHelper {
  PartnerImagesScreenState state;
  int currentPage = 0;
  UserModel? userProfile;
  UserModel? currentUserData;
  final PageController pageController = PageController();
  CarouselSliderController carouselController = CarouselSliderController();
  VideoPlayerController? videoController;
  bool isVideoPlaying = false;
  bool showForwardGif = false;
  bool isLoading = true;
  bool showBackwardGif = false;

  PartnerImagesHelper(this.state) {
    Future.delayed(const Duration(milliseconds: 100), () => getProfile());
  }

  void manageCurrentPage(int value) {
    currentPage = value;
    updateState();
  }

  Future<void> getProfile() async {
    userProfile = Get.arguments;
    currentUserData = await state.partnerImagesController?.userRepository.getUserData();

    initializeVideoForCurrentUser();
    isLoading = false;
    updateState();
  }

  void updateState() => state.partnerImagesController?.update();

  void onPageChanged(int index) {
    currentPage = index;
    updateState();
  }

  Future<void> initializeVideoForCurrentUser() async {
    if (userProfile?.introductionVideo?.isNotEmpty == true) {
      videoController = VideoPlayerController.networkUrl(Uri.parse(userProfile!.introductionVideo!));
      await videoController?.initialize();
      isVideoPlaying = false;
      updateState();
      videoController?.addListener(() {
        if (videoController?.value.position == videoController?.value.duration) {
          isVideoPlaying = false;
          updateState();
        }
      });
    }
  }

  void disposeVideoController() {
    videoController?.pause();
    videoController?.dispose();
    videoController = null;
  }
  Future<void> onNegativeSwipe(BuildContext context) async {
    if (showBackwardGif == false) {
      showBackwardGif = !showBackwardGif;
      updateState();
    }
    final bool shouldFollow = await state.showConfirmationDialog(context, "are you sure you want to remove this potential match?");
    showBackwardGif = false;
    updateState();
    if (shouldFollow) {
      final LikedUser likedUser = LikedUser(
        userId: userProfile!.userId ?? '',
        isLiked: false,
      );
      await state.partnerImagesController?.userRepository.addUserToLikedList('likedUser', likedUser);
      if(userProfile?.fcmToken != null) SendNotificationService.instance.sendNotification(fcmToken: userProfile?.fcmToken ?? '', senderMessage: '${currentUserData?.fullName} liked your profile', senderName: userProfile?.fullName ?? '');
      RouteHelper.instance.gotoDashboard();
      updateState();
    }
    videoController?.pause();
  }

  Future<void> onPositiveSwipe(BuildContext context) async {
    if (showForwardGif == false) {
      showForwardGif = !showForwardGif;
      updateState();
    }
    final bool shouldFollow = await state.showConfirmationDialog(context, "are you sure you want more information on this person?");
    showForwardGif = false;
    updateState();
    if (shouldFollow) {
      final LikedUser likedUser = LikedUser(
        userId: userProfile!.userId ?? '',
        isLiked: true,
      );
      await state.partnerImagesController?.userRepository.addUserToLikedList('likedUser', likedUser);
      RouteHelper.instance.gotoPartnerProfile(currentUser: userProfile);
      updateState();
    }
    videoController?.pause();
  }

  void playVideo() {
    videoController?.play();
    updateState();
  }

  void pauseVideo() {
    videoController?.pause();
    updateState();
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
}

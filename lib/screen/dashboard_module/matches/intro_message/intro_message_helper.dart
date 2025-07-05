import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/screen/dashboard_module/matches/intro_message/intro_message_screen.dart';

class IntroMessageHelper {
  IntroMessageScreenState state;
  TextEditingController introMessageController = TextEditingController();
  String introMessageError = '';
  String? userid;
  String? roomId;

  IntroMessageHelper(this.state) {
    Future.delayed(const Duration(milliseconds: 100), () async => await getProfile());
  }

  Future<void> getProfile() async {
    userid = Get.arguments;
    state.introMessageController?.userRepository.updateIntroMessageStatus(userid ?? '', true);
    roomId = await state.introMessageController!.cheatingRepository.findExistingRoom(userid);
    "Current roomId --> $roomId".logs();
    "userid --> $userid".logs();
  }

  void updateState() => state.introMessageController?.update();

  void validateIntroMessage() {
    if (introMessageController.text.isEmpty) {
      introMessageError = 'Please enter your intro message';
    } else {
      introMessageError = '';
    }
    if (introMessageError.isEmpty) {
      navigateToNextScreen();
    }
    updateState();
  }

  Future<void> navigateToNextScreen() async => RouteHelper.instance.gotoChat(introMessage: introMessageController.text, isfollowBack: roomId != null);
}

import 'dart:async';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/screen/onboarding/onboarding_screen.dart';

class OnBoardingScreenHelper {
  OnboardingScreenState state;
  CarouselSliderController carouselController = CarouselSliderController();
  int currentPage = 0;
  Timer? autoSlideTimer;

  final List<Map<String, String>> onboardingData = [
    {
      'image': AppAsset.firstOnboarding,
      'title': StringConstant.welcomeToLoveStory,
      'description': StringConstant.onboardingFirst,
    },
    {
      'image': AppAsset.secondOnboarding,
      'title': StringConstant.aRealLoveStoryMarriage,
      'description': StringConstant.onboardingSecond,
    },
  ];

  OnBoardingScreenHelper(this.state);

  void updateState() => state.onboardingController?.update();

  void manageCurrentPage(int value) {
    currentPage = value;
    updateState();
  }
}

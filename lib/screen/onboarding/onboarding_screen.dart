import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/onboarding_controller.dart';
import 'package:love_story_unicorn/screen/onboarding/onboarding_helper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  OnBoardingScreenHelper? onboardingScreenHelper;
  OnboardingController? onboardingController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    onboardingScreenHelper ??= OnBoardingScreenHelper(this);
    return GetBuilder(
      init: OnboardingController(),
      builder: (OnboardingController controller) {
        onboardingController = controller;
        return Scaffold(
          body: AppBackground(
            showBack: false,
            child: Column(
              children: [
                Expanded(
                  child: CarouselSlider(
                    items: List.generate(
                      onboardingScreenHelper?.onboardingData.length ?? 0,
                      (index) => buildOnboardingPage(index),
                    ),
                    carouselController: onboardingScreenHelper?.carouselController,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.7,
                      autoPlayInterval: const Duration(seconds: 3),
                      onPageChanged: (index, reason) => onboardingScreenHelper?.manageCurrentPage(index),
                      viewportFraction: 1.0,
                      enableInfiniteScroll: false,
                    ),
                  ),
                ),
                buildPageIndicator(),
                const SizedBox(height: Dimens.heightSmallMedium),
                AppButton(
                  title: StringConstant.createAccount,
                  color: AppColorConstant.appWhite,
                  fontColor: AppColorConstant.appBlack,
                  margin: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraSemiLarge),
                  onTap: () => RouteHelper.instance.goToSignUp(),
                ),
                const SizedBox(height: Dimens.heightNormal),
                buildLoginText(),
                const SizedBox(height: Dimens.heightMedium),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildLoginText() {
    return InkWell(
      onTap: () => RouteHelper.instance.goToSignIn(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            StringConstant.alreadyHaveAccount.tr.toLowerCase(),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColorConstant.appWhite,
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: Dimens.widthSmall),
          const InkWell(
            child: AppText(
              StringConstant.signIn,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColorConstant.appWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOnboardingPage(int index) {
    final Map<String, String>? data = onboardingScreenHelper?.onboardingData[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraSemiLarge),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(index == 2 ? 15 : 0),
            child: AppImageAsset(
              image: data?['image'] ?? '',
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: Dimens.heightSmallMedium),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
            child: AppText(
              data?['title'] ?? '',
              fontWeight: FontWeight.w800,
              fontSize: Dimens.textSizeVeryLarge,
              color: AppColorConstant.appWhite,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimens.heightNormal),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
            child: AppText(
              data?['description'] ?? '',
              fontWeight: FontWeight.w400,
              color: AppColorConstant.appWhite,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingScreenHelper?.onboardingData.length ?? 0,
        (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: onboardingScreenHelper?.currentPage == index ? AppColorConstant.appWhite : AppColorConstant.appBlack.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
            ),
          );
        },
      ),
    );
  }
}

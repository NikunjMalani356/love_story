import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/app/widgets/app_shimmer.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/dashboard_controller.dart';
import 'package:love_story_unicorn/controller/swipe_controller.dart';
import 'package:love_story_unicorn/screen/dashboard_module/swipe/swipe_helper.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:video_player/video_player.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => SwipeScreenState();
}

class SwipeScreenState extends State<SwipeScreen> {
  SwipeHelper? swipeHelper;
  SwipeController? swipeController;
  DashboardController? dashboardController;

  @override
  void dispose() {
    swipeHelper?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    swipeHelper ??= SwipeHelper(this);
    try {
      dashboardController ??= Get.find<DashboardController>();
    } catch (e) {
      'DashboardController not found: $e'.logs();
    }
    return GetBuilder(
      init: SwipeController(),
      builder: (SwipeController controller) {
        swipeController = controller;
        return Scaffold(
          body: AppBackground(
            showSuffixIcon: true,
            titleColor: AppColorConstant.appWhite,
            titleText: StringConstant.match,
            onSuffixTap: () => RouteHelper.instance.gotoFilter(),
            onTapShowBack: () {
              swipeHelper?.videoController?.pause();
              dashboardController?.updateCurrentIndex(1);
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(child: buildSwipeCardView()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DimensPadding.paddingExtraLargeX,
                        vertical: DimensPadding.paddingSmallMedium,
                      ),
                      child: swipeHelper?.swipedCount != 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => swipeHelper?.onNegativeSwipe(context),
                                    child: AppImageAsset(image: swipeHelper?.showBackwardGif == false ? AppAsset.showBackwardGif : AppAsset.backwardCard),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => swipeHelper?.onPositiveSwipe(context),
                                    child: AppImageAsset(image: swipeHelper?.showForwardGif == false ? AppAsset.showForwardGif : AppAsset.forwardCard),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ),
                  ],
                ),
                if (swipeHelper?.isLoading ?? false) const AppLoader(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> showConfirmationDialog(BuildContext context, String message) async {
    bool result = false;

    await Get.dialog<bool>(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(StringConstant.confirmation, fontSize: Dimens.textSizeVeryLarge, fontWeight: FontWeight.w700),
            const SizedBox(height: Dimens.heightSmall),
            AppText(message, fontSize: Dimens.size20, textAlign: TextAlign.center),
            const SizedBox(height: Dimens.heightSmallMedium),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    title: StringConstant.cancel,
                    onTap: () {
                      result = false;
                      Get.back(result: result);
                    },
                  ),
                ),
                const SizedBox(width: Dimens.heightSmall),
                Expanded(
                  child: AppButton(
                    title: StringConstant.yes,
                    onTap: () {
                      result = true;
                      Get.back(result: result);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return result;
  }

  Widget buildSwipeCardView() {
    if (swipeHelper?.swipedCount == 0 && swipeHelper?.isLoading == false) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImageAsset(
              image: AppAsset.signUpUnicorn,
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            const AppText(
              StringConstant.noMoreUsers,
              fontSize: Dimens.textSizeSemiLarge,
              color: AppColorConstant.appWhite,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      );
    }

    return (swipeHelper?.swipedCount != 0)
        ? Padding(
            padding: const EdgeInsets.only(top: DimensPadding.paddingFromBackArrow + 20),
            child: SwipableStack(
              itemCount: swipeHelper?.allUsers?.length ?? 0,
              controller: swipeHelper?.swipeStackController,
              detectableSwipeDirections: const {SwipeDirection.right, SwipeDirection.left},
              onSwipeCompleted: (index, direction) => swipeHelper?.onSwipeCompleted(index, direction),
              builder: (context, swipeProperty) {
                final user = swipeHelper?.allUsers?[swipeProperty.index];
                final carouselItems = [
                  AppImageAsset(
                    image: user?.headShotImage ?? AppAsset.thirdOnbording,
                    fit: BoxFit.cover,
                  ),
                  AppImageAsset(
                    image: user?.fullBodyImage ?? AppAsset.thirdOnbording,
                    fit: BoxFit.cover,
                  ),
                  if (user?.introductionVideo != null) ...[
                    if (swipeHelper!.videoController != null && swipeHelper!.videoController!.value.isInitialized) ColoredBox(color: AppColorConstant.appBlack, child: buildVideoView()) else const AppShimmerEffectView(),
                  ],
                ];

                return GestureDetector(
                  onTap: () {
                    final currentIndex = swipeHelper?.swipeStackController.currentIndex;
                    if (currentIndex != null) {
                      swipeHelper?.videoController?.pause();
                      RouteHelper.instance.gotoPartnerProfile(currentUser: swipeHelper!.allUsers?[currentIndex]);
                    }
                  },
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.85,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                                    child: PageView.builder(
                                      controller: swipeHelper?.pageControllers[swipeProperty.index],
                                      itemCount: carouselItems.length,
                                      onPageChanged: (index) {
                                        swipeHelper?.onPageChanged(index, user);
                                        swipeHelper?.updateState();
                                      },
                                      itemBuilder: (context, index) {
                                        return carouselItems[index];
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            carouselItems.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: Dimens.heightExtraSmall,
                              width: Dimens.heightExtraSmall,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: swipeHelper?.currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        : const SizedBox();
  }

  Widget buildVideoView() {
    return Align(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          VideoPlayer(swipeHelper!.videoController!),
          InkWell(
            onTap: () => swipeHelper?.manageVideoPlayer(),
            child: AppImageAsset(
              image: swipeHelper!.videoController != null && swipeHelper!.videoController!.value.isPlaying ? AppAsset.icPause : AppAsset.icPlay,
              height: Dimens.heightMedium,
              width: Dimens.heightMedium,
            ),
          ),
        ],
      ),
    );
  }
}

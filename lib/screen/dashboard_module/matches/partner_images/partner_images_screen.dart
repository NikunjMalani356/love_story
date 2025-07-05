import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/app/widgets/app_shimmer.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/partner_images_controller.dart';
import 'package:love_story_unicorn/screen/dashboard_module/matches/partner_images/partner_images_helper.dart';
import 'package:video_player/video_player.dart';

class PartnerImagesScreen extends StatefulWidget {
  const PartnerImagesScreen({super.key});

  @override
  State<PartnerImagesScreen> createState() => PartnerImagesScreenState();
}

class PartnerImagesScreenState extends State<PartnerImagesScreen> {
  PartnerImagesHelper? partnerImagesHelper;
  PartnerImagesController? partnerImagesController;

  @override
  void dispose() {
    partnerImagesHelper?.disposeVideoController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    "Current screen --> $runtimeType".logs();
    partnerImagesHelper ??= PartnerImagesHelper(this);
    return GetBuilder(
      init: PartnerImagesController(),
      builder: (PartnerImagesController controller) {
        partnerImagesController = controller;
        return Scaffold(
          body: AppBackground(
            titleText: StringConstant.potentialMatches,
            titleColor: AppColorConstant.appWhite,
            child: Stack(
              children: [
                if (!(partnerImagesHelper?.isLoading ?? false))
                  Column(
                    children: [
                      const SizedBox(height: Dimens.heightLarge),
                      buildCarouselSliderView(),
                      const SizedBox(height: Dimens.heightXSmall),
                      buildProgressIndicator(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => partnerImagesHelper?.onNegativeSwipe(context),
                            child: AppImageAsset(image: partnerImagesHelper?.showBackwardGif == false ? AppAsset.showBackwardGif : AppAsset.backwardCard, height: Dimens.dragonCustomHeight),
                          ),
                          InkWell(
                            onTap: () => partnerImagesHelper?.onPositiveSwipe(context),
                            child: AppImageAsset(image: partnerImagesHelper?.showForwardGif == false ? AppAsset.showForwardGif : AppAsset.forwardCard, height: Dimens.dragonCustomHeight),
                          ),
                        ],
                      ),
                    ],
                  ),
                if (partnerImagesHelper?.isLoading == true) const AppLoader(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCarouselSliderView() {
    return Expanded(
      child: CarouselSlider(
        items: List.generate(
          3,
          (index) => Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              color: AppColorConstant.appBlack,
              border: Border.all(),
              borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: index == 2
                  ? buildIntroVideoWidget()
                  : AppImageAsset(
                      image: index == 0 ? partnerImagesHelper?.userProfile?.headShotImage ?? AppAsset.signUpUnicorn : partnerImagesHelper?.userProfile?.fullBodyImage ?? AppAsset.thirdOnbording,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        carouselController: partnerImagesHelper?.carouselController,
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height * 0.65,
          autoPlayInterval: const Duration(seconds: 5),
          onPageChanged: (index, reason) {
            partnerImagesHelper?.manageCurrentPage(index);
            partnerImagesHelper?.pauseVideo();
          },
          viewportFraction: 1.0,
        ),
      ),
    );
  }

  Widget buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: Dimens.heightExtraSmall,
          width: Dimens.heightExtraSmall,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: partnerImagesHelper?.currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
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

  Widget buildIntroVideoWidget() {
    if (partnerImagesHelper?.videoController == null || !partnerImagesHelper!.videoController!.value.isInitialized) {
      return const AppShimmerEffectView();
    }
    return Align(
      child: InkWell(
        onTap: () {
          if (partnerImagesHelper!.videoController != null || partnerImagesHelper!.videoController!.value.isPlaying) {
            partnerImagesHelper?.manageVideoPlayer();
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: partnerImagesHelper!.videoController!.value.aspectRatio,
              child: VideoPlayer(partnerImagesHelper!.videoController!),
            ),
            if (partnerImagesHelper!.isVideoPlaying != true)
              InkWell(
                onTap: () => partnerImagesHelper?.manageVideoPlayer(),
                child: const AppImageAsset(
                  image: AppAsset.icPlay,
                  height: Dimens.heightMedium,
                  width: Dimens.heightMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

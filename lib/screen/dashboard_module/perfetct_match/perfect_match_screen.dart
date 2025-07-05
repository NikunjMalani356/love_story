import 'package:flutter/material.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/screen/dashboard_module/perfetct_match/perfect_match_helper.dart';

class PerfectMatchScreen extends StatefulWidget {
  const PerfectMatchScreen({super.key});

  @override
  State<PerfectMatchScreen> createState() => PerfectMatchScreenState();
}

class PerfectMatchScreenState extends State<PerfectMatchScreen> with SingleTickerProviderStateMixin {
  PerfectMatchScreenHelper? perfectMatchScreenHelper;

  @override
  Widget build(BuildContext context) {
    "Current screen --> $runtimeType".logs();
    perfectMatchScreenHelper ??= PerfectMatchScreenHelper(this);
    return Scaffold(
      body: AppBackground(
        showBack: false,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            Expanded(child: buildImagesView()),
            const AppButton(
              color: AppColorConstant.appWhite,
              fontColor: AppColorConstant.appBlack,
              title: StringConstant.continueText,
              margin: EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLargeMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImagesView() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SlideTransition(
              position: perfectMatchScreenHelper!.rightImageAnimation!,
              child: RotationTransition(
                turns: perfectMatchScreenHelper!.rightImageRotation!,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(boxShadow: AppColorConstant.appBottomShadow),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                        child: AppImageAsset(
                          image: AppAsset.perfectMatchSecond,
                          height: MediaQuery.of(context).size.height * 0.35,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -12,
                      left: -12,
                      child: buildLikeView(),
                    ),
                  ],
                ),
              ),
            ),
            SlideTransition(
              position: perfectMatchScreenHelper!.leftImageAnimation!,
              child: RotationTransition(
                turns: perfectMatchScreenHelper!.leftImageRotation!,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(boxShadow: AppColorConstant.appBottomShadow),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                        child: AppImageAsset(
                          image: AppAsset.perfectMatchFirst,
                          height: MediaQuery.of(context).size.height * 0.35,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -12,
                      left: -12,
                      child: buildLikeView(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.12),
        buildBottomView(),
      ],
    );
  }

  Widget buildBottomView() {
    return const Column(
      children: [
        AppText(
          StringConstant.itsAMatch,
          fontSize: Dimens.textSizeSemiLarge,
          fontWeight: FontWeight.w600,
        ),
        AppText(StringConstant.startConversation),
      ],
    );
  }

  Widget buildLikeView() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(DimensPadding.paddingSmallMedium),
      child: const AppImageAsset(
        image: AppAsset.icLike,
        color: AppColorConstant.appErrorColor,
      ),
    );
  }
}

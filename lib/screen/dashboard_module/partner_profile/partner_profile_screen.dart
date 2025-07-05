import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/partner_profile_controller.dart';
import 'package:love_story_unicorn/screen/dashboard_module/partner_profile/partner_profile_helper.dart';
import 'package:video_player/video_player.dart';

class PartnerProfileScreen extends StatefulWidget {
  const PartnerProfileScreen({super.key});

  @override
  State<PartnerProfileScreen> createState() => PartnerProfileScreenState();
}

class PartnerProfileScreenState extends State<PartnerProfileScreen> {
  PartnerProfileHelper? partnerProfileHelper;
  PartnerProfileController? partnerProfileController;

  @override
  Widget build(BuildContext context) {
    "Current screen --> $runtimeType".logs();
    partnerProfileHelper ??= PartnerProfileHelper(this);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        RouteHelper.instance.gotoDashboard();
      },
      child: GetBuilder(
        init: PartnerProfileController(),
        builder: (PartnerProfileController controller) {
          partnerProfileController = controller;
          return Scaffold(
            body: Stack(
              children: [
                AppImageAsset(
                  image: AppAsset.appBackground,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                if (partnerProfileHelper?.isLoading ?? true) const AppLoader() else SafeArea(child: buildUpperView()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildUpperView() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CarouselSlider(
              carouselController: partnerProfileHelper?.carouselSliderController,
              options: CarouselOptions(
                onPageChanged: (index, reason) => partnerProfileHelper?.onPageChanged(index),
                height: MediaQuery.of(context).size.height * 0.5,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                autoPlayInterval: const Duration(seconds: 3),
              ),
              items: [
                AppImageAsset(
                  image: partnerProfileHelper?.partnerProfile?.headShotImage ?? '',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
                ColoredBox(
                  color: AppColorConstant.appWhite,
                  child: AppImageAsset(
                    image: partnerProfileHelper?.partnerProfile?.fullBodyImage ?? AppAsset.thirdOnbording,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                if (partnerProfileHelper?.videoController != null && (partnerProfileHelper?.videoController?.value.isInitialized == true)) ... [
                  ColoredBox(color: AppColorConstant.appBlack, child: buildIntroVideoWidget()),
                ],
              ],
            ),
            Positioned(
              bottom: 10,
              child: Row(
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: partnerProfileHelper?.currentPage == index ? AppColorConstant.appWhite : AppColorConstant.appWhite.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: InkWell(
                onTap: () => RouteHelper.instance.gotoDashboard(),
                child: Container(
                  padding: const EdgeInsets.all(DimensPadding.paddingSmallMedium),
                  margin: const EdgeInsets.only(left: DimensPadding.paddingMedium, top: DimensPadding.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColorConstant.appWhite,
                    borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                  ),
                  child: const AppImageAsset(image: AppAsset.icBack, height: Dimens.heightSmallMedium),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimens.heightExtraNormal),
              buildNameField(),
              const SizedBox(height: Dimens.heightExtraNormal),
              buildLocationField(),
              const SizedBox(height: Dimens.heightNormal),
              buildBasicInformation(),
              const SizedBox(height: Dimens.heightSmallMedium),
              buildQuestionsSection(),
              const SizedBox(height: Dimens.heightExtraNormal),
              if (partnerProfileHelper?.isDragonShow ?? false) buildDragonView(),
              const SizedBox(height: Dimens.heightExtraSmallMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDragonView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLargeMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: InkWell(onTap: () => partnerProfileHelper?.onNegativeSwipe(context), child: AppImageAsset(image: partnerProfileHelper?.showBackwardGif == false ? AppAsset.showBackwardGif : AppAsset.backwardCard))),
          const SizedBox(width: Dimens.heightMedium),
          Expanded(child: InkWell(onTap: () => partnerProfileHelper?.onPositiveSwipe(context), child: AppImageAsset(image: partnerProfileHelper?.showForwardGif == false ? AppAsset.showForwardGif : AppAsset.forwardCard))),
        ],
      ),
    );
  }

  Future<void> showRejectionDialog(BuildContext context, String message) async {
    await Get.dialog<bool>(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Dimens.heightSmall),
            AppText(message, fontSize: Dimens.size20, textAlign: TextAlign.center),
            const SizedBox(height: Dimens.heightSmallMedium),
            const SizedBox(width: Dimens.heightSmall),
            AppButton(
              title: StringConstant.okText,
              onTap: () {
                Get.back();
              },
            ),
          ],
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

  Widget buildBasicInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRelocatedField(),
        const SizedBox(height: Dimens.heightNormal),
        buildGenderField(),
        const SizedBox(height: Dimens.heightNormal),
        buildLookingFor(),
        const SizedBox(height: Dimens.heightNormal),
        buildChildPrefs(),
        const SizedBox(height: Dimens.heightNormal),
        buildAgeDifference(),
      ],
    );
  }

  Widget buildIntroVideoWidget() {
    return Align(
      child: InkWell(
        onTap: () {
          if (partnerProfileHelper?.videoController?.value.isPlaying == true) {
            partnerProfileHelper?.manageVideoPlayer();
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (partnerProfileHelper?.videoController != null) ...[
              AspectRatio(
                aspectRatio: partnerProfileHelper?.videoController?.value.aspectRatio ?? 1,
                child: VideoPlayer(partnerProfileHelper!.videoController!),
              ),
            ],
            if (partnerProfileHelper?.videoController?.value.isPlaying != true)
              InkWell(
                onTap: () => partnerProfileHelper?.manageVideoPlayer(),
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

  Widget buildQuestionsSection() {
    if (partnerProfileHelper?.questionAnswer == null || partnerProfileHelper?.questionAnswer['questions_and_answers'] == null) {
      return const SizedBox.shrink();
    }
    final questions = partnerProfileHelper?.questionAnswer['questions_and_answers'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          "Questions",
          fontSize: Dimens.textSizeSemiLarge,
          fontWeight: FontWeight.w700,
          color: AppColorConstant.appWhite,
        ),
        MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              if (question['answer'] == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: Dimens.heightExtraNormal),
                child: buildQuestionItem(question),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildQuestionItem(Map<String, dynamic> question) {
    final answer = question['answer'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          question['question'] ?? '',
          color: AppColorConstant.appWhite,
          fontSize: Dimens.textSizeLarge,
        ),
        const SizedBox(height: Dimens.heightTiny),
        if (answer is List)
          Wrap(
            spacing: DimensPadding.paddingSmallMedium,
            runSpacing: DimensPadding.paddingSmallMedium,
            children: answer.map((item) => buildAnswerChip(item.toString())).toList(),
          )
        else
          buildAnswerChip(answer.toString()),
      ],
    );
  }

  Widget buildAnswerChip(String answer) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingTiny, horizontal: DimensPadding.paddingMedium),
      decoration: BoxDecoration(
        color: AppColorConstant.appWhite,
        borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
      ),
      child: AppText(answer),
    );
  }

  Widget buildNameField() {
    return AppText(
      "${partnerProfileHelper?.partnerProfile?.fullName}, ${calculateAge(partnerProfileHelper?.partnerProfile?.dateOfBirth)}",
      fontSize: Dimens.textSizeSemiLarge,
      color: AppColorConstant.appWhite,
      fontWeight: FontWeight.w700,
    );
  }

  Widget buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          StringConstant.location,
          fontSize: Dimens.size20,
          fontWeight: FontWeight.w700,
          color: AppColorConstant.appWhite,
        ),
        Row(
          children: [
            if (partnerProfileHelper?.partnerProfile?.userLocation?.city != null && partnerProfileHelper?.partnerProfile?.userLocation?.city != "")
              AppText("${partnerProfileHelper?.partnerProfile?.userLocation?.city}, ", color: AppColorConstant.appWhite),
            AppText(
              "${partnerProfileHelper?.partnerProfile?.userLocation?.state}, ${partnerProfileHelper?.partnerProfile?.userLocation?.country}",
              color: AppColorConstant.appWhite,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          "Gender",
          fontSize: Dimens.size20,
          fontWeight: FontWeight.w700,
          color: AppColorConstant.appWhite,
        ),
        const SizedBox(height: Dimens.heightTiny),
        Container(
          padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingTiny, horizontal: DimensPadding.paddingMedium),
          decoration: BoxDecoration(
            color: AppColorConstant.appWhite,
            borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
          ),
          child: AppText(partnerProfileHelper?.partnerProfile?.gender ?? ''),
        ),
      ],
    );
  }

  Widget buildAgeDifference() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              "Maximum older",
              fontSize: Dimens.size20,
              fontWeight: FontWeight.w700,
              color: AppColorConstant.appWhite,
            ),
            const SizedBox(height: Dimens.heightTiny),
            Container(
              padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingTiny, horizontal: DimensPadding.paddingMedium),
              decoration: BoxDecoration(
                color: AppColorConstant.appWhite,
                borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
              ),
              child: AppText(partnerProfileHelper?.partnerProfile?.olderAge ?? ''),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              "Maximum younger",
              fontSize: Dimens.size20,
              fontWeight: FontWeight.w700,
              color: AppColorConstant.appWhite,
            ),
            const SizedBox(height: Dimens.heightTiny),
            Container(
              padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingTiny, horizontal: DimensPadding.paddingMedium),
              decoration: BoxDecoration(
                color: AppColorConstant.appWhite,
                borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
              ),
              child: AppText(partnerProfileHelper?.partnerProfile?.youngerAge ?? ''),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildRelocatedField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          "Where you relocated for Partner",
          fontSize: Dimens.size20,
          fontWeight: FontWeight.w700,
          color: AppColorConstant.appWhite,
        ),
        const SizedBox(height: Dimens.heightTiny),
        Wrap(
          spacing: DimensPadding.paddingSmallMedium,
          runSpacing: DimensPadding.paddingSmallMedium,
          children: partnerProfileHelper?.partnerProfile?.relocation?.map<Widget>((answer) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingTiny, horizontal: DimensPadding.paddingMedium),
              decoration: BoxDecoration(
                color: AppColorConstant.appWhite,
                borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
              ),
              child: AppText(answer),
            );
          }).toList() ?? [],
        ),
      ],
    );
  }

  Widget buildLookingFor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          "Interested In",
          fontSize: Dimens.size20,
          fontWeight: FontWeight.w700,
          color: AppColorConstant.appWhite,
        ),
        const SizedBox(
          height: Dimens.heightTiny,
        ),
        Wrap(
          spacing: DimensPadding.paddingSmallMedium,
          runSpacing: DimensPadding.paddingSmallMedium,
          children: partnerProfileHelper?.partnerProfile?.partnerPrefs.map<Widget>((answer) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingTiny, horizontal: DimensPadding.paddingMedium),
              decoration: BoxDecoration(
                color: AppColorConstant.appWhite,
                borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
              ),
              child: AppText(answer),
            );
          }).toList() ?? [],
        ),
      ],
    );
  }

  Widget buildChildPrefs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          "Child Preferences",
          fontSize: Dimens.size20,
          fontWeight: FontWeight.w700,
          color: AppColorConstant.appWhite,
        ),
        const SizedBox(height: Dimens.heightTiny),
        Wrap(
          spacing: DimensPadding.paddingSmallMedium,
          runSpacing: DimensPadding.paddingSmallMedium,
          children: partnerProfileHelper?.partnerProfile?.childPref?.iHave?.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(
                vertical: DimensPadding.paddingTiny,
                horizontal: DimensPadding.paddingMedium,
              ),
              decoration: BoxDecoration(
                color: AppColorConstant.appWhite,
                borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
              ),
              child: AppText(e),
            );
          }).toList() ?? [],
        ),
        const SizedBox(height: DimensPadding.paddingSmallMedium),
        Wrap(
          spacing: DimensPadding.paddingSmallMedium,
          runSpacing: DimensPadding.paddingSmallMedium,
          children: partnerProfileHelper?.partnerProfile?.childPref?.iWant?.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(
                vertical: DimensPadding.paddingTiny,
                horizontal: DimensPadding.paddingMedium,
              ),
              decoration: BoxDecoration(
                color: AppColorConstant.appWhite,
                borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
              ),
              child: AppText(e),
            );
          }).toList() ?? [],
        ),
      ],
    );
  }

  int calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 0;
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month || (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}

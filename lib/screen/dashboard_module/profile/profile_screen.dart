import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_shimmer.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/app/widgets/app_text_form_field.dart';
import 'package:love_story_unicorn/controller/profile_controller.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/field_screen/age_difference.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/field_screen/child_prefs.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/field_screen/gender_field.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/field_screen/location_field.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/field_screen/looking_for.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/field_screen/relocated_field.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/profile_screen_helper.dart';
import 'package:love_story_unicorn/serialized/question_model.dart';
import 'package:video_player/video_player.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  ProfileScreenHelper? profileScreenHelper;
  ProfileController? profileController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    profileScreenHelper ??= ProfileScreenHelper(this);
    return GetBuilder<ProfileController>(
      autoRemove: false,
      init: ProfileController(),
      builder: (ProfileController profileController) {
        this.profileController = profileController;
        return Scaffold(
          backgroundColor: AppColorConstant.appTransparent,
          body: AppBackground(
            showBack: false,
            isLoading: profileScreenHelper?.isLoading ?? true,
            child: (profileScreenHelper?.isLoading == false) ? buildUpperView() : const SizedBox(),
          ),
        );
      },
    );
  }

  Widget buildUpperView() {
    return SingleChildScrollView(
      controller: profileScreenHelper?.scrollController,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AppShimmerEffectView(height: Get.height),
                CarouselSlider(
                  carouselController: profileScreenHelper?.carouselSliderController,
                  options: CarouselOptions(
                    onPageChanged: (index, reason) => profileScreenHelper?.onPageChanged(index),
                    height: double.infinity,
                    viewportFraction: 1.0,
                    autoPlayInterval: const Duration(seconds: 3),
                  ),
                  items: [
                    AppImageAsset(cachingKey: DateTime.now().microsecondsSinceEpoch.toString(), image: profileScreenHelper?.userProfile?.headShotImage ?? '', fit: BoxFit.cover, width: MediaQuery.of(context).size.width),
                    AppImageAsset(cachingKey: DateTime.now().microsecondsSinceEpoch.toString(), image: profileScreenHelper?.userProfile?.fullBodyImage ?? '', fit: BoxFit.cover, width: MediaQuery.of(context).size.width),
                    if (profileScreenHelper?.videoController != null && profileScreenHelper!.videoController!.value.isInitialized) ColoredBox(color: AppColorConstant.appBlack, child: buildIntroVideoWidget()) else const AppShimmerEffectView(),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => Get.toNamed(RouteConstant.basicInformation, arguments: {'isEdit': true})?.then((value) async => await profileScreenHelper?.getCallCurrentUser()),
                    child: Container(
                      height: 45,
                      width: 45,
                      margin: const EdgeInsets.only(top: 10, right: 10),
                      padding: const EdgeInsets.all(DimensPadding.paddingSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
                        color: AppColorConstant.appWhite,
                      ),
                      child: const AppImageAsset(image: AppAsset.icEdit, color: AppColorConstant.appPurple),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: profileScreenHelper?.currentPage == index ? AppColorConstant.appWhite : AppColorConstant.appWhite.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
            children: [
              const SizedBox(height: Dimens.heightExtraNormal),
              buildNameField(),
              const SizedBox(height: Dimens.heightExtraNormal),
              LocationField(helper: profileScreenHelper, profileController: profileController),
              const SizedBox(height: Dimens.heightNormal),
              buildBasicInformation(),
              const SizedBox(height: Dimens.heightSmallMedium),
              buildQuestionsSection(),
            ],
          ),
          const SizedBox(height: Dimens.heightNormal),
          AppButton(
            title: 'Logout',
            onTap: () => profileScreenHelper?.manageLogout(),
            margin: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
          ),
          AppButton(
            title: 'Delete Account',
            color: AppColorConstant.appRed,
            onTap: () => profileScreenHelper?.onDeleteTap(),
            margin: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium, vertical: DimensPadding.paddingNormal),
          ),
          const SizedBox(height: Dimens.heightNormal),
          AppText('Version : ${profileScreenHelper?.appVersion}', color: AppColorConstant.appWhite),
          const SizedBox(height: Dimens.heightNormal),
        ],
      ),
    );
  }

  Widget buildNameField() {
    return AppText(
      "${profileScreenHelper?.userProfile?.fullName}, ${calculateAge(profileScreenHelper?.userProfile?.dateOfBirth)}",
      fontSize: Dimens.textSizeSemiLarge,
      color: AppColorConstant.appWhite,
      fontWeight: FontWeight.w700,
    );
  }

  Widget buildBasicInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RelocatedField(helper: profileScreenHelper,profileController: profileController),
        const SizedBox(height: Dimens.heightNormal),
        GenderField(helper: profileScreenHelper,profileController: profileController),
        const SizedBox(height: Dimens.heightNormal),
        LookingFor(helper: profileScreenHelper,profileController: profileController),
        const SizedBox(height: Dimens.heightNormal),
        ChildPrefs(helper: profileScreenHelper,profileController: profileController),
        const SizedBox(height: Dimens.heightNormal),
        AgeDifference(helper: profileScreenHelper,profileController: profileController),
      ],
    );
  }

  Widget buildQuestionsSection() {
    if (profileScreenHelper?.questionAnswer == null || profileScreenHelper?.questionAnswer['questions_and_answers'] == null) {
      return const SizedBox.shrink();
    }
    final questions = profileScreenHelper!.questions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: AppText(
                "Questions",
                fontSize: Dimens.textSizeSemiLarge,
                fontWeight: FontWeight.w700,
                color: AppColorConstant.appWhite,
              ),
            ),
            InkWell(
              onTap: () => Get.toNamed(RouteConstant.mandatoryQuestion, arguments: {'isEdit': true})?.then((value) async {
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) async => await profileScreenHelper?.init());
              }),
              child: const Icon(Icons.edit, color: AppColorConstant.appWhite),
            ),
          ],
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            if ((question.inputType == "multiSelection" && question.multiAnswer == null) ||
                (question.inputType == "text" && question.answer == null) ||
                (question.inputType == "dropdown" && question.answer == null) ||
                (question.inputType == "singleSelection" && question.answer == null)) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: Dimens.heightExtraNormal),
              child: buildQuestionItem(question, index),
            );
          },
        ),
      ],
    );
  }

  Widget buildIntroVideoWidget() {
    return Align(
      child: InkWell(
        onTap: () {
          if (profileScreenHelper!.videoController!.value.isPlaying) {
            profileScreenHelper?.manageVideoPlayer();
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            AspectRatio(aspectRatio: profileScreenHelper!.videoController!.value.aspectRatio, child: VideoPlayer(profileScreenHelper!.videoController!)),
            if (profileScreenHelper!.videoController!.value.isPlaying != true)
              InkWell(
                onTap: () => profileScreenHelper?.manageVideoPlayer(),
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

  Widget buildQuestionItem(Question question, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(question.question, color: AppColorConstant.appWhite, fontSize: Dimens.textSizeLarge),
        const SizedBox(height: Dimens.heightTiny),
        if (question.inputType == "multiSelection")
          Wrap(
            spacing: DimensPadding.paddingSmallMedium,
            runSpacing: DimensPadding.paddingSmallMedium,
            children: question.multiAnswer?.map((item) => buildAnswerChip(item)).toList() ?? [],
          )
        else if (profileScreenHelper?.isEditQuestion[index] ?? false)
          AppTextFormField(
            controller: profileScreenHelper?.answerController[index],
            errorText: profileScreenHelper?.answerError[index],
            textInputAction: TextInputAction.done,
          )
        else
          buildAnswerChip(profileScreenHelper?.answerController[index].text ?? ''),
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

  int calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 0;
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month || (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Widget buildErrorText(String? errorText) {
    return errorText == null ? const SizedBox.shrink() : AppText(errorText, color: AppColorConstant.appWhite, fontSize: Dimens.textSizeSmall);
  }
}

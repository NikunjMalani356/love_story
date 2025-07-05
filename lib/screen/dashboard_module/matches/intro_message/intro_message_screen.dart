import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/app/widgets/app_text_form_field.dart';
import 'package:love_story_unicorn/controller/dashboard_controller.dart';
import 'package:love_story_unicorn/controller/intro_message_controller.dart';
import 'package:love_story_unicorn/screen/dashboard_module/matches/intro_message/intro_message_helper.dart';

class IntroMessageScreen extends StatefulWidget {
  const IntroMessageScreen({super.key});

  @override
  State<IntroMessageScreen> createState() => IntroMessageScreenState();
}

class IntroMessageScreenState extends State<IntroMessageScreen> {
  IntroMessageHelper? introMessageHelper;
  DashboardController? dashboardController;
  IntroMessageController? introMessageController;

  @override
  Widget build(BuildContext context) {
    "Current screen --> $runtimeType".logs();
    introMessageHelper ??= IntroMessageHelper(this);
    try {
      dashboardController ??= Get.find<DashboardController>();
    } catch (e) {
      'DashboardController not found: $e'.logs();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        RouteHelper.instance.gotoDashboard();
      },
      child: GetBuilder(
        init: IntroMessageController(),
        builder: (IntroMessageController controller) {
          introMessageController = controller;
          return Scaffold(
            body: AppBackground(
              titleColor: AppColorConstant.appWhite,
              titleText: 'Intro Message',
              onTapShowBack: () => RouteHelper.instance.gotoDashboard(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraMedium),
                children: [
                  const SizedBox(height: Dimens.widthLarge),
                  const AppText(
                    'Please share why you like the person? They will only see your response after they double green dragon you back',
                    fontSize: Dimens.textSizeVeryLarge,
                    color: AppColorConstant.appWhite,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: Dimens.heightExtraSmallMedium),
                  AppTextFormField(
                    controller: introMessageHelper?.introMessageController,
                    hintText: 'Intro Message',
                    errorText: introMessageHelper?.introMessageError,
                    isMaxLines: true,
                  ),
                  AppButton(
                    title: 'Send',
                    margin: const EdgeInsets.only(top: Dimens.heightLarge),
                    onTap: () => introMessageHelper?.validateIntroMessage(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

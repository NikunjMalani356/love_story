import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/basic_information_controller.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BasicInformationController(),
      builder: (BasicInformationController controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLargeMedium),
          child: Column(
            children: [
              const SizedBox(height: Dimens.heightMedium),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(onTap: () => controller.manageLogout(), child: const Icon(Icons.logout, color: AppColorConstant.appWhite)),
              ).paddingOnly(bottom: DimensPadding.paddingSmall),
              AppText(
                ListConstant.basicDetailTitle[0],
                color: AppColorConstant.appWhite,
                fontSize: Dimens.textSizeExtraLarge,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              AppButton(
                title: StringConstant.continueText,
                onTap: () => controller.goToNextPage(),
              ),
            ],
          ),
        );
      },
    );
  }
}

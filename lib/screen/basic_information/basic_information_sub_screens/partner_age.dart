import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_drop_down.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/basic_information_controller.dart';

class PartnerAge extends StatelessWidget {
  const PartnerAge({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BasicInformationController>(
      init: BasicInformationController(),
      builder: (controller) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLargeMedium),
          children: [
            const SizedBox(height: Dimens.heightLarge),
            AppText(
              ListConstant.basicDetailTitle[1],
              color: AppColorConstant.appWhite,
              fontSize: Dimens.textSizeExtraLarge,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            const AppText(
              StringConstant.maxAgeOlder,
              color: AppColorConstant.appWhite,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            AppDropdown<String>(
              items: ListConstant.olderAges,
              selectedValue: controller.selectedOlderAge,
              hint: StringConstant.selectMaxOlder,
              errorText: controller.olderAgeError,
              onChanged: (newValue) {
                controller.selectedOlderAge = newValue ?? '0';
                controller.update();
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            const AppText(
              StringConstant.maxAgeYounger,
              color: AppColorConstant.appWhite,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            AppDropdown<String>(
              items: ListConstant.youngerAges,
              selectedValue: controller.selectedYoungerAge,
              hint: StringConstant.selectMaxYounger,
              errorText: controller.youngerAgeError,
              onChanged: (newValue) {
                controller.selectedYoungerAge = newValue ?? '0';
                controller.update();
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            AppButton(
              title: StringConstant.continueText,
              onTap: () => controller.validatePartnerAge(),
            ),
          ],
        );
      },
    );
  }
}

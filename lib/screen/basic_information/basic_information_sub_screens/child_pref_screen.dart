import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/basic_information_controller.dart';

class ChildPrefScreen extends StatelessWidget {
  const ChildPrefScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BasicInformationController(),
      builder: (BasicInformationController controller) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLargeMedium),
          children: [
            const SizedBox(height: Dimens.heightLarge),
            AppText(
              ListConstant.basicDetailTitle[4],
              color: AppColorConstant.appWhite,
              fontSize: Dimens.textSizeExtraLarge,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            const AppText(
              StringConstant.iWant,
              color: AppColorConstant.appWhite,
              fontSize: Dimens.textSizeVeryLarge,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Column(
              children: List.generate(
                ListConstant.childPreIWantList.length,
                (index) {
                  final bool isSelected = controller.selectedIWantPreference==index;//childPreIHaveList.length;
                  return AppButton(
                    suffixIcon: isSelected ? AppAsset.icCheck : null,
                    margin: const EdgeInsets.symmetric(vertical: DimensPadding.paddingSmallMedium),
                    title: ListConstant.childPreIWantList[index],
                    color: isSelected ? AppColorConstant.appBlack : AppColorConstant.appWhite,
                    fontColor: isSelected ? AppColorConstant.appWhite : AppColorConstant.appBlack,
                    padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
                    border: Border.all(color: Colors.transparent),
                    fontSize: Dimens.textSizeLarge,
                    onTap: () => controller.manageChildPref(index, 0),
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            const AppText(
              StringConstant.iHave,
              color: AppColorConstant.appWhite,
              fontSize: Dimens.textSizeVeryLarge,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Column(
              children: List.generate(
                ListConstant.childPreIHaveList.length,
                (index) {
                  final bool isSelected = controller.selectedIHavePreference==index;
                  return AppButton(
                    suffixIcon: isSelected ? AppAsset.icCheck : null,
                    margin: const EdgeInsets.symmetric(vertical: DimensPadding.paddingSmallMedium),
                    title: ListConstant.childPreIHaveList[index],
                    color: isSelected ? AppColorConstant.appBlack : AppColorConstant.appWhite,
                    fontColor: isSelected ? AppColorConstant.appWhite : AppColorConstant.appBlack,
                    padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
                    border: Border.all(color: Colors.transparent),
                    fontSize: Dimens.textSizeLarge,
                    onTap: () => controller.manageChildPref(index, 1),
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            AppButton(title: StringConstant.continueText, onTap: () => controller.validateChildPref()),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/basic_information_controller.dart';

class UserCongratulationsScreen extends StatelessWidget {
  const UserCongratulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BasicInformationController(),
      builder: (BasicInformationController controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLargeMedium),
          child: Column(
            children: [
              const SizedBox(height: Dimens.heightLarge),
              AppText(
                ListConstant.basicDetailTitle.last,
                color: AppColorConstant.appWhite,
                fontSize: Dimens.textSizeExtraLarge,
                fontWeight: FontWeight.w700,
              ),
              Expanded(
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: const [
                      SizedBox(height: Dimens.heightLarge),
                      AppText(
                        "You've earned 100 points!",
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.w700,
                        color: AppColorConstant.appWhite,
                        fontSize: Dimens.textSizeVeryLarge,
                      ),
                      SizedBox(height: Dimens.heightNormal),
                      AppText(
                        'See how your responses align with your potential matches—let the chemistry unfold!',
                        fontSize: Dimens.size20,
                        fontWeight: FontWeight.w700,
                        textAlign: TextAlign.center,
                        color: AppColorConstant.appWhite,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              AppButton(title: StringConstant.discoverYourConnection, onTap: () => controller.registerUser()),
              const SizedBox(height: Dimens.heightNormal),
            ],
          ),
        );
      },
    );
  }
}

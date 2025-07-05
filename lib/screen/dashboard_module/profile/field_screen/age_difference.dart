import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_drop_down.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/profile_controller.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/profile_screen_helper.dart';

class AgeDifference extends StatefulWidget {
  final ProfileScreenHelper? helper;
  final ProfileController? profileController;

  const AgeDifference({super.key, this.helper, this.profileController});

  @override
  State<AgeDifference> createState() => AgeDifferenceState();
}

class AgeDifferenceState extends State<AgeDifference> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText("Age Difference", fontSize: Dimens.size20, fontWeight: FontWeight.w700, color: AppColorConstant.appWhite),
            if (widget.helper?.isAgeDiffTap == false) InkWell(onTap: () => widget.helper?.onAgeDiffTap(), child: const Icon(Icons.edit, color: AppColorConstant.appWhite)),
          ],
        ),
        const SizedBox(height: Dimens.heightTiny),
        if (widget.helper?.isAgeDiffTap == false)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText("Maximum older", fontSize: Dimens.size20, fontWeight: FontWeight.w700, color: AppColorConstant.appWhite),
                  const SizedBox(height: Dimens.heightTiny),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingTiny, horizontal: DimensPadding.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColorConstant.appWhite,
                      borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
                    ),
                    child: AppText(widget.helper?.olderAge ?? ''),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText("Maximum younger", fontSize: Dimens.size20, fontWeight: FontWeight.w700, color: AppColorConstant.appWhite),
                  const SizedBox(height: Dimens.heightTiny),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingTiny, horizontal: DimensPadding.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColorConstant.appWhite,
                      borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
                    ),
                    child: AppText(widget.helper?.youngerAge ?? ''),
                  ),
                ],
              ),
            ],
          ),
        if (widget.helper?.isAgeDiffTap == true) ...[
          const AppText(
            "Maximum older",
            fontSize: Dimens.size20,
            fontWeight: FontWeight.w700,
            color: AppColorConstant.appWhite,
          ).paddingOnly(top: Dimens.heightTiny),
          AppDropdown<String>(
            items: ListConstant.olderAges,
            selectedValue: widget.helper?.olderAge,
            hint: StringConstant.selectMaxOlder,
            onChanged: (newValue) => widget.helper?.onChangedOlder(newValue),
          ).paddingOnly(top: Dimens.heightTiny),
          const AppText(
            "Maximum younger",
            fontSize: Dimens.size20,
            fontWeight: FontWeight.w700,
            color: AppColorConstant.appWhite,
          ).paddingOnly(top: Dimens.heightTiny),
          AppDropdown<String>(
            items: ListConstant.youngerAges,
            selectedValue: widget.helper?.youngerAge,
            hint: StringConstant.selectMaxYounger,
            onChanged: (newValue) => widget.helper?.onChangedYounger(newValue),
          ),
          const SizedBox(height: Dimens.heightTiny),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              width: Dimens.widthLarge,
              height: Dimens.heightMedium,
              title: StringConstant.save,
              onTap: () => widget.helper?.manageAge(),
            ),
          ).paddingOnly(top: Dimens.heightTiny),
        ],
      ],
    );
  }

  Widget buildErrorText(String? errorText) {
    return errorText == null ? const SizedBox.shrink() : AppText(errorText, color: AppColorConstant.appWhite, fontSize: Dimens.textSizeSmall);
  }
}

import 'package:flutter/material.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_drop_down.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/profile_controller.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/profile_screen_helper.dart';

class GenderField extends StatefulWidget {
  final ProfileScreenHelper? helper;
  final ProfileController? profileController;

  const GenderField({super.key, this.helper, this.profileController});

  @override
  State<GenderField> createState() => GenderFieldState();
}

class GenderFieldState extends State<GenderField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              "Gender",
              fontSize: Dimens.size20,
              fontWeight: FontWeight.w700,
              color: AppColorConstant.appWhite,
            ),
            if (widget.helper?.isGender == false) InkWell(onTap: () => widget.helper?.onGenderTap(), child: const Icon(Icons.edit, color: AppColorConstant.appWhite)),
          ],
        ),
        const SizedBox(height: Dimens.heightTiny),
        if (widget.helper?.isGender == true)
          Column(
            children: [
              AppDropdown<String>(
                items: ListConstant.genderList,
                selectedValue: widget.helper?.gender,
                hint: StringConstant.selectGender,
                onChanged: (newValue) => widget.helper?.onChangedGender(newValue),
              ),
              buildErrorText(widget.helper?.genderError),
              const SizedBox(height: Dimens.heightTiny),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  width: Dimens.widthLarge,
                  height: Dimens.heightMedium,
                  title: StringConstant.save,
                  onTap: () => widget.helper?.manageGender(),
                ),
              ),
            ],
          ),
        if (widget.helper?.isGender == false)
          Container(
            padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingTiny, horizontal: DimensPadding.paddingMedium),
            decoration: BoxDecoration(
              color: AppColorConstant.appWhite,
              borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
            ),
            child: AppText(widget.helper?.gender ?? ''),
          ),
      ],
    );
  }

  Widget buildErrorText(String? errorText) {
    return errorText == null ? const SizedBox.shrink() : AppText(errorText, color: AppColorConstant.appWhite, fontSize: Dimens.textSizeSmall);
  }
}

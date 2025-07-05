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

class ChildPrefs extends StatefulWidget {
  final ProfileScreenHelper? helper;
  final ProfileController? profileController;

  const ChildPrefs({super.key, this.helper, this.profileController});

  @override
  State<ChildPrefs> createState() => ChildPrefsState();
}

class ChildPrefsState extends State<ChildPrefs> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(),
        const SizedBox(height: Dimens.heightTiny),
        if (widget.helper?.isChildPrefTap == true) buildEditableChildPreferences() else buildStaticChildPreferences(),
      ],
    );
  }

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const AppText(
          "Child Preferences",
          fontSize: Dimens.size20,
          fontWeight: FontWeight.w700,
          color: AppColorConstant.appWhite,
        ),
        if (widget.helper?.isChildPrefTap == false) InkWell(onTap: () => widget.helper?.onChildPrefTap(), child: const Icon(Icons.edit, color: AppColorConstant.appWhite)),
      ],
    );
  }

  Widget buildEditableChildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDropdown(
          items: ListConstant.childPreIHaveList,
          selectedValue: widget.helper?.iHave.first,
          hint: 'Select i have',
          onChanged: widget.helper?.onChangedIHave,
          errorText: widget.helper?.iHaveError,
        ),
        const SizedBox(height: Dimens.heightTiny),
        buildDropdown(
          items: ListConstant.childPreIWantList,
          selectedValue: widget.helper?.iWant.first,
          hint: 'Select i want',
          onChanged: widget.helper?.onChangedIWant,
          errorText: widget.helper?.iWantError,
        ),
        const SizedBox(height: Dimens.heightTiny),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            width: Dimens.widthLarge,
            height: Dimens.heightMedium,
            title: StringConstant.save,
            onTap: () => widget.helper?.manageChildPref(),
          ),
        ),
      ],
    );
  }

  Widget buildStaticChildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildPreferenceWrap(widget.helper?.iHave ?? []),
        const SizedBox(height: DimensPadding.paddingSmallMedium),
        buildPreferenceWrap(widget.helper?.iWant ?? []),
      ],
    );
  }

  Widget buildDropdown({required List<String> items, String? selectedValue, required String hint, required ValueChanged<String?>? onChanged, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdown<String>(
          items: items,
          selectedValue: selectedValue,
          hint: hint,
          onChanged: onChanged,
        ).paddingOnly(top: Dimens.heightTiny),
        buildErrorText(errorText),
      ],
    );
  }

  Widget buildPreferenceWrap(List<String> preferences) {
    return Wrap(
      spacing: DimensPadding.paddingSmallMedium,
      runSpacing: DimensPadding.paddingSmallMedium,
      children: preferences.map((preference) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingTiny, horizontal: DimensPadding.paddingMedium),
          decoration: BoxDecoration(
            color: AppColorConstant.appWhite,
            borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
          ),
          child: AppText(preference),
        );
      }).toList(),
    );
  }

  Widget buildErrorText(String? errorText) {
    return errorText == null ? const SizedBox.shrink() : AppText(errorText, color: AppColorConstant.appWhite, fontSize: Dimens.textSizeSmall);
  }
}

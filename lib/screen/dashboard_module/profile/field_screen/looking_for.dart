import 'package:flutter/material.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/app/widgets/custom_dropdown_button.dart';
import 'package:love_story_unicorn/controller/profile_controller.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/profile_screen_helper.dart';

class LookingFor extends StatefulWidget {
  final ProfileScreenHelper? helper;
  final ProfileController? profileController;

  const LookingFor({super.key, this.helper, this.profileController});

  @override
  State<LookingFor> createState() => LookingForState();
}

class LookingForState extends State<LookingFor> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              "Interested In",
              fontSize: Dimens.size20,
              fontWeight: FontWeight.w700,
              color: AppColorConstant.appWhite,
            ),
            if (widget.helper?.isPartnerPrefsTap == false) InkWell(onTap: () => widget.helper?.onPartnerPrefsTap(), child: const Icon(Icons.edit, color: AppColorConstant.appWhite)),
          ],
        ),
        const SizedBox(height: Dimens.heightTiny),
        if (widget.helper?.isPartnerPrefsTap == true)
          Column(
            children: [
              CustomDropdownButton(
                items: ListConstant.genderList,
                selectedItems: widget.helper?.partnerPrefs ?? [],
                onItemSelected: (item) => setState(() {}),
                hintText: widget.helper?.partnerPrefs.join(", ") ?? "Select interested in",
                fontSize: Dimens.textSizeMedium,
              ),
              buildErrorText(widget.helper?.partnerPrefsError),
              const SizedBox(height: Dimens.heightTiny),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  width: Dimens.widthLarge,
                  height: Dimens.heightMedium,
                  title: StringConstant.save,
                  onTap: () => widget.helper?.managePartnerPrefs(),
                ),
              ),
            ],
          ),
        if (widget.helper?.isPartnerPrefsTap == false)
          Wrap(
            spacing: DimensPadding.paddingSmallMedium,
            runSpacing: DimensPadding.paddingSmallMedium,
            children: widget.helper?.partnerPrefs.map<Widget>(
                  (answer) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingTiny, horizontal: DimensPadding.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppColorConstant.appWhite,
                        borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
                      ),
                      child: AppText(answer),
                    );
                  },
                ).toList() ??
                [],
          ),
      ],
    );
  }

  Widget buildErrorText(String? errorText) {
    return errorText == null ? const SizedBox.shrink() : AppText(errorText, color: AppColorConstant.appWhite, fontSize: Dimens.textSizeSmall);
  }
}

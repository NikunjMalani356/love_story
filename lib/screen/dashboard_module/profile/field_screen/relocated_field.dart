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

class RelocatedField extends StatefulWidget {
  final ProfileScreenHelper? helper;
  final ProfileController? profileController;

  const RelocatedField({super.key, this.helper, this.profileController});

  @override
  State<RelocatedField> createState() => RelocatedFieldState();
}

class RelocatedFieldState extends State<RelocatedField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: AppText(
                "where you'd relocate for a partner?",
                fontSize: Dimens.size20,
                fontWeight: FontWeight.w700,
                color: AppColorConstant.appWhite,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.helper?.isRelocationTap == false) InkWell(onTap: () => widget.helper?.onRelocationTap(), child: const Icon(Icons.edit, color: AppColorConstant.appWhite)),
          ],
        ),
        const SizedBox(height: Dimens.heightTiny),
        if (widget.helper?.isRelocationTap == true)
          Column(
            children: [
              AppDropdown<String>(
                items: ListConstant.relocationList,
                selectedValue: widget.helper?.relocationList.first,
                hint: StringConstant.selectRelocation,
                onChanged: (newValue) => widget.helper?.onChangedRelocation(newValue),
              ),
              buildErrorText(widget.helper?.relocationError),
              const SizedBox(height: Dimens.heightTiny),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  width: Dimens.widthLarge,
                  height: Dimens.heightMedium,
                  title: StringConstant.save,
                  onTap: () => widget.helper?.manageRelocation(),
                ),
              ),
            ],
          ),
        if (widget.helper?.isRelocationTap == false && widget.helper?.relocationList.isEmpty == false)
          Container(
            padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingTiny, horizontal: DimensPadding.paddingMedium),
            decoration: BoxDecoration(
              color: AppColorConstant.appWhite,
              borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
            ),
            child: AppText(widget.helper?.relocationList.first ?? ''),
          ),
      ],
    );
  }

  Widget buildErrorText(String? errorText) {
    return errorText == null ? const SizedBox.shrink() : AppText(errorText, color: AppColorConstant.appWhite, fontSize: Dimens.textSizeSmall);
  }
}

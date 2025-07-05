import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';

class AppDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedValue;
  final String hint;
  final ValueChanged<T?>? onChanged;
  final String? errorText;

  const AppDropdown({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.hint,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: Dimens.heightLarge,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColorConstant.appWhite,
            borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
          ),
          child: DropdownButton2<T>(
            isExpanded: true,
            value: selectedValue,
            iconStyleData: const IconStyleData(
              icon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.keyboard_arrow_down),
              ),
            ),
            hint: Padding(
              padding: const EdgeInsets.only(left: DimensPadding.paddingSmallNormal),
              child: Text(hint, style: const TextStyle(color: AppColorConstant.appGrey)),
            ),
            underline: const SizedBox(),
            items: items.map((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingSmallNormal),
                  child: AppText(value.toString().toLowerCase(),height: 1),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
        if (errorText != null && (errorText?.isNotEmpty == true))
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: AppText(
              errorText ?? '',
              color: AppColorConstant.appWhite,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}

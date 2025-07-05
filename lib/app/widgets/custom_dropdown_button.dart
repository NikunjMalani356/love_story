import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';

class CustomDropdownButton extends StatelessWidget {
  final List<String>? items;
  final List<String>? selectedItems;
  final Function(String)? onItemSelected;
  final String? hintText;
  final double fontSize;

  const CustomDropdownButton({
    super.key,
    this.items,
    this.selectedItems,
    this.onItemSelected,
    this.hintText,
    this.fontSize = Dimens.textSizeRegular,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: AppText(hintText ?? '', fontSize: fontSize),
        items: items?.map((item) {
          return DropdownMenuItem(
            value: item,
            enabled: false,
            child: StatefulBuilder(
              builder: (context, menuSetState) {
                final bool isSelected = selectedItems?.contains(item) ?? false;
                return InkWell(
                  onTap: () {
                    if (isSelected) {
                      selectedItems?.remove(item);
                    } else {
                      selectedItems?.add(item);
                    }
                    onItemSelected!(item);
                    menuSetState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingSmallNormal, horizontal: DimensPadding.paddingMedium),
                    child: Row(
                      children: [
                        Icon(isSelected ? Icons.check_box_outlined : Icons.check_box_outline_blank),
                        const SizedBox(width: DimensPadding.paddingSmallNormal),
                        Expanded(child: AppText(item, fontSize: fontSize)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
        onChanged: (value) {},
        selectedItemBuilder: (context) {
          return [
            AppText(
              selectedItems?.join(', ') ?? '',
              fontSize: fontSize,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ];
        },
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
          height: Dimens.heightLarge,
          decoration: BoxDecoration(
            color: AppColorConstant.appWhite,
            borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(height: Dimens.heightMedium, padding: EdgeInsets.zero),
      ),
    );
  }
}

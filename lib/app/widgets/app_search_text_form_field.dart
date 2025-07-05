import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';

class AppSearchTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? headerText;
  final String? hintText;
  final Color? imageColor;
  final EdgeInsetsGeometry? textFormFieldPadding;
  final String? prefixIcon;
  final String? errorText;
  final bool removeContentPadding;
  final String? suffixIcon;
  final double? hintFontSize;
  final double? fieldHeight;
  final SuggestionSelectionCallback<String> onSuggestionSelected;
  final List<String> suggestionsCallback;
  final List<TextInputFormatter>? inputFormatters;
  final GestureTapCallback? onTap;
  final ValueChanged<String>? onChanged;

  const AppSearchTextFormField({
    required this.controller,
    super.key,
    this.headerText,
    this.onChanged,
    this.hintText,
    this.imageColor,
    this.textFormFieldPadding,
    this.prefixIcon,
    this.errorText,
    this.removeContentPadding = true,
    this.suffixIcon,
    this.hintFontSize,
    this.fieldHeight,
    this.onTap,
    required this.onSuggestionSelected,
    required this.suggestionsCallback, this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    'suggestionsCallback --> $suggestionsCallback'.logs();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerText != null) ...[
          AppText(
            headerText ?? '',
            color: AppColorConstant.appWhite,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        ],
        Container(
          height: Dimens.heightLarge,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColorConstant.appWhite,
            borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
          ),
          child: TypeAheadFormField<String>(
            hideOnEmpty: true,
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
              elevation: 8,
              color: AppColorConstant.appWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            onSuggestionSelected: onSuggestionSelected,
            suggestionsCallback: (pattern) {
              return suggestionsCallback.where((item) => item.toLowerCase().startsWith(pattern.toLowerCase())).toList();
            },
            itemBuilder: (BuildContext context, String itemData) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: AppText(itemData),
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) => suggestionsBox,
            textFieldConfiguration: TextFieldConfiguration(
              onTap: onTap,
              onChanged: onChanged,
              controller: controller,
              inputFormatters: inputFormatters,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                prefixIcon: prefixIcon == null
                    ? null
                    : AppImageAsset(color: imageColor ?? AppColorConstant.appLightPurple, image: prefixIcon ?? ''),
                suffixIcon: suffixIcon == null
                    ? null
                    : AppImageAsset(color: imageColor ?? AppColorConstant.appLightPurple, image: suffixIcon ?? ''),
                border: InputBorder.none,
                hintText: hintText?.tr,
                hintStyle: TextStyle(
                  overflow: TextOverflow.visible,
                  color: AppColorConstant.appLightGrey,
                  fontSize: hintFontSize ?? 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        if (errorText != null && (errorText?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: AppText(
              errorText ?? '',
              color: AppColorConstant.appWhite,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';

class AppTextFormField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final bool obscureText;
  final VoidCallback? onSuffixPressed;
  final String? errorText;
  final double? borderWidth;
  final String? initialValue;
  final String? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool? enableInteractiveSelection;
  final bool autofocus;
  final bool? isMaxLines;
  final bool readOnly;
  final TextInputAction? textInputAction;


  const AppTextFormField({
    super.key,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.borderWidth,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.onSuffixPressed,
    this.borderColor,
    this.enableInteractiveSelection,
    this.backgroundColor,
    this.errorText,
    this.initialValue,
    this.inputFormatters,
    this.suffixIcon,
    this.isMaxLines = false,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:backgroundColor ?? AppColorConstant.appWhite,
            borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
            border: Border.all(color: borderColor ?? AppColorConstant.appTransparent, width:borderWidth??  2),
          ),
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            readOnly: readOnly,
            obscureText: obscureText,
            autofocus: autofocus,
            textInputAction: textInputAction??TextInputAction.done,
            maxLines: isMaxLines == true ? 5 : 1,
            minLines: 1,
            selectionControls: enableInteractiveSelection == false
                ? DesktopTextSelectionControls()
                : MaterialTextSelectionControls(),
            decoration: InputDecoration(
              hintText: hintText?.toLowerCase(),
              hintMaxLines: 1,
              hintStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColorConstant.appGrey),
              contentPadding: const EdgeInsets.all(DimensPadding.paddingMedium),
              border: InputBorder.none,
              suffixIcon: onSuffixPressed != null
                  ? IconButton(
                      onPressed: onSuffixPressed,
                      icon: suffixIcon != null ? AppImageAsset(image: suffixIcon!, color: AppColorConstant.appGrey, height: Dimens.heightExtraSmallMedium) : Icon(obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: AppColorConstant.appGrey),
                    )
                  : null,
            ),
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

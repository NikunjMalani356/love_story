import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';

class AppText extends StatelessWidget {
  final String title;
  final Color color;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final double fontSize;
  final TextAlign? textAlign;
  final double? height;
  final FontStyle? fontStyle;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextDecoration decoration;
  final double? letterSpacing;
  final double leftSpacing;

  const AppText(
    this.title, {
    super.key,
    this.color = AppColorConstant.appBlack,
    this.fontWeight,
    this.fontFamily,
    this.fontSize = 16,
    this.textAlign,
    this.height,
    this.fontStyle,
    this.maxLines,
    this.overflow,
    this.decoration = TextDecoration.none,
    this.letterSpacing,
    this.leftSpacing = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftSpacing),
      child: Text(
        title.tr.toLowerCase(),
        textAlign: textAlign,
        maxLines: maxLines,
        style: TextStyle(
          color: color,
          fontWeight: fontWeight,
          fontSize: fontSize,
          height: height,
          fontStyle: fontStyle,
          fontFamily: fontFamily,
          overflow: overflow,
          decoration: decoration,
          decorationColor: AppColorConstant.appGrey.withOpacity(0.5),
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}

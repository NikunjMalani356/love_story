import 'package:flutter/material.dart';

class AppColorConstant {
  static const Color appTransparent = Color(0x00000000);
  static const Color appWhite = Color(0xffFFFFFF);
  static const Color appBlack = Color(0xFF000000);
  static const Color appLightGrey = Color(0xFFD9D9D9);
  static const Color appWhite200 = Color(0xffF2F2F2);
  static const Color appWhite100 = Color(0xFFFCFAFF);
  static const Color appLightPurple = Color(0xFF5f6ffa);
  static const Color appPurple = Color(0xff9b6be6);
  static const Color appErrorColor = Color(0xffff0000);
  static const Color appGreenColor = Color(0xffadffad);
  static const Color appDarkGrey = Color(0xff666666);
  static const Color appRadiumGreen = Color(0xff94FF79);
  static const Color appGrey = Color(0xff8B8B8B);
  static const Color appPink = Color(0xffe467cd);
  static const Color appCustomRed = Color(0x12E94057);
  static const Color appRed = Color(0xffF88379);
  static const Color appExtraLightGrey = Color(0xffadafbb);


  static Color hex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static List<BoxShadow> appBoxShadow = [
    BoxShadow(
      offset: const Offset(0, -6),
      spreadRadius: 0.2,
      color: appBlack.withOpacity(0.2),
      blurRadius: 2,
    ),
  ];
  static List<BoxShadow> appBottomShadow = [
    BoxShadow(
      color: AppColorConstant.appBlack.withOpacity(0.2),
      spreadRadius: 8,
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];


}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:toastification/toastification.dart';

extension AppToast on String {
  void showSuccessToast() {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: RichText(
        text: TextSpan(
          text: this,
          style: TextStyle(
            fontFamily: GoogleFonts.quicksand().fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColorConstant.appDarkGrey,
          ),
        ),
      ),
      icon: const Icon(Icons.check_circle, color: Colors.green),
      autoCloseDuration: const Duration(seconds: 3),
      boxShadow: highModeShadow,
      showProgressBar: false,
    );
  }

  void showErrorToast() {
    toastification.show(
      boxShadow: highModeShadow,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: RichText(
        text: TextSpan(
          text: this,
          style: TextStyle(
            fontFamily: GoogleFonts.quicksand().fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColorConstant.appDarkGrey,
          ),
        ),
      ),
      icon: const Icon(Icons.cancel_rounded, color: Colors.red),
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12.0),
      showProgressBar: false,
    );
  }
  void showInfoToast() {
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      title: RichText(
        text: TextSpan(
          text: this,
          style: TextStyle(
            fontFamily: GoogleFonts.quicksand().fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColorConstant.appDarkGrey,
          ),
        ),
      ),
      icon: const Icon(Icons.info, color: Colors.blue),
      autoCloseDuration: const Duration(seconds: 3),
      boxShadow: highModeShadow,
      borderRadius: BorderRadius.circular(12.0),
      showProgressBar: false,
    );
  }
}

import 'package:flutter/material.dart';

class ValidationUtils {
  ValidationUtils._privateConstructor();

  //     ======================= Regular Expressions =======================

  static final ValidationUtils instance = ValidationUtils._privateConstructor();
  static const String passwordRegexp = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$!%*?&])(?=.*\d)[A-Za-z@#$!%*?&\d]{8,}$';
  static const String userNameRegexp = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String emailRegexp = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z.-]+\.[a-zA-Z]{2,}$';
  static const String nameRegexp = r"^[A-Za-z]+$";
  static const String fullNameRegexp = r'^[a-zA-Z\s]+$';

  // ======================= Validation Methods =======================
  static bool validateEmptyController(TextEditingController textEditingController) {
    return textEditingController.text.trim().isEmpty;
  }

  static bool lengthValidator(TextEditingController textEditingController, int length) {
    return textEditingController.text.trim().length < length;
  }

  static bool compareValidator(TextEditingController textEditingController, TextEditingController secondController) {
    return textEditingController.text != secondController.text;
  }

  static bool regexValidator(String textEditingController, String regex) {
    return RegExp(regex).hasMatch(textEditingController);
  }

  bool checkForAudio(String message) => message.contains('audioFile.m4a') || message.contains('audioFile.mp3');
}

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/screen/authentication/forgot_password/forgot_password.dart';

class ForgotHelper {
  ForgotPasswordState state;
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  String emailError = '';

  ForgotHelper(this.state);

  Future<void> validateForgotForm() async {
    final String email = emailController.text.trim();
    if (email.isEmpty) {
      emailError = 'Please enter your email';
    } else if (!GetUtils.isEmail(email)) {
      emailError = 'Please enter a valid email';
    } else {
      emailError = '';
    }
    if (emailError.isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      forgotPassword();
    }
    updateState();
  }

  Future<void> forgotPassword() async {
    isLoading = true;
    updateState();
    final bool? success = await state.controller?.authRepository.sendPasswordOnEmail(emailController.text.trim());
    if (success == true) {
      Get.back();
      'A password reset link has been sent to your registered email address.'.showSuccessToast();
    } else {
      'The email address is not registered with us.'.showErrorToast();
    }
    isLoading = false;
    updateState();
  }

  void updateState() => state.controller?.update();
}

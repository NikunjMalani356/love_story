import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/screen/authentication/sign_up/sign_up_screen.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';

class SignUpScreenHelper {
  SignUpScreenState state;
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String confirmPasswordError = '';
  String emailError = '';
  String numberError = '';
  String passwordError = '';
  String? privacyPolicy;
  bool passwordObscureText = true;
  bool confirmPasswordObscureText = true;
  bool isDeclarationAccept = true;
  bool isLoading = false;

  SignUpScreenHelper(this.state) {
    Future.delayed(Duration.zero, () => policyUrl());
  }

  void updateState() => state.signUpController?.update();

  Future<void> policyUrl() async => privacyPolicy = await state.signUpController?.utillsRepository.getPolicyUrl() ?? '';

  void validateSignForm() {
    final String email = emailController.text.trim();
    final String number = numberController.text.trim();
    final String password = passwordController.text.trim();
    final String confPassword = confirmPassword.text.trim();

    if (email.isEmpty) {
      emailError = 'Please enter your email';
    } else if (!GetUtils.isEmail(email)) {
      emailError = 'Please enter a valid email';
    } else {
      emailError = '';
    }
    if (number.isEmpty) {
      numberError = 'Please enter your number';
    } else if (!GetUtils.isPhoneNumber(number)) {
      numberError = 'Please enter a valid number';
    } else {
      numberError = '';
    }
    if (password.isEmpty) {
      passwordError = 'Please enter a password.';
    } else {
      final List<String> errors = [];

      if (password.length < 8) {
        errors.add('at least 8 characters long');
      }
      if (!password.contains(RegExp('[a-z]'))) {
        errors.add('at least one lowercase letter');
      }
      if (!password.contains(RegExp('[A-Z]'))) {
        errors.add('at least one uppercase letter');
      }
      if (!password.contains(RegExp(r'\d'))) {
        errors.add('at least one digit');
      }
      if (!password.contains(RegExp(r'[@#$!%*?&]'))) {
        errors.add('at least one special character (@#\$!%*?&)');
      }
      if (errors.isNotEmpty) {
        passwordError = 'Password must contain ${errors.join(', ')}.';
      }
    }
    if (confPassword.isEmpty) {
      confirmPasswordError = 'Please enter confirm password';
    } else if (password != confPassword) {
      confirmPasswordError = 'Password does not match';
    } else {
      confirmPasswordError = '';
    }

    updateState();
    if (confirmPasswordError.isEmpty && emailError.isEmpty && passwordError.isEmpty && numberError.isEmpty) {
      if (!isDeclarationAccept) {
        'Please accept terms and conditions'.showErrorToast();
        return;
      }
      registerUser();
    }
  }

  Future<void> registerUser() async {
    try {
      isLoading = true;
      updateState();
      final User? currentUser = await state.signUpController?.authRepository.registerWithEmailAndPassword(emailController.text.trim(), passwordController.text);
      if (currentUser != null) {
        'Current user --> $currentUser'.infoLogs();
        confirmPassword.clear();
        emailController.clear();
        passwordController.clear();
        numberController.clear();
        final UserModel userModel = UserModel(
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          email: FirebaseAuth.instance.currentUser?.email ?? '',
        );

        'User model --> ${userModel.toJson()}'.infoLogs();

        final bool isUserCreated = await state.signUpController?.userRepository.createUser(userModel) ?? false;
        if (isUserCreated) {
          'User created successfully'.showSuccessToast();
          RouteHelper.instance.goToSubscription();
        }
      }
    } on SocketException catch (e) {
      'Catch SocketException in registerUser --> ${e.message}'.errorLogs();
      e.message.showErrorToast();
    } catch (e) {
      'Catch error in registerUser --> $e'.errorLogs();
    }
    isLoading = false;
    updateState();
  }

  void updatePasswordObscureText() {
    passwordObscureText = !passwordObscureText;
    updateState();
  }

  void updateConfirmPasswordObscureText() {
    confirmPasswordObscureText = !confirmPasswordObscureText;
    updateState();
  }

  void updateDeclaration() {
    isDeclarationAccept = !isDeclarationAccept;
    updateState();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/screen/authentication/sign_in/sign_in_screen.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';

class SignInScreenHelper {
  SignInScreenState state;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String emailError = '';
  String passwordError = '';
  String? privacyPolicy;
  bool passwordObscureText = true;
  bool isRememberMe = true;
  bool isLoading = false;

  SignInScreenHelper(this.state) {
    Future.delayed(Duration.zero, () => policyUrl());
  }

  void updateState() => state.authenticationController?.update();

  Future<void> policyUrl() async => privacyPolicy = await state.authenticationController?.utillsRepository.getPolicyUrl() ?? '';

  void validateSignForm() {
    if (kDebugMode && emailController.text.isEmpty) {
      // emailController.text ='sagaranghan@gmail.com';
      emailController.text = 'kajal@gmail.com';
      passwordController.text = 'Test@123';
    }
    if (emailController.text.isEmpty) {
      emailError = 'Please enter your email';
    } else if (!GetUtils.isEmail(emailController.text)) {
      emailError = 'Please enter a valid email';
    } else {
      emailError = '';
    }
    if (passwordController.text.isEmpty) {
      passwordError = 'Please enter password';
    } else {
      passwordError = '';
    }
    updateState();
    if (emailError.isEmpty && passwordError.isEmpty) {
      verifyUser();
    }
  }

  Future<void> verifyUser() async {
      isLoading = true;
      updateState();
      final User? currentUser = await state.authenticationController?.authRepository.logIn(emailController.text, passwordController.text);
      if (currentUser != null) {
        'Current user --> $currentUser'.infoLogs();
        emailController.clear();
        passwordController.clear();
        final UserModel? userModel = await state.authenticationController?.userRepository.getUserData();
        'UserModel --> ${userModel?.toJson()}'.infoLogs();
        if (userModel == null) {
          RouteHelper.instance.goToBasicInformation();
        } else {
          final bool isSubscribed = (await state.authenticationController?.userRepository.checkUserSubscription()) ?? false;
          if (isSubscribed) {
            final bool isInfoFilled = (await state.authenticationController?.userRepository.checkUserData()) ?? false;
            if (isInfoFilled) {
              final fcmToken = await FirebaseMessaging.instance.getToken();
              await state.authenticationController?.userRepository.updateUserMap('fcmToken', fcmToken);
              RouteHelper.instance.gotoDashboard();
            } else {
              RouteHelper.instance.goToBasicInformation();
            }
          } else {
            RouteHelper.instance.goToSubscription();
          }
        }
      }
    // } on SocketException catch (e) {
    //   'Catch SocketException in verifyUser --> ${e.message}'.errorLogs();
    //   e.message.showErrorToast();
    // } catch (e) {
    //   'Catch error in verifyUser --> $e'.errorLogs();
    // }
    isLoading = false;
    updateState();
  }

  void updatePasswordObscureText() {
    passwordObscureText = !passwordObscureText;
    updateState();
  }

  void updateRememberMe() {
    isRememberMe = !isRememberMe;
    updateState();
  }
}

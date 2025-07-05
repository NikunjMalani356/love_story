import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/app/widgets/app_text_form_field.dart';
import 'package:love_story_unicorn/controller/authentication_controller.dart';
import 'package:love_story_unicorn/screen/authentication/sign_in/sign_in_helper.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  SignInScreenHelper? signInScreenHelper;
  AuthenticationController? authenticationController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    signInScreenHelper ??= SignInScreenHelper(this);
    return Scaffold(body: buildBodyView());
  }

  Widget buildBodyView() {
    return GetBuilder<AuthenticationController>(
      autoRemove: false,
      init: AuthenticationController(),
      builder: (logic) {
        authenticationController = logic;
        return Stack(
          children: [
            AppBackground(
              showBack: false,
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLarge),
                  children: [
                    const AppImageAsset(image: AppAsset.signUpUnicorn, height: Dimens.heightHuge),
                    const AppText(
                      StringConstant.welcomeBack,
                      color: AppColorConstant.appWhite,
                      fontSize: Dimens.textSizeLarge,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                    const AppText(
                      StringConstant.loginAccount,
                      color: AppColorConstant.appWhite,
                      fontSize: Dimens.textSizeLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    AppTextFormField(
                      hintText: StringConstant.enterYourEmail,
                      controller: signInScreenHelper?.emailController,
                      errorText: signInScreenHelper?.emailError,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    AppTextFormField(
                      hintText: StringConstant.enterYourPassword,
                      controller: signInScreenHelper?.passwordController,
                      errorText: signInScreenHelper?.passwordError,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: signInScreenHelper?.passwordObscureText ?? true,
                      enableInteractiveSelection: false,
                      onSuffixPressed: () => signInScreenHelper?.updatePasswordObscureText(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => signInScreenHelper?.updateRememberMe(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                signInScreenHelper?.isRememberMe == true
                                    ? Icons.check_circle_outline
                                    : Icons.circle_outlined,
                                color: AppColorConstant.appWhite,
                                size: 16,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 2, bottom: 2),
                                child: AppText('Remember me', color: AppColorConstant.appWhite, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => RouteHelper.instance.goToForgot(),
                          child: const AppText('Forgot Password ?', color: AppColorConstant.appWhite, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      color: AppColorConstant.appWhite,
                      fontColor: AppColorConstant.appBlack,
                      title: StringConstant.logIn,
                      onTap: () => signInScreenHelper?.validateSignForm(),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    InkWell(
                      onTap: () => RouteHelper.instance.goToSignUp(),
                      child: const AppText(StringConstant.continueWithEmail, fontSize: Dimens.textSizeMedium, textAlign: TextAlign.center),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(onTap: () => RouteHelper.instance.gotoTermCondition('terms'),child: const AppText(StringConstant.termsOfUse, fontSize: Dimens.textSizeMedium)),
                        InkWell(onTap: () => RouteHelper.instance.gotoWebView(signInScreenHelper?.privacyPolicy ?? ""), child: const AppText(StringConstant.privacyPolicy, fontSize: Dimens.textSizeMedium)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (signInScreenHelper?.isLoading ?? false) const AppLoader(),
          ],
        );
      },
    );
  }

  Widget buildLoginOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (Platform.isIOS)
          Container(
            padding: const EdgeInsets.all(DimensPadding.paddingMedium),
            decoration: BoxDecoration(
              color: AppColorConstant.appWhite,
              borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
            ),
            child: const AppImageAsset(image: AppAsset.icApple),
          ),
        Container(
          padding: const EdgeInsets.all(DimensPadding.paddingMedium),
          decoration: BoxDecoration(
            color: AppColorConstant.appWhite,
            borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
          ),
          child: const AppImageAsset(image: AppAsset.icGoogle),
        ),
        Container(
          padding: const EdgeInsets.all(DimensPadding.paddingMedium),
          decoration: BoxDecoration(
            color: AppColorConstant.appWhite,
            borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
          ),
          child: const AppImageAsset(image: AppAsset.icFacebook),
        ),
      ],
    );
  }
}

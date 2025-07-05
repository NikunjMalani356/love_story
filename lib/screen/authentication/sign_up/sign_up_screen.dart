import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
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
import 'package:love_story_unicorn/screen/authentication/sign_up/sign_up_helper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  SignUpScreenHelper? signUpScreenHelper;
  AuthenticationController? signUpController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    signUpScreenHelper ??= SignUpScreenHelper(this);
    return Scaffold(body: buildBodyView());
  }

  Widget buildBodyView() {
    return GetBuilder<AuthenticationController>(
      autoRemove: false,
      init: AuthenticationController(),
      builder: (logic) {
        signUpController = logic;
        return Stack(
          children: [
            AppBackground(
              showBack: false,
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLarge),
                      child: AppText(
                        StringConstant.createYourAccount,
                        color: AppColorConstant.appWhite,
                        fontSize: Dimens.textSizeLarge,
                        fontWeight: FontWeight.w700,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLarge),
                      child: AppTextFormField(
                        hintText: StringConstant.email,
                        controller: signUpScreenHelper?.emailController,
                        errorText: signUpScreenHelper?.emailError,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          signUpScreenHelper?.emailError = '';
                          signUpScreenHelper?.updateState();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLarge),
                      child: AppTextFormField(
                        hintText: StringConstant.number,
                        controller: signUpScreenHelper?.numberController,
                        errorText: signUpScreenHelper?.numberError,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        onChanged: (value) {
                          signUpScreenHelper?.numberError = '';
                          signUpScreenHelper?.updateState();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: DimensPadding.paddingExtraLarge, right: DimensPadding.paddingTiny),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextFormField(
                              hintText: StringConstant.enterYourPassword,
                              controller: signUpScreenHelper?.passwordController,
                              errorText: signUpScreenHelper?.passwordError,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: signUpScreenHelper?.passwordObscureText ?? true,
                              enableInteractiveSelection: false,
                              onSuffixPressed: () => signUpScreenHelper?.updatePasswordObscureText(),
                              onChanged: (value) {
                                signUpScreenHelper?.passwordError = '';
                                signUpScreenHelper?.updateState();
                              },
                            ),
                          ),
                          const SizedBox(width: Dimens.heightTiny),
                          InkWell(
                            onTap: () => showPasswordInfo(),
                            child: const Padding(
                              padding: EdgeInsets.only(top: DimensPadding.paddingExtraLargeMedium),
                              child: AppImageAsset(image: AppAsset.icInfo, color: AppColorConstant.appWhite, height: Dimens.heightExtraNormal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLarge),
                      child: AppTextFormField(
                        hintText: StringConstant.confirmPassword,
                        controller: signUpScreenHelper?.confirmPassword,
                        errorText: signUpScreenHelper?.confirmPasswordError,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: signUpScreenHelper?.confirmPasswordObscureText ?? true,
                        enableInteractiveSelection: false,
                        onSuffixPressed: () => signUpScreenHelper?.updateConfirmPasswordObscureText(),
                        onChanged: (value) {
                          signUpScreenHelper?.confirmPasswordError = '';
                          signUpScreenHelper?.updateState();
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLarge),
                      child: InkWell(
                        onTap: () => signUpScreenHelper?.updateDeclaration(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              signUpScreenHelper?.isDeclarationAccept == true ? Icons.check_circle_outline : Icons.circle_outlined,
                              color: AppColorConstant.appWhite,
                              size: 16,
                            ),
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: DimensPadding.paddingTiny, bottom: DimensPadding.paddingTiny),
                                child: AppText(StringConstant.iHereby, color: AppColorConstant.appWhite, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLarge),
                      child: AppButton(
                        color: AppColorConstant.appWhite,
                        fontColor: AppColorConstant.appBlack,
                        title: StringConstant.createAccount,
                        onTap: () => signUpScreenHelper?.validateSignForm(),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    InkWell(
                      onTap: () => RouteHelper.instance.goToSignIn(),
                      child: const AppText(StringConstant.signInOption, fontSize: Dimens.textSizeMedium, textAlign: TextAlign.center),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(onTap: () => RouteHelper.instance.gotoTermCondition('terms'),child: const AppText(StringConstant.termsOfUse, fontSize: Dimens.textSizeMedium)),
                        InkWell(onTap: () => RouteHelper.instance.gotoWebView(signUpScreenHelper?.privacyPolicy ?? ""), child: const AppText(StringConstant.privacyPolicy, fontSize: Dimens.textSizeMedium)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (signUpScreenHelper?.isLoading ?? false) const AppLoader(),
          ],
        );
      },
    );
  }

  void showPasswordInfo() {
    Get.dialog(
      AlertDialog(
        title: const AppText(
          StringConstant.passwordRequirements,
          fontSize: Dimens.textSizeVeryLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ListConstant.passwordValidationList
              .map(
                (rule) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('•'),
                    const SizedBox(width: Dimens.widthNormal),
                    Expanded(child: AppText(rule)),
                  ],
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppButton(
              title: StringConstant.okText,
              fontSize: Dimens.size20,
            ),
          ),
        ],
      ),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/app/widgets/app_text_form_field.dart';
import 'package:love_story_unicorn/controller/forgot_password_controller.dart';
import 'package:love_story_unicorn/screen/authentication/forgot_password/forgot_helper.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  ForgotHelper? helper;
  ForgotPasswordController? controller;

  @override
  Widget build(BuildContext context) {
    helper ??= ForgotHelper(this);
    return Scaffold(body: buildBodyView());
  }

  Widget buildBodyView() {
    return GetBuilder<ForgotPasswordController>(
      autoRemove: false,
      init: ForgotPasswordController(),
      builder: (logic) {
        controller = logic;
        return Stack(
          children: [
            AppBackground(
              child: Column(
                children: [
                  const AppText(
                    StringConstant.forgotPassword,
                    color: AppColorConstant.appWhite,
                    fontSize: Dimens.size20,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ).paddingSymmetric(vertical: DimensPadding.paddingExtraLarge),
                  AppTextFormField(
                    hintText: StringConstant.email,
                    controller: helper?.emailController,
                    errorText: helper?.emailError,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      helper?.emailError = '';
                      controller?.update();
                    },
                  ).paddingSymmetric(vertical: DimensPadding.paddingExtraLarge),
                  const Spacer(),
                  AppButton(
                    title: StringConstant.resetLink,
                    onTap: () => helper?.validateForgotForm(),
                  ).paddingSymmetric(vertical: DimensPadding.paddingExtraLarge),
                ],
              ).paddingSymmetric(horizontal: DimensPadding.paddingExtraLarge),
            ),
            if (helper?.isLoading ?? false) const AppLoader(),
          ],
        );
      },
    );
  }
}

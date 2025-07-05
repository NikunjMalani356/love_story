import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/app/widgets/app_text_form_field.dart';
import 'package:love_story_unicorn/controller/subscription_controller.dart';
import 'package:love_story_unicorn/screen/payment/subscription_helper.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => SubscriptionScreenState();
}

class SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionHelper? subscriptionHelper;
  SubscriptionController? subscriptionController;

  @override
  Widget build(BuildContext context) {
    subscriptionHelper ??= SubscriptionHelper(this);
    'Current screen --> $runtimeType'.logs();
    return GetBuilder(
      init: SubscriptionController(),
      builder: (SubscriptionController controller) {
        subscriptionController = controller;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              buildBodyView(),
              if (subscriptionHelper?.isLoading ?? false) const AppLoader(),
            ],
          ),
        );
      },
    );
  }

  Widget buildBodyView() {
    return AppBackground(
      showBack: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimens.heightMedium),
                  Row(
                    children: [
                      const AppText(StringConstant.subscription, color: AppColorConstant.appWhite, fontSize: Dimens.textSizeExtraLarge, fontWeight: FontWeight.w700),
                      const Spacer(),
                      InkWell(onTap: () => subscriptionHelper?.manageLogout(), child: const Icon(Icons.logout, color: AppColorConstant.appWhite)),
                    ],
                  ),
                  const SizedBox(height: Dimens.heightSmall),
                  AppText(subscriptionHelper?.subscriptionDescription ?? '', color: AppColorConstant.appWhite),
                  const SizedBox(height: Dimens.heightExtraNormal),
                  AppTextFormField(
                    hintText: 'Enter secret code',
                    borderColor: (subscriptionHelper?.isPromoCodeApplied ?? false) ? AppColorConstant.appGreenColor : AppColorConstant.appWhite,
                    onChanged: (p0) => subscriptionHelper?.manageCode(p0, context),
                  ),
                  const SizedBox(height: Dimens.heightExtraNormal),
                  ListView.separated(
                    itemCount: subscriptionHelper?.products.length ?? 0,
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => const SizedBox(height: Dimens.heightXSmall),
                    itemBuilder: (context, index) {
                      final ProductDetails? plan = subscriptionHelper?.products[0];
                      if (plan == null) return const SizedBox();

                      return InkWell(
                        onTap: () => subscriptionHelper?.selectPlan(index),
                        child: purchaseOptionCard(plan, isSelected: subscriptionHelper?.selectedPlanIndex == index),
                      );
                    },
                  ),

                ],
              ),
            ),
            AppButton(
              title: StringConstant.next,
              onTap: () async {
                if (subscriptionHelper?.products.isEmpty == true) {
                  if (Platform.isIOS) {
                    StringConstant.noPlanAvailable.showError();
                  } else {
                    await subscriptionHelper?.updatePayment();
                    RouteHelper.instance.goToBasicInformation();
                  }
                  return;
                }
                if (subscriptionHelper?.selectedPlanIndex == null) {
                  StringConstant.pleaseSelectPlan.showError();
                } else {
                  await subscriptionHelper?.buyProduct();
                }
              },
            ),
            const SizedBox(height: Dimens.heightExtraNormal),
          ],
        ),
      ),
    );
  }

  Widget purchaseOptionCard(ProductDetails plan, {required bool isSelected}) {
    return Card(
      color: isSelected ? AppColorConstant.hex("#EDE7F6FF") : AppColorConstant.appWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
        side: BorderSide(
          color: isSelected ? AppColorConstant.appLightPurple : AppColorConstant.appTransparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DimensPadding.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              plan.title,
              fontSize: Dimens.textSizeLarge,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: Dimens.heightTiny),
            AppText(
              plan.price,
              color: AppColorConstant.appLightPurple,
            ),
            const SizedBox(height: Dimens.heightSmall),
            AppText(
              plan.description,
              fontSize: Dimens.textSizeMedium,
              color: AppColorConstant.appGrey,
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/screen/payment/subscription_screen.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';
import 'package:love_story_unicorn/service/subscription_service.dart';

class SubscriptionHelper {
  SubscriptionScreenState state;
  StreamSubscription<bool>? subscriptionStatusSubscription;
  String secretCode = 'godmode';
  String? subscriptionDescription;
  bool isPromoCodeApplied = false;
  List<ProductDetails> products = [];
  bool isLoading = true;
  bool isPlanActivated = false;
  int selectedPlanIndex = 0;

  SubscriptionHelper(this.state) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      await getData();
      await getSubscriptionDescription();
      listenToSubscriptionStatus();
    });
  }
  void updateState() => state.subscriptionController?.update();

  Future<void> getSubscriptionDescription() async {
    final Map<String, dynamic>? utillsData = await state.subscriptionController?.utillsRepository.getUtillsData('urls');
    if (utillsData != null && utillsData.containsKey('subscription_description')) {
      subscriptionDescription = utillsData['subscription_description'] ?? '';
      'subscription_description --> ${utillsData['subscription_description']}'.logs();
      updateState();
    }
  }

  void listenToSubscriptionStatus() {
    subscriptionStatusSubscription = SubscriptionService.instance.subscriptionStatusStream.listen((status) {
      'status --> $status'.logs();
      if (status == true) {
        updatePayment();
        RouteHelper.instance.goToBasicInformation();
      }
    });
  }

  void manageLogout() {
    state.subscriptionController?.authRepository.signOut();
    RouteHelper.instance.offAllSignIn();
  }

  Future<void> getData() async {
    products = await SubscriptionService.instance.initialize();
    isPlanActivated = await SubscriptionService.instance.verifyPurchase();
    if (isPlanActivated) {
      RouteHelper.instance.goToBasicInformation();
    }
    isLoading = false;
    updateState();
  }

  void selectPlan(int index) {
    selectedPlanIndex = index;
    updateState();
  }

  Future<void> buyProduct() async {
    if (products.isEmpty) {
      StringConstant.pleaseSelectPlan.showErrorToast();
      return;
    }

    final selectedIndex = selectedPlanIndex;

    isLoading = true;
    updateState();
    'isPromoCodeApplied --> $isPromoCodeApplied'.logs();
    if (!isPromoCodeApplied) {
      final bool isReceiptGet = await getReceiptDataFromIos();
      'isReceiptGet --> $isReceiptGet'.infoLogs();
      if (!isReceiptGet) {
        await SubscriptionService.instance.buyProduct(products[selectedIndex]);
      }
    } else {
      await updatePayment();
      RouteHelper.instance.goToBasicInformation();
    }
    isLoading = false;
    updateState();
  }

  Future<bool> getReceiptDataFromIos() async {
    const platform = MethodChannel('platform_channel');
    try {
      final receiptData = await platform.invokeMethod('getReceiptData');
      return receiptData != null && receiptData != 'null';
    } catch (e) {
      'Catch in getReceiptDataFromIos --> $e'.errorLogs();
    }
    return false;
  }

  void dispose() => subscriptionStatusSubscription?.cancel();

  Future<void> updatePayment() async {
    final bool isEmptyAndroid = products.isEmpty && Platform.isAndroid;
    await state.subscriptionController?.userRepository.updateUserMap(
      'subscription',
      SubscriptionPlan(
        planName: isEmptyAndroid ? '' : products[selectedPlanIndex].title,
        planDescription: isEmptyAndroid ? '' : products[selectedPlanIndex].description,
        planPrice: isEmptyAndroid ? '' : products[selectedPlanIndex].price,
        planStartDate: DateTime.now().toUtc(),
        planExpiry: DateTime.now().toUtc().add(const Duration(days: 31)),
      ).toJson(),
    );
  }

  void manageCode(String p0, BuildContext context) {
    isPromoCodeApplied = secretCode == p0;
    if (isPromoCodeApplied) {
      FocusScope.of(context).unfocus();
      'Promo code applied successfully'.showSuccess();
    }
    updateState();
  }
}

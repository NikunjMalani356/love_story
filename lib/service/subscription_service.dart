import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/utills/utills_repository.dart';

class SubscriptionService {
  SubscriptionService._privateConstructor() {
    listenToPurchaseStream();
  }

  static final SubscriptionService instance = SubscriptionService._privateConstructor();

  UtillsRepository utillsRepository = getIt<UtillsRepository>();
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  final List<PurchaseDetails> purchases = [];
  bool isPlanActivated = false;
  final subscriptionStatusController = StreamController<bool>.broadcast();

  Stream<bool> get subscriptionStatusStream => subscriptionStatusController.stream;

  Future<List<ProductDetails>> initialize() async {
    final Map<String, dynamic>? utillsData = await utillsRepository.getUtillsData('membership');
    if (utillsData != null && utillsData.containsKey('planIds')) {
      'utillsData --> $utillsData'.logs();
      final Set<String> kProductIds = utillsData['planIds'].whereType<String>().toSet();

      final ProductDetailsResponse response = await inAppPurchase.queryProductDetails(kProductIds);
      if (response.notFoundIDs.isNotEmpty) {
        'Product not found: ${response.notFoundIDs}'.errorLogs();
      }
      if (response.error != null) {
        'Error fetching products: ${response.error}'.errorLogs();
      }
      return response.productDetails;
    }
    return [];
  }

  Future<bool> verifyPurchase() async {
    bool hasValidPurchase = false;

    for (final purchase in purchases) {
      if (purchase.pendingCompletePurchase && (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored)) {
        await inAppPurchase.completePurchase(purchase);
      }

      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        hasValidPurchase = true;
        purchases.remove(purchase);
        break;
      }
    }
    return hasValidPurchase;
  }

  Future<bool> buyProduct(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition = inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      /// TO be precise method :  Clear any pending transactions
      await clearIOSTransactions();
    }
    final bool isPurchased = await inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    return isPurchased;
  }

  void listenToPurchaseStream() {
    inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        handlePurchaseUpdates(purchaseDetailsList);
      },
      onError: (error) {
        'Error in purchase stream: $error'.errorLogs();
      },
    );
  }

  void handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
        isPlanActivated = true;
        subscriptionStatusController.add(true);
        if (purchaseDetails.pendingCompletePurchase) {
          inAppPurchase.completePurchase(purchaseDetails);
          'Complete purchase'.infoLogs();
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        'Purchase error: ${purchaseDetails.error?.message}'.errorLogs();
      }
    }
  }

  Future<void> clearIOSTransactions() async {
    final transactions = await SKPaymentQueueWrapper().transactions();

    for (final transaction in transactions) {
      if (transaction.transactionState == SKPaymentTransactionStateWrapper.purchased ||
          transaction.transactionState == SKPaymentTransactionStateWrapper.failed ||
          transaction.transactionState == SKPaymentTransactionStateWrapper.restored) {
        await SKPaymentQueueWrapper().finishTransaction(transaction);
      }
    }
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}

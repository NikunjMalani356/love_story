import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebViewController extends GetxController {
  WebViewController? controller;
  bool isLoading = false;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    webViewInApp();
  }

  void webViewInApp() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColorConstant.appTransparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            isLoading = true;
            update();
          },
          onPageFinished: (String url) {
            isLoading = false;
            update();
          },
          onHttpError: (HttpResponseError error) {
            'httpResponseError'.showErrorToast();
          },
          onWebResourceError: (WebResourceError error) {
            'webResponseError'.showErrorToast();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://flutter.dev')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(Get.arguments['url'] ?? 'https://flutter.dev'));
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/web_view_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebViewScreen extends StatelessWidget {
  const AppWebViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppWebViewController>(
      init: AppWebViewController(),
      builder: (AppWebViewController appWebViewController) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const AppText('privacy policy', fontSize: Dimens.textSizeLarge, fontWeight: FontWeight.bold),
          ),
          body: Stack(
            children: [
              WebViewWidget(controller: appWebViewController.controller ?? WebViewController()),
              if (appWebViewController.isLoading) const AppLoader(),
            ],
          ),
        );
      },
    );
  }
}

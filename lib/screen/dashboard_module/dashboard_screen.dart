import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/app_function.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/controller/dashboard_controller.dart';
import 'package:love_story_unicorn/screen/dashboard_module/dashboard_helper.dart';

import 'package:love_story_unicorn/serialized/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  DashboardHelper? dashboardHelper;
  DashboardController? dashboardController;

  @override
  Widget build(BuildContext context) {
    "Current screen --> $runtimeType".logs();
    dashboardHelper ??= DashboardHelper(this);
    return GetBuilder(
      init: DashboardController(),
      builder: (DashboardController controller) {
        dashboardController = controller;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (dashboardController?.currentIndex == 1) {
              dashboardController?.updateCurrentIndex(0);
            } else if (dashboardController?.currentIndex == 2) {
              dashboardController?.updateCurrentIndex(0);
            } else {
              await AppFunction.showExitDialog();
            }
          },
          child: Scaffold(
            bottomNavigationBar: SafeArea(
              top: false,
              child: buildContainer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(dashboardHelper!.pages.length, buildBottomBarItem),
                ),
              ),
            ),
            body: dashboardHelper!.pages[dashboardController!.currentIndex]['body'],
          ),
        );
      },
    );
  }

  Widget buildContainer({required Widget child}) {
    return Container(
      height: Dimens.heightExtraLarge,
      decoration: const BoxDecoration(color: AppColorConstant.appWhite),
      child: child,
    );
  }

  Widget buildBottomBarItem(int index) {
    return GestureDetector(
      onTap: () => dashboardController?.updateCurrentIndex(index),
      child: SizedBox(
        width: Get.width / 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (index == dashboardController?.currentIndex) Container(height: 3, color: index == 0 ? AppColorConstant.appErrorColor : AppColorConstant.appBlack) else Container(height: 3),
            Stack(
              alignment: Alignment.center,
              children: [
                if (index == 0 && dashboardHelper?.currentUserData?.followers != null && dashboardHelper?.currentUserData?.followers.isNotEmpty == true && dashboardHelper?.currentUserData?.following.isEmpty == true) ...[
                  StreamBuilder<Map<String, int>>(
                    stream: dashboardHelper?.followedTimeStream(dashboardHelper?.currentUserData?.followers.first ?? FollowingModel(userId: '', followedTime: DateTime.now().toUtc())),
                    builder: (context, snapshot) {
                      final timeRemaining = snapshot.data ?? {'hours': 0, 'minutes': 0, 'seconds': 0};
                      final hours = timeRemaining['hours'] ?? 0;
                      final minutes = timeRemaining['minutes'] ?? 0;
                      final seconds = timeRemaining['seconds'] ?? 0;
                      if (hours > 0 || minutes > 0 || seconds > 0) {
                        return const AppImageAsset(
                          image: AppAsset.matchGlow,
                          height: 56,
                          width: 56,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
                AppImageAsset(
                  image: index == dashboardController?.currentIndex ? dashboardHelper!.pages[index]['image'] : dashboardHelper!.pages[index]['unfilledImage'],
                ),
              ],
            ),
            const SizedBox(height: Dimens.heightSmall),
          ],
        ),
      ),
    );
  }
}

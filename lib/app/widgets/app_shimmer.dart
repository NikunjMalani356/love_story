import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmerEffectView extends StatelessWidget {
  final double? height;
  final double? width;
  final double? borderRadius;

  const AppShimmerEffectView({super.key, this.height, this.width, this.borderRadius});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColorConstant.appLightGrey,
      highlightColor: AppColorConstant.appWhite,
      child: Container(
        height: height ?? 30,
        width: Get.width,
        decoration: BoxDecoration(
          color: AppColorConstant.appWhite200,
          borderRadius: BorderRadius.circular(borderRadius ?? 4),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/controller/chat_controller.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPreviewScreen extends StatelessWidget {
  const PhotoPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    return GetBuilder<ChatController>(
      builder: (ChatController controller) {
        final String imagePath = Get.arguments['url'];
        final bool isNetworkImage = imagePath.startsWith('http') || imagePath.startsWith('https');
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                PhotoView(
                  backgroundDecoration: const BoxDecoration(color: AppColorConstant.appWhite),
                  imageProvider: isNetworkImage ? NetworkImage(imagePath) : FileImage(File(imagePath)),
                ),
                InkWell(
                  onTap: () => RouteHelper.instance.goToBack(),
                  child: Container(
                    padding: const EdgeInsets.all(DimensPadding.paddingSmallMedium),
                    margin: const EdgeInsets.only(left: DimensPadding.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColorConstant.appWhite200,
                      borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                    ),
                    child: const AppImageAsset(image: AppAsset.icBack, height: Dimens.heightSmallMedium),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';

class AppLoader extends StatefulWidget {
  final Color? backgroundColor;

  const AppLoader({super.key, this.backgroundColor});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: widget.backgroundColor ?? AppColorConstant.appPurple.withOpacity(0.3)),
      child: Center(
        child: AppImageAsset(
          image: AppAsset.unicorn,
          width: MediaQuery.of(context).size.width * 0.3,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/screen/splash/splash_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  SplashScreenHelper? splashScreenHelper;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    splashScreenHelper ??= SplashScreenHelper(this);
    return Scaffold(
      body: AppBackground(
        showBack: false,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            const Center(child: AppImageAsset(image: AppAsset.signUpUnicorn, height: Dimens.heightHuge, width: Dimens.heightHuge)),
            FutureBuilder<String>(
              future: splashScreenHelper?.getVersion(),
              builder: (context, snapshot) => AppText('Version : ${snapshot.data ?? ''}', color: AppColorConstant.appWhite),
            ),
          ],
        ),
      ),
    );
  }
}

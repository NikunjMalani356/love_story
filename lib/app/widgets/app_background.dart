import 'package:flutter/material.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String? titleText;
  final String? suffixIcon;
  final String? backIcon;
  final bool showBack;
  final bool showSuffixIcon;
  final bool isLoading;
  final VoidCallback? onTapShowBack;
  final VoidCallback? onSuffixTap;
  final Color? titleColor;
  final String? suffixTitle;

  const AppBackground({super.key, this.child = const SizedBox(), this.titleText, this.backIcon, this.showBack = true, this.showSuffixIcon = false, this.isLoading = false, this.onTapShowBack, this.onSuffixTap, this.suffixIcon, this.titleColor, this.suffixTitle});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppImageAsset(
          image: AppAsset.appBackground,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        SafeArea(child: child),
        SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showBack) ...[
                    InkWell(
                      onTap: onTapShowBack ?? () => RouteHelper.instance.goToBack(),
                      child: Container(
                        padding: const EdgeInsets.all(DimensPadding.paddingSmallMedium),
                        margin: const EdgeInsets.only(left: DimensPadding.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColorConstant.appWhite,
                          borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                        ),
                        child: AppImageAsset(image: backIcon ?? AppAsset.icBack, height: Dimens.heightSmallMedium),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(),
                  ],
                  if (showSuffixIcon) ...[
                    InkWell(
                      onTap: onSuffixTap,
                      child: Container(
                        padding: suffixTitle != null ? const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium, vertical: DimensPadding.paddingSmallMedium) : const EdgeInsets.all(DimensPadding.paddingSmallMedium),
                        margin: const EdgeInsets.only(right: DimensPadding.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColorConstant.appWhite,
                          borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                        ),
                        child: (suffixTitle != null)
                            ? AppText(
                                suffixTitle ?? '',
                                fontSize: Dimens.textSizeLarge,
                              )
                            : AppImageAsset(image: suffixIcon ?? AppAsset.icMenu, height: Dimens.heightSmallMedium),
                      ),
                    ),
                  ],
                ],
              ),
              if (titleText != null) ...[
                AppText(
                  titleText ?? '',
                  fontSize: Dimens.textSizeVeryLarge,
                  fontWeight: FontWeight.w800,
                  color: titleColor ?? AppColorConstant.appBlack,
                ),
              ],
            ],
          ),
        ),
        if (isLoading) const AppLoader(),
      ],
    );
  }
}

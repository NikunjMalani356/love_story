// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_shimmer.dart';

class AppImageAsset extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final bool isFile;
  final Alignment alignment;
  final String? cachingKey;

  const AppImageAsset({
    super.key,
    this.cachingKey,
    required this.image,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.isFile = false,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty || image.contains('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        cacheKey: cachingKey,
        placeholder: (context, url) => AppShimmerEffectView(height: height, width: width),
        errorWidget: (context, url, error) => const Center(child: AppImageAsset(image: AppAsset.signUpUnicorn, height: Dimens.dragonCustomHeight, width:Dimens.dragonCustomHeight)),
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        alignment: alignment,
      );
    } else if (isFile) {
      return Image.file(File(image), height: height, width: width, color: color, fit: fit);
    } else if (image.contains('.json')) {
      return Lottie.asset(image, height: height, width: width);
    } else if (image.split('.').last != 'svg') {
      return Image.asset(image, fit: fit, height: height, width: width, color: color);
    } else {
      return SvgPicture.asset(image, height: height, width: width, color: color, fit: fit ?? BoxFit.contain);
    }
  }
}

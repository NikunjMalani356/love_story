import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/app/widgets/app_text_form_field.dart';
import 'package:love_story_unicorn/service/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';

class AppFunction {
  static Future<File?> selectImage() async {
    File? image;
    final source = await Get.dialog<ImageSource>(
      AlertDialog(
        backgroundColor: AppColorConstant.appWhite,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText("Select option to upload."),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: AppButton(
                    title: 'Camera',
                    onTap: () => Get.back(result: ImageSource.camera),
                  ),
                ),
                const SizedBox(width: Dimens.widthNormal),
                Expanded(
                  child: AppButton(
                    title: 'Gallery',
                    onTap: () => Get.back(result: ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      if (source == ImageSource.gallery) {
        final permissionGranted = await PermissionService.instance.requestStorageOrMediaPermission();
        'permissionGranted --> $permissionGranted'.infoLogs();
        if (!permissionGranted) {
          return null;
        }
      }
      if (source == ImageSource.camera) {
        final permissionGranted = await PermissionService.instance.requestPermission(Permission.camera);
        if (!permissionGranted) return null;
      }
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        final filePath = pickedFile.path;
        image = await compressImage(File(filePath));
      }
    }
    return image;
  }

  static Future<File?> compressImage(File file) async {
    String targetFileName = file.uri.pathSegments.last;
    if (!targetFileName.endsWith('.jpg') && !targetFileName.endsWith('.jpeg')) {
      targetFileName = "${targetFileName.split('.').first}.jpg";
    }
    final targetPath = "${file.parent.path}/compressed_$targetFileName";
    try {
      final result = await FlutterImageCompress.compressAndGetFile(file.absolute.path, targetPath, quality: 70);
      return result?.path == null ? null : File(result!.path);
    } catch (e) {
      'Image compression failed: $e'.errorLogs();
      return null;
    }
  }

  static Future<String?> selectVideo() async {
    final source = await Get.dialog<ImageSource>(
      AlertDialog(
        backgroundColor: AppColorConstant.appWhite,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText("Select option to upload a video."),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: AppButton(
                    title: 'Camera',
                    onTap: () => Get.back(result: ImageSource.camera),
                  ),
                ),
                const SizedBox(width: Dimens.widthNormal),
                Expanded(
                  child: AppButton(
                    title: 'Gallery',
                    onTap: () => Get.back(result: ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (source == ImageSource.camera) {
      final permissionGranted = await PermissionService.instance.requestPermission(Permission.camera);
      if (!permissionGranted) return null;
      final String video = await RouteHelper.instance.goToCameraScreen();
      return await compressVideo(video);
    } else if (source != null) {
      final permissionGranted = await PermissionService.instance.requestStorageOrMediaPermission();
      if (!permissionGranted) return null;
      final pickedFile = await ImagePicker().pickVideo(source: source);
      if (pickedFile != null) {
        return await compressVideo(pickedFile.path);
      }
    }
    return null;
  }

  static Future<String?> compressVideo(String filePath) async {
    try {
      final info = await VideoCompress.compressVideo(filePath, quality: VideoQuality.MediumQuality);
      if (info != null && info.file != null) return info.file!.path;
    } catch (e) {
      'Video compression failed: $e'.errorLogs();
    }
    return null;
  }

  static Future<void> showExitDialog() async {
    await Get.dialog<bool>(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(StringConstant.exitAppDescription, fontSize: Dimens.size20, textAlign: TextAlign.center),
            const SizedBox(height: Dimens.heightSmallMedium),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    title: StringConstant.cancel,
                    onTap: () => Get.back(),
                  ),
                ),
                const SizedBox(width: Dimens.heightSmall),
                Expanded(
                  child: AppButton(
                    title: StringConstant.yes,
                    onTap: () => SystemNavigator.pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showDeleteDialog({GestureTapCallback? onTap}) async {
    await Get.dialog<bool>(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Dimens.heightSmall),
            const AppText('Are you sure you want to delete?', fontSize: Dimens.size20, textAlign: TextAlign.center),
            const SizedBox(height: Dimens.heightSmallMedium),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    title: StringConstant.cancel,
                    onTap: () => Get.back(),
                  ),
                ),
                const SizedBox(width: Dimens.heightSmall),
                Expanded(
                  child: AppButton(
                    title: StringConstant.yes,
                    onTap: onTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showVerifyLoginDialog({GestureTapCallback? onTap, TextEditingController? emailController, TextEditingController? passwordController}) async {
    await Get.dialog<bool>(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Dimens.heightSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Password Confirmation', fontSize: Dimens.size20, textAlign: TextAlign.center),
                const SizedBox(width: Dimens.heightSmall),
                InkWell(
                  onTap: () => showComingSoonDialog(
                    info: [
                      if (Platform.isIOS) StringConstant.unsubscribeAppStore else StringConstant.unsubscribePlayStore,
                       StringConstant.forgotPasswordDescription,
                    ],
                  ),
                  child: const AppImageAsset(image: AppAsset.icInfo),
                ),
              ],
            ),
            const SizedBox(height: Dimens.heightSmallMedium),
            AppTextFormField(
              controller: emailController,
              hintText: 'Email',
              readOnly: true,
              backgroundColor: AppColorConstant.appLightGrey,
            ),
            const SizedBox(height: Dimens.heightSmall),
            AppTextFormField(controller: passwordController, hintText: 'Password', borderColor: AppColorConstant.appBlack.withOpacity(0.5), borderWidth: 1, autofocus: true),
            const SizedBox(height: Dimens.heightSmallMedium),
            Row(
              children: [
                Expanded(child: AppButton(title: StringConstant.cancel, onTap: () => Get.back())),
                const SizedBox(width: Dimens.heightSmall),
                Expanded(child: AppButton(title: StringConstant.yes, onTap: onTap)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showComingSoonDialog({GestureTapCallback? onTap, List<String>? info}) async {
    await Get.dialog<bool>(
      AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              info?.length ?? 0,
              (int index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('•').paddingOnly(right: DimensPadding.paddingTiny),
                    Expanded(child: AppText(info?[index] ?? '')),
                  ],
                ).paddingSymmetric(vertical: DimensPadding.paddingSmallNormal);
              },
            ),
          ).paddingOnly(top: DimensPadding.paddingSmallNormal),
        ),
      ),
    );
  }

  static Future<void> showPermissionDialog() async {
    await Get.dialog<bool>(
      barrierDismissible: false,
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(StringConstant.permissionDescription, fontSize: Dimens.size20, textAlign: TextAlign.center),
            const SizedBox(height: Dimens.heightXSmall),
            const AppText(StringConstant.permissionSubDescription, fontSize: Dimens.size20, textAlign: TextAlign.center),
            const SizedBox(height: Dimens.heightExtraMedium),
            Row(
              children: [
                Expanded(child: AppButton(title: StringConstant.notNow, onTap: () => Get.back())),
                const SizedBox(width: Dimens.heightSmall),
                Expanded(
                  child: AppButton(
                    title: StringConstant.goToSetting,
                    onTap: () async {
                      final bool isOpened = await openAppSettings();
                      if (isOpened) Get.back();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool> showSoftwareUpdateDialog(Map<String, dynamic> updateMap) async {
    final bool isSoftUpdate = updateMap['update_type'] == 'soft';
    final bool? result = await Get.dialog<bool>(
      barrierDismissible: isSoftUpdate,
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Dimens.heightExtraNormal),
            AppText(
              isSoftUpdate ? SoftwareUpdateConstants.hardUpdateTitle : SoftwareUpdateConstants.hardUpdateTitle,
              fontSize: Dimens.textSizeVeryLarge,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: Dimens.heightExtraNormal),
            AppText(updateMap['whats_new'], fontSize: Dimens.textSizeLarge, textAlign: TextAlign.center),
            const SizedBox(height: Dimens.heightExtraMedium),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    title: SoftwareUpdateConstants.updateNow,
                    onTap: () async => await updateMap['update_path'].toString().launchString(),
                  ),
                ),
                if (isSoftUpdate) ...[
                  const SizedBox(width: Dimens.heightSmall),
                  Expanded(
                    child: AppButton(
                      title: SoftwareUpdateConstants.notNow,
                      onTap: () => Get.back(result: true),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
    return result ?? true;
  }
}

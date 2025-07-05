import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/app_function.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService instance = PermissionService._internal();

  factory PermissionService() => instance;

  PermissionService._internal();

  Future<bool> requestStorageOrMediaPermission() async {
    if (await isAndroid13orAbove()) {
      return await requestPermission(Permission.videos);
    } else {
      return await requestPermission(Platform.isIOS ? Permission.photos : Permission.storage);
    }
  }

  Future<bool> isAndroid13orAbove() async {
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return true;
      }
    }
    return false;
  }

  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    'Permission status $permission --> $status'.infoLogs();
    if (status == PermissionStatus.granted) {
      return true;
      } else if (status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied || status == PermissionStatus.limited) {
        await AppFunction.showPermissionDialog();
        return false;
    }
    return false;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/app_function.dart';
import 'package:love_story_unicorn/service/connectivity_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RemoteConfigService {
  RemoteConfigService._privateConstructor();

  static final RemoteConfigService instance = RemoteConfigService._privateConstructor();

  Future<void> setUpRemoteConfig() async {
    try {
      final bool isConnected = await ConnectivityService.instance.checkConnection();
      'Connected --> $isConnected'.logs();
      if (!isConnected) return;
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(fetchTimeout: Duration.zero, minimumFetchInterval: Duration.zero));
      await remoteConfig.ensureInitialized();
      await remoteConfig.fetchAndActivate();
    } on FirebaseException catch (e) {
      e.message.toString().showError();
    }
  }

  Future<bool> getRemoteValue() async {
    final bool isConnected = await ConnectivityService.instance.checkConnection();
    if (!isConnected) return true;
    final FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.instance;
    final String consoleKey = firebaseRemoteConfig.getString('update_info');
    final Map<String, dynamic> updateInfoMap = jsonDecode(consoleKey);
    'Console key --> $updateInfoMap'.infoLogs();
    final bool isAndroidOs = Platform.isAndroid;
    final Map<String, dynamic> updateIosMap = isAndroidOs ? updateInfoMap['android'] : updateInfoMap['ios'];
    'Update info map --> $updateIosMap'.infoLogs();
    if (updateIosMap['update_type'] == 'none') return true;
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final bool isAbleToUpdateAvailable = num.parse(packageInfo.version.replaceAll('.', '')) < num.parse(updateIosMap['app_version'].replaceAll('.', ''));
    if (!isAbleToUpdateAvailable) return true;
    final bool isUpdated = await AppFunction.showSoftwareUpdateDialog(updateIosMap);
    return isUpdated;
  }
}

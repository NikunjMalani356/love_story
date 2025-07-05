import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';
import 'package:love_story_unicorn/screen/splash/splash_screen.dart';
import 'package:love_story_unicorn/service/remote_config_service.dart';
import 'package:love_story_unicorn/service/shared_preference.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreenHelper {
  SplashScreenState state;
  UserRepository userRepository = getIt.get<UserRepository>();

  SplashScreenHelper(this.state) {
    manageUser();
  }

  Future<String> getVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version} (${packageInfo.buildNumber})';
  }

  Future<void> manageUser() async {
    final bool isUpdated = await RemoteConfigService.instance.getRemoteValue();
    if (isUpdated) {
      'FirebaseAuth.instance.currentUser --> ${FirebaseAuth.instance.currentUser?.uid}'.infoLogs();
      final bool? isFirstLaunch = await SharedPrefService.instance.getPrefBoolValue(SharedPrefService.isFirstLaunch);
      'isFirstLaunch --> $isFirstLaunch'.infoLogs();
      if (isFirstLaunch == null) {
        await FirebaseAuth.instance.signOut();
        await SharedPrefService.instance.setPrefBoolValue(SharedPrefService.isFirstLaunch, false);
      }
      Future.delayed(
        const Duration(seconds: 2),
            () async {
          if (FirebaseAuth.instance.currentUser?.uid != null) {
            final bool isSubscribed = await userRepository.checkUserSubscription();
            'isSubscribed --> $isSubscribed'.infoLogs();
            if (isSubscribed) {
              final bool isInfoFilled = await userRepository.checkUserData();
              if (isInfoFilled) {
                RouteHelper.instance.gotoDashboard();
              } else {
                RouteHelper.instance.goToBasicInformation();
              }
            } else {
              RouteHelper.instance.goToSubscription();
            }
          } else {
            RouteHelper.instance.goToSignIn();
          }
        },
      );
    }
  }
}

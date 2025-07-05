import 'package:firebase_auth/firebase_auth.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/screen/dashboard_module/chat_screen/chat_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/dashboard_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/matches/match_making_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/profile_screen.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';

import 'package:love_story_unicorn/service/config_service.dart';

class DashboardHelper {
  DashboardScreenState state;
  UserModel? currentUserData;
  double hours = 0.0;

  List<Map<String, dynamic>> pages = [
    {'image': AppAsset.icFilledMatches, 'unfilledImage': AppAsset.icUnfilledMatches, 'body': const MatchMakingScreen()},
    {'image': AppAsset.icUnfilledChats, 'unfilledImage': AppAsset.icUnfilledChats, 'body': const ChatScreen()},
    {'image': AppAsset.icUnfilledProfile, 'unfilledImage': AppAsset.icUnfilledProfile, 'body': const ProfileScreen()},
  ];

  DashboardHelper(this.state) {
    Future.delayed(const Duration(milliseconds: 10), () async => await getUser());
    hours = ConfigService.instance.getHourAsSeconds().toDouble();
  }

  Future<void> getUser() async {
    currentUserData = await state.dashboardController?.userRepository.getUserData(
      userId: FirebaseAuth.instance.currentUser?.uid,
    );
    state.dashboardController?.update();
  }

  Stream<Map<String, int>> followedTimeStream(FollowingModel followingModel) async* {
    final followedTime = followingModel.followedTime;
    final durationToAdd = Duration(seconds: hours.toInt());

    final endTime = followedTime.add(durationToAdd);

    while (true) {
      final now = DateTime.now();
      if (now.isAfter(endTime)) {
        yield {'hours': 0, 'minutes': 0, 'seconds': 0};
        break;
      }

      final remaining = endTime.difference(now);
      final hoursLeft = remaining.inHours;
      final minutesLeft = remaining.inMinutes % 60;
      final secondsLeft = remaining.inSeconds % 60;

      yield {
        'hours': hoursLeft,
        'minutes': minutesLeft,
        'seconds': secondsLeft,
      };

      await Future.delayed(const Duration(seconds: 1));
    }
  }
}

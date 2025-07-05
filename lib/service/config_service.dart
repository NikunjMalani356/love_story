import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';

class ConfigService {
  static String hour = "00:00:00"; // Keep as String
  static String rejectTime = "00:00:00"; // Keep as String
  static final ConfigService instance = ConfigService._internal();

  factory ConfigService() => instance;

  ConfigService._internal();

  Future<void> getRequestTimeFromConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetchAndActivate();

      final timeJson = remoteConfig.getAll()['request_time'];
      if (timeJson != null) {
        "timeJson asString: ${timeJson.asString()}".logs();

        final Map<String, dynamic> timeData = jsonDecode(timeJson.asString());
        if (timeData.containsKey('time')) {
          hour = timeData['time'];
        } else {
          'Key "time" not found in the Remote Config data.'.errorLogs();
        }
      } else {
        'Key "request_time" not found in Remote Config.'.errorLogs();
      }

     final  rejectTimeJson = remoteConfig.getAll()['reject_time'];
      if (rejectTimeJson != null) {
        final Map<String, dynamic> timeData = jsonDecode(rejectTimeJson.asString());
        if (timeData.containsKey('time')) {
          rejectTime = timeData['time'];
        } else {
          'Key "time" not found in the Remote Config data.'.errorLogs();
        }
      } else {
        'Key "reject_time" not found in Remote Config.'.errorLogs();
      }
    } catch (e) {
      'Error fetching time: $e'.errorLogs();
    }
  }

  /// Helper to convert `hour` string to total seconds
  int getHourAsSeconds() {
    try {
      final parts = hour.split(':');
      if (parts.length == 3) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        final seconds = int.tryParse(parts[2]) ?? 0;

        return hours + (minutes * 60) + (seconds * 3600);
      } else {
        'Invalid time format in hour: $hour'.errorLogs();
        return 0;
      }
    } catch (e) {
      'Error parsing hour as seconds: $e'.errorLogs();
      return 0;
    }
  }

  int getRejectTimeHourAsSeconds() {
    try {
      final parts = rejectTime.split(':');
      if (parts.length == 3) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        final seconds = int.tryParse(parts[2]) ?? 0;

        return hours + (minutes * 60) + (seconds * 3600);
      } else {
        'Invalid time format in hour: $rejectTime'.errorLogs();
        return 0;
      }
    } catch (e) {
      'Error parsing hour as seconds: $e'.errorLogs();
      return 0;
    }
  }
}

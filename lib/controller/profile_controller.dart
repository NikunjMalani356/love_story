import 'dart:io';

import 'package:get/get.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/app_function.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/authentication/auth_repository.dart';
import 'package:love_story_unicorn/repository/cheating/cheating_repository.dart';
import 'package:love_story_unicorn/repository/que_ans/que_ans_repository.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';
import 'package:love_story_unicorn/repository/utills/utills_repository.dart';
import 'package:love_story_unicorn/serialized/age_model.dart';
import 'package:video_player/video_player.dart';

class ProfileController extends GetxController {
  AuthRepository authRepository = getIt.get<AuthRepository>();
  UtillsRepository utillsRepository = getIt.get<UtillsRepository>();
  UserRepository userRepository = getIt.get<UserRepository>();
  QueAnsRepository queAnsRepository = getIt.get<QueAnsRepository>();
  CheatingRepository chattingRepository = getIt.get<CheatingRepository>();
  DateTime? birthDateTime;
  AgeModel? age;
  File? selectedHeadShotImage;
  String? selectHeadshotImageUrl;
  String? selectFullBodyImageUrl;
  File? selectedFullBodyImage;
  VideoPlayerController? videoController;
  dynamic videoPath;
  int? selectedIHavePreference;
  int? selectedIWantPreference;

  List<int> get yearList => List.generate(82, (index) => DateTime.now().year - 18 - index);
  int selectedYear = DateTime.now().year - 18;

  String nameError = "";
  String lastNameError = "";
  String dobError = "";
  String olderAgeError = "";
  String youngerAgeError = "";
  String countryError = "";
  String stateError = "";
  String cityError = "";
  String partnerLocationError = "";
  bool isLoading = false;

  void updateYear(int year) {
    selectedYear = year;
    update();
  }

  void updateSelectedDate(DateTime date) {
    birthDateTime = date;
    calculateAge();
    update();
  }

  void calculateAge() {
    if (birthDateTime == null) return;

    final DateTime currentDate = DateTime.now();
    final DateTime birthDate = birthDateTime!;

    int years = currentDate.year - birthDate.year;
    int months = currentDate.month - birthDate.month;
    int days = currentDate.day - birthDate.day;

    if (months < 0 || (months == 0 && days < 0)) {
      years--;
      months += 12;
    }

    if (days < 0) {
      final monthBefore = DateTime(currentDate.year, currentDate.month - 1);
      days += DateTime(monthBefore.year, monthBefore.month + 1, 0).day;
      months--;
    }

    age = AgeModel(
      years: years,
      month: months,
      day: days,
    );

    update();
  }

  void manageVideoPlayer() {
    videoController?.value.isPlaying == true ? videoController?.pause() : videoController?.play();
    update();
  }

  Future<void> pickIntroVideo() async {
    final dynamic video = await AppFunction.selectVideo();
    if (video != null && video.toString().isNotEmpty) {
      videoPath = video;
    }
    if (videoPath != null && videoPath is String) {
      videoController?.dispose();
      videoController = VideoPlayerController.file(File(videoPath));
      await videoController?.initialize();
      final videoDuration = videoController?.value.duration;
      'videoDuration --> $videoDuration'.infoLogs();
      if (videoDuration != null) {
        if (videoDuration < const Duration(seconds: 5)) {
          'Video too short. Minimum 5 seconds required.'.showErrorToast();
          videoController?.dispose();
          videoController = null;
          videoPath = '';
          update();
          return;
        }
      }

      videoController?.addListener(() {
        'isCompleted --> ${videoController?.value.isCompleted}'.infoLogs();
        if (videoController?.value.isCompleted == true) videoController?.pause();
        update();
      });
      update();
      'videoController --> $videoController'.infoLogs();
    }
  }

  Future<void> pickHeadShot() async {
    final image = await AppFunction.selectImage();
    if (image != null) {
      selectedHeadShotImage = image;
      update();
    }
  }

  Future<void> pickFullBody() async {
    final image = await AppFunction.selectImage();

    if (image != null) {
      selectedFullBodyImage = image;
      update();
    }
  }

  Future<void> updateData({String? field, dynamic value}) async {
    await userRepository.updateUser(field != null ? {field: value} : {});
  }
}

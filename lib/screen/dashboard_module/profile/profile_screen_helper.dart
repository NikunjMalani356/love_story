import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/helper/rest_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/app_function.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/profile_screen.dart';
import 'package:love_story_unicorn/serialized/country_model.dart';
import 'package:love_story_unicorn/serialized/question_model.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:video_player/video_player.dart';

class ProfileScreenHelper {
  ProfileScreenState state;
  UserModel? userProfile;
  int currentPage = 0;
  final TextEditingController countryController = TextEditingController();
  String? countryError;
  final TextEditingController stateController = TextEditingController();
  String? stateError;
  final TextEditingController cityController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? cityError;
  List<TextEditingController> answerController = [];
  ScrollController scrollController = ScrollController();
  final CarouselSliderController carouselSliderController = CarouselSliderController();
  VideoPlayerController? videoController;
  Map<String, dynamic> questionAnswer = {};
  List<Question> questions = [];
  Question? allQuestions;
  bool isVideoPlaying = false;
  bool isLoading = true;
  String appVersion = '';
  List<String> relocationList = [];
  List<bool> isEditQuestion = [];
  List<String> answerError = [];
  String? relocationError;
  bool isRelocationTap = false;
  bool isLocationTap = false;
  String? gender;
  bool isGender = false;
  bool isLoadingLocation = false;
  String? genderError;
  List<String> partnerPrefs = [];
  String? partnerPrefsError;
  bool isPartnerPrefsTap = false;
  bool isAgeDiffTap = false;
  bool isChildPrefTap = false;
  List<String> iHave = [];
  String? iHaveError;
  List<String> iWant = [];
  String? iWantError;
  String? olderAge;
  String? youngerAge;
  List<String> countryList = [];
  List<CountryModel> countryModel = [];
  List<String> stateList = [];
  List<StatModel> stateModel = [];
  List<String> cityList = [];

  ProfileScreenHelper(this.state) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async => await init());
  }

  Future<void> init() async {
    isLoading = true;
    updateState();
    await getCurrentUser();
    setData();
    await getAllQuestions();
    await loadQuestionsFromJson();
    await getVersion();
    getGetCountries();
    isLoading = false;
    updateState();
  }

  Future<void> getGetCountries() async {
    await getCountries();
    await getStates();
    await getCity();
    updateState();
  }

  void setData() {
    relocationList = userProfile?.relocation ?? [];
    gender = userProfile?.gender;
    partnerPrefs = userProfile?.partnerPrefs ?? [];
    iHave = userProfile?.childPref?.iHave ?? [];
    iWant = userProfile?.childPref?.iWant ?? [];
    olderAge = userProfile?.olderAge;
    youngerAge = userProfile?.youngerAge;
    countryController.text = userProfile?.userLocation?.country ?? '';
    stateController.text = userProfile?.userLocation?.state ?? '';
    cityController.text = userProfile?.userLocation?.city ?? '';
    emailController.text = userProfile?.email ?? '';
    updateState();
  }

  void updateState() => state.profileController?.update();

  void onPageChanged(int index) {
    currentPage = index;
    updateState();
  }

  Future<void> getCountries({bool isGetStates = false}) async {
    try {
      isLoading = true;
      updateState();
      final response = await RestServices.instance.getRestCall(endpoint: '');
      if (response != null && response.isNotEmpty) {
        final List<dynamic> responseMap = jsonDecode(response);
        countryModel = responseMap.map((e) => CountryModel.fromJson(e)).toList();
        countryList.addAll(countryModel.map((e) => e.name ?? '').toList());
      }
    } on SocketException catch (e) {
      'Catch SocketException in getCountries --> ${e.message}'.errorLogs();
    }
    isLoading = false;
    updateState();
  }

  Future<void> getStates() async {
    try {
      isLoadingLocation = true;
      updateState();
      stateList = [];
      final String? country = countryModel.firstWhere((element) => element.name == countryController.text).iso2;
      final response = await RestServices.instance.getRestCall(endpoint: '${country ?? ''}/states');
      if (response != null && response.isNotEmpty) {
        final List<dynamic> responseMap = jsonDecode(response);
        stateModel = responseMap.map((e) => StatModel.fromJson(e)).toList();
        stateList.addAll(stateModel.map((e) => e.name ?? '').toList());
      }
    } on SocketException catch (e) {
      'Catch SocketException in getStates --> ${e.message}'.errorLogs();
    }
    isLoadingLocation = false;
    updateState();
  }

  Future<void> getCity() async {
    try {
      isLoadingLocation = true;
      state.profileController?.update();
      final String? country = countryModel.firstWhere((element) => element.name == countryController.text).iso2;
      final String? stat = stateModel.firstWhere((element) => element.name == stateController.text).iso2;
      final response = await RestServices.instance.getRestCall(endpoint: '${country ?? ''}/states/${stat ?? ''}/cities');
      if (response != null && response.isNotEmpty) {
        final List<dynamic> responseMap = jsonDecode(response);
        final List<CityModel> cityModel = responseMap.map((e) => CityModel.fromJson(e)).toList();
        cityList.addAll(cityModel.map((e) => e.name ?? '').toList());
      }
    } on SocketException catch (e) {
      'Catch SocketException in getCity --> ${e.message}'.errorLogs();
    }
    isLoadingLocation = false;
    state.profileController?.update();
  }

  void onCountryTap() {
    countryController.clear();
    stateController.clear();
    cityController.clear();
    stateList.clear();
    cityList.clear();
    countryError = null;
    stateError = null;
    cityError = null;
    manageListScroll();
  }

  void onStateTap() {
    stateController.clear();
    cityController.clear();
    cityList.clear();
    stateError = null;
    cityError = null;
  }

  void onCityTap() {
    cityController.clear();
    cityError = null;
  }

  Future<void> selectedCountry(String value) async {
    countryController.text = value;
    await getStates();
    updateState();
  }

  Future<void> selectedState(String value) async {
    stateController.text = value;
    await getCity();
    updateState();
  }

  Future<void> selectedCity(String value) async {
    cityController.text = value;
    updateState();
  }

  void manageListScroll() {
    if (scrollController.position.maxScrollExtent == 0) return;
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void onLocationTap() {
    isLocationTap = true;
    state.profileController?.update();
  }

  void onRelocationTap() {
    isRelocationTap = true;
    state.profileController?.update();
  }

  void onGenderTap() {
    isGender = true;
    state.profileController?.update();
  }

  void onPartnerPrefsTap() {
    isPartnerPrefsTap = true;
    state.profileController?.update();
  }

  void onChildPrefTap() {
    isChildPrefTap = true;
    state.profileController?.update();
  }

  void onAgeDiffTap() {
    isAgeDiffTap = true;
    state.profileController?.update();
  }

  void onChangedIHave(String? newValue) {
    iHave.first = newValue!;
    updateState();
  }

  void onChangedIWant(String? newValue) {
    iWant.first = newValue!;
    updateState();
  }

  void onChangedOlder(String? newValue) {
    olderAge = newValue;
    updateState();
  }

  void onChangedYounger(String? newValue) {
    youngerAge = newValue;
    updateState();
  }

  Future<String> getVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    'appVersion --> $appVersion'.logs();
    return packageInfo.version;
  }

  void manageVideoPlayer() {
    if (videoController?.value.isPlaying == true) {
      videoController?.pause();
      isVideoPlaying = false;
    } else {
      videoController?.play();
      isVideoPlaying = true;
    }
    updateState();
  }

  void onChangedRelocation(String? newValue) {
    relocationList.first = newValue!;
    updateState();
  }

  void onChangedGender(String? newValue) {
    gender = newValue;
    updateState();
  }

  Future<void> getAllQuestions() async {
    try {
      final Map<String, dynamic>? allQuestionAnswer = await state.profileController?.queAnsRepository.getQuestion();
      'allQuestionAnswer --> $allQuestionAnswer'.logs();
      questionAnswer = {'questions_and_answers': []};
      if (allQuestionAnswer != null) {
        if (allQuestionAnswer.containsKey('mandatory')) {
          questionAnswer['questions_and_answers'].addAll(allQuestionAnswer['mandatory']);
          // for(final question in allQuestionAnswer['mandatory']) {
          //   mandatoryQuestions.add(Question.fromJson(question));
          // }
          // 'mandatoryQuestions mandatoryQuestions --> ${mandatoryQuestions.length}'.logs();
        }
        if (allQuestionAnswer.containsKey('optional')) {
          questionAnswer['questions_and_answers'].addAll(allQuestionAnswer['optional']);
          // optionalQuestions.addAll(allQuestionAnswer['optional']);
        }
      }
      'questionAnswer --> ${questionAnswer['questions_and_answers'].length}'.logs();
      initializeVideoForCurrentUser();
    } catch (e) {
      'Catch exception in getAllQuestions --> $e'.errorLogs();
    }
  }

  Future<void> loadQuestionsFromJson() async {
    try {
      isLoading = true;
      updateState();
      final Map<String, dynamic>?  questionsData = await state.profileController?.utillsRepository.getUtillsData('question_list');
      // final String jsonString = await rootBundle.loadString(AppAsset.questionJson);
      // final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> questionsJson = questionsData?['questions_and_answers'] ?? {};
      questions = questionsJson.map((questionJson) => Question.fromJson(questionJson)).toList();
      answerController = List.generate(questions.length, (_) => TextEditingController());
      isEditQuestion = List.generate(questions.length, (_) => false);
      answerError = List.generate(questions.length, (_) => '');
      if (questionAnswer.isNotEmpty) {
        final List<dynamic>? existingAnswers = questionAnswer['questions_and_answers'];
        if (existingAnswers == null) return;
        for (final question in questions) {
          final existingAnswer = existingAnswers.firstWhere((item) => item['question'] == question.question, orElse: () => null);
          if (existingAnswer != null) {
            if (existingAnswer['answer'] is String) {
              question.answer = existingAnswer['answer'];
              answerController[questions.indexOf(question)].text = question.answer ?? '';
            } else if (existingAnswer['answer'] is List) {
              answerController[questions.indexOf(question)].text = existingAnswer['answer'].join(',');
              question.multiAnswer = List<String>.from(existingAnswer['answer']);
              "question.multiAnswer --> ${question.multiAnswer}".logs();
            }
          }
        }
      }
    } catch (e) {
      'Catch exception in loadQuestionsFromJson --> $e'.errorLogs();
    }
    isLoading = false;
    updateState();
  }

  Future<void> initializeVideoForCurrentUser() async {
    'introductionVideo --> ${userProfile?.introductionVideo ?? ''}'.logs();
    videoController = VideoPlayerController.networkUrl(Uri.parse(userProfile?.introductionVideo ?? ''));
    await videoController?.initialize();
    videoController?.addListener(() {
      if (videoController?.value.position == videoController?.value.duration) {
        isVideoPlaying = false;
        updateState();
      }
    });
    updateState();
  }

  void manageLogout() {
    state.profileController?.authRepository.signOut();
    if (userProfile?.fcmToken != null) state.profileController?.updateData(field: 'fcmToken');
    RouteHelper.instance.offAllSignIn();
  }

  Future<void> getCurrentUser() async {
    userProfile = await state.profileController?.userRepository.getUserData();
  }

  Future<void> manageRelocation() async {
    relocationError = relocationList.isEmpty ? "Please select relocation" : null;
    if (relocationError == null) {
      state.profileController?.isLoading = true;
      updateState();
      await state.profileController?.updateData(field: 'relocation', value: relocationList);
      isRelocationTap = false;
      state.profileController?.isLoading = false;
    }
    updateState();
  }

  void managePartnerPrefs() {
    partnerPrefsError = partnerPrefs.isEmpty ? "Please select interested in" : null;
    if (partnerPrefsError == null) {
      state.profileController?.isLoading = true;
      updateState();
      state.profileController?.updateData(field: 'partnerPrefs', value: partnerPrefs);
      isPartnerPrefsTap = false;
      state.profileController?.isLoading = false;
    }
    updateState();
  }

  void manageGender() {
    genderError = gender == null ? "Please select interested in" : null;
    if (genderError == null) {
      state.profileController?.isLoading = true;
      updateState();
      state.profileController?.updateData(field: 'gender', value: gender);
      isGender = false;
      state.profileController?.isLoading = false;
    }
    updateState();
  }

  void manageChildPref() {
    iHaveError = iHave.isEmpty ? "Child preferences you have not selected" : null;
    iWantError = iWant.isEmpty ? "Child preferences you want not selected" : null;
    if (iHaveError == null && iWantError == null) {
      state.profileController?.isLoading = true;
      updateState();
      state.profileController?.updateData(field: 'childPref', value: {'iHave': iHave, 'iWant': iWant});
      isChildPrefTap = false;
      state.profileController?.isLoading = false;
    }
    updateState();
  }

  void manageAge() {
    'olderAge --> $olderAge, youngerAge --> $youngerAge'.logs();
    state.profileController?.isLoading = true;
    updateState();
    state.profileController?.updateData(field: 'olderAge', value: olderAge);
    state.profileController?.updateData(field: 'youngerAge', value: youngerAge);
    isAgeDiffTap = false;
    'isAgeDiffTap --> $isAgeDiffTap'.logs();
    state.profileController?.isLoading = false;
    updateState();
  }

  void manageLocation() {
    countryError = countryController.text.trim().isEmpty
        ? StringConstant.mandatoryCountry
        : countryList.contains(countryController.text) == false
            ? StringConstant.invalidCountry
            : null;
    stateError = stateController.text.trim().isEmpty
        ? StringConstant.mandatoryState
        : stateList.contains(stateController.text) == false
            ? StringConstant.invalidState
            : null;
    cityError = cityController.text.trim().isEmpty
        ? StringConstant.mandatoryCity
        : cityList.contains(cityController.text) == false
            ? StringConstant.invalidCity
            : null;
    if (countryError == null && stateError == null && cityError == null) {
      state.profileController?.isLoading = true;
      updateState();
      state.profileController?.updateData(field: 'userLocation', value: {'country': countryController.text, 'state': stateController.text, 'city': cityController.text});
      isLocationTap = false;
      state.profileController?.isLoading = false;
    }
    updateState();
  }

  Future<void> deleteAccount() async {
    try {
      RouteHelper.instance.goToBack();
      isLoading = true;
      updateState();
      final User? currentUser = await state.profileController?.authRepository.logIn(emailController.text, passwordController.text);
      if (currentUser != null) {
        RouteHelper.instance.goToBack();
        final List<FollowingModel>? followersList = userProfile?.followers;
        'followersList --> $followersList'.logs();
        if (followersList != null && followersList.isNotEmpty) {
          for (final follower in followersList) {
            final String followerId = follower.userId;
            final UserModel? followerData = await state.profileController?.userRepository.getUserData(userId: followerId);
            final String? roomId = await state.profileController?.chattingRepository.findExistingRoom(userProfile?.userId, appositeUserId: followerId);
            if (roomId != null) await state.profileController?.chattingRepository.deleteChatRoom(roomId);
            final Map<String, dynamic>? user = followerData?.toMap();
            if (user != null) {
              user['followers'] = [];
              user['following'] = [];
              await state.profileController?.userRepository.updateUser(user, userId: followerId);
            }
          }
        }
        await state.profileController?.userRepository.deleteUserFolder();
        await state.profileController?.userRepository.deleteUser();
        'Account deleted successfully'.showSuccessToast();
        RouteHelper.instance.offAllSignIn();
      }
    } catch (e) {
      'Error during account deletion: $e'.logs();
    } finally {
      isLoading = false;
      updateState();
    }
  }

  Future<void> getCallCurrentUser() async {
    updateIsLoading(value: true);
    await getCurrentUser();
    await videoController?.initialize();
    updateIsLoading();
  }

  void updateIsLoading({bool value = false}) {
    isLoading = value;
    updateState();
  }

  Future<void> onDeleteTap() {
    return AppFunction.showDeleteDialog(
      onTap: () async {
        RouteHelper.instance.goToBack();
        passwordController.clear();
        await AppFunction.showVerifyLoginDialog(
          emailController: emailController,
          passwordController: passwordController,
          onTap: () => deleteAccount(),
        );
      },
    );
  }
}

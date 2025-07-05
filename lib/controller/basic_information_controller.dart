import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/helper/rest_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/app_function.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/authentication/auth_repository.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';
import 'package:love_story_unicorn/serialized/age_model.dart';
import 'package:love_story_unicorn/serialized/country_model.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';
import 'package:video_player/video_player.dart';

class BasicInformationController extends GetxController {
  AuthRepository authRepository = getIt.get<AuthRepository>();
  UserRepository userRepository = getIt.get<UserRepository>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  late PageController pageController;
  List<String> countryList = [];
  List<CountryModel> countryModel = [];
  List<String> stateList = [];
  List<StatModel> stateModel = [];
  List<String> cityList = [];

  int currentIndex = 0;
  DateTime? birthDateTime;
  AgeModel? age;
  String? selectedOlderAge;
  String? selectedYoungerAge;
  String? partnerLocation;
  int selectedGenderIndex = -1;
  List<int> selectedPartnerGenderIndex = [];
  List<int> selectedRelocationType = [];
  List<int> selectedChildPreference = [];
  String? selectedHeadShotUrl;
  String? selectedFullBodyUrl;
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
  Map<String, dynamic> arguments = Get.arguments ?? {};
  UserModel? user;

  @override
  void onInit() {
    final isEdit = arguments['isEdit'];
    pageController = PageController(initialPage: isEdit != null && arguments['isEdit'] == true ? 1 : 0);
    currentIndex = isEdit != null && arguments['isEdit'] == true ? 1 : 0;
    getData();
    getCountries();
    super.onInit();
  }

  Future<void> getData() async {
    if (arguments['isEdit'] != null && arguments['isEdit'] == true) {
      isLoading = true;
      update();
      user = await userRepository.getUserData() ?? UserModel();
      firstNameController.text = user?.firstName ?? '';
      lastNameController.text = user?.lastName ?? '';
      birthDateTime = user?.dateOfBirth;
      countryController.text = user?.userLocation?.country ?? '';
      stateController.text = user?.userLocation?.state ?? '';
      cityController.text = user?.userLocation?.city ?? '';
      selectedOlderAge = user?.olderAge ?? '';
      selectedYoungerAge = user?.youngerAge ?? '';
      selectedGenderIndex = ListConstant.genderList.indexOf(user?.gender ?? '');
      selectedPartnerGenderIndex = user?.partnerPrefs.map((e) => ListConstant.genderList.indexOf(e)).toList() ?? [];
      selectedRelocationType = user?.relocation?.map((e) => ListConstant.relocationList.indexOf(e)).toList() ?? [];
      selectedIHavePreference = user?.childPref?.iHave != null ? ListConstant.childPreIHaveList.indexOf(user?.childPref!.iHave!.first ?? '') : null;
      selectedIWantPreference = user?.childPref?.iWant != null ? ListConstant.childPreIWantList.indexOf(user?.childPref!.iWant!.first ?? '') : null;
      selectedHeadShotUrl = user?.headShotImage;
      selectedFullBodyUrl = user?.fullBodyImage;
      videoPath = user?.introductionVideo;
      videoController = VideoPlayerController.networkUrl(Uri.parse(user?.introductionVideo ?? ''));
      await videoController?.initialize();
      isLoading = false;
      update();
    }
  }

  void manageLogout() {
    authRepository.signOut();
    RouteHelper.instance.offAllSignIn();
  }

  void goToNextPage() {
    currentIndex++;
    pageController.animateToPage(
      currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    update();
  }

  void updateYear(int year) {
    selectedYear = year;
    update();
  }

  void goToPreviousPage() {
    if (arguments['isEdit'] != null && arguments['isEdit'] == true && currentIndex == 1) {
      'goToPreviousPage'.errorLogs();
      Get.back();
      return;
    }
    if (currentIndex > 0) {
      currentIndex--;
      pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      update();
    }
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

  void updateSelectedDate(DateTime date) {
    birthDateTime = date;
    calculateAge();
    update();
  }

  void countryOnTap() {
    countryController.clear();
    stateController.clear();
    stateList.clear();
    cityController.clear();
    cityList.clear();
  }

  void onChangeCountry(String value) {
    countryError = '';
    stateError = '';
    cityError = '';
    update();
  }

  void stateOnTap() {
    stateController.clear();
    cityController.clear();
    cityList.clear();
  }

  void onChangeState(String value) {
    stateError = '';
    cityError = '';
    update();
  }

  void profileValidation() {
    if (firstNameController.text.trim().isEmpty) {
      nameError = StringConstant.emptyName;
      update();
    } else {
      nameError = '';
      update();
    }
    if (lastNameController.text.trim().isEmpty) {
      lastNameError = StringConstant.emptyLastName;
      update();
    } else {
      lastNameError = '';
      update();
    }
    if (birthDateTime == null) {
      dobError = StringConstant.emptyDob;
      update();
    } else {
      dobError = '';
      update();
    }
    if (nameError.isEmpty && lastNameError.isEmpty && dobError.isEmpty) {
      if (selectedHeadShotUrl == null) {
        'Please select head shot'.showErrorToast();
        return;
      }
      if (selectedFullBodyUrl == null) {
        'Please select full body image'.showErrorToast();
        return;
      }
      if (videoPath == null || videoPath.toString().isEmpty) {
        'Please record intro video'.showErrorToast();
        return;
      }
      videoController?.pause();
      arguments['isEdit'] != null && arguments['isEdit'] == true ? updateUser() : goToNextPage();
    }
  }

  void validatePartnerAge() {
    if (selectedOlderAge == null) {
      olderAgeError = 'Please select older age';
    } else {
      olderAgeError = '';
    }
    if (selectedYoungerAge == null) {
      youngerAgeError = 'Please select younger age';
    } else {
      youngerAgeError = '';
    }
    update();
    if (olderAgeError.isEmpty && youngerAgeError.isEmpty) {
      goToNextPage();
    }
  }

  void validateGender() {
    if (selectedGenderIndex < 0) {
      'Please select gender'.showErrorToast();
      return;
    }
    if (selectedPartnerGenderIndex.isEmpty) {
      'Please select partner gender'.showErrorToast();
      return;
    }
    goToNextPage();
  }

  void manageChildPref(int index, int category) {
    if (category == 1) {
      if (selectedIHavePreference == index) {
        selectedIHavePreference = null;
      } else {
        selectedIHavePreference = index;
      }
    }
    if (category == 0) {
      if (selectedIWantPreference == index) {
        selectedIWantPreference = null;
      } else {
        selectedIWantPreference = index;
      }
    }
    update();
  }

  void managePartnerGender(int index) {
    if (selectedPartnerGenderIndex.contains(index)) {
      selectedPartnerGenderIndex.remove(index);
    } else {
      selectedPartnerGenderIndex.add(index);
    }
    update();
  }

  Future<void> selectedCountry(String value) async {
    countryController.text = value;
    countryError = '';
    stateError = '';
    cityError = '';
    await getStates();
    update();
  }

  Future<void> selectedState(String value) async {
    stateController.text = value;
    stateError = '';
    cityError = '';
    await getCity();
    update();
  }

  void selectedCity(String value) {
    cityController.text = value;
    cityError = '';
    update();
  }

  void validateYourLocation() {
    if (countryController.text.trim().isEmpty) {
      countryError = 'Please select country';
    } else if (countryList.contains(countryController.text) == false) {
      countryError = 'Selected country is invalid';
    } else {
      countryError = '';
    }
    if (stateController.text.trim().isEmpty) {
      stateError = 'Please select state';
    } else if (stateList.contains(stateController.text) == false) {
      stateError = 'Selected state is invalid';
    } else {
      stateError = '';
    }
    if (cityController.text.trim().isEmpty) {
      cityError = 'Please select city';
    } else if (cityList.contains(cityController.text) == false) {
      cityError = 'Selected city is invalid';
    } else if (cityList.isEmpty) {
      cityError = 'City is not available for this state';
    } else {
      cityError = '';
    }
    if (countryError.isEmpty && stateError.isEmpty && cityError.isEmpty) {
      goToNextPage();
    }
    update();
  }

  void manageRelocation(int index) {
    if (selectedRelocationType.contains(index)) {
      selectedRelocationType.clear();
    } else {
      selectedRelocationType.clear();
      selectedRelocationType.add(index);
    }
    update();
  }

  void validateRelocation() {
    if (selectedRelocationType.isEmpty) {
      'Please select relocation option'.showErrorToast();
    } else {
      goToNextPage();
    }
  }

  void validateChildPref() {
    if (selectedIHavePreference == null || selectedIWantPreference == null) {
      'Please select child preference'.showErrorToast();
    } else {
      if (arguments['isEdit'] == null && arguments['isEdit'] != true) registerUser();
    }
  }

  Future<void> pickHeadShot() async {
    final File? image = await AppFunction.selectImage();
    if (image != null) {
      selectedHeadShotUrl = image.path;
      update();
    }
  }

  Future<void> pickFullBody() async {
    final File? image = await AppFunction.selectImage();

    if (image != null) {
      selectedFullBodyUrl = image.path;
      update();
    }
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

  void manageVideoPlayer() {
    videoController?.value.isPlaying == true ? videoController?.pause() : videoController?.play();
    update();
  }

  Future<void> updateUser() async {
    isLoading = true;
    update();

    await userRepository.updateUser({
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'fullName': '${firstNameController.text} ${lastNameController.text}',
      'headShotImage': selectedHeadShotUrl != null
          ? selectedHeadShotUrl.toString().contains('http')
              ? selectedHeadShotUrl
              : await authRepository.uploadToFirebase(File(selectedHeadShotUrl!), isHeadShot: true)
          : null,
      'fullBodyImage': selectedFullBodyUrl != null
          ? selectedFullBodyUrl.toString().contains('http')
              ? selectedFullBodyUrl.toString()
              : await authRepository.uploadToFirebase(File(selectedFullBodyUrl!))
          : null,
      'introductionVideo': videoPath != null
          ? videoPath.toString().contains('http')
              ? videoPath.toString()
              : await authRepository.uploadToFirebase(File(videoPath!), isVideo: true)
          : null,
      'dateOfBirth': birthDateTime?.toString(),
    });
    "User updated successfully".showSuccessToast();
    Get.back(result: true);
    isLoading = false;
    update();
  }

  Future<void> registerUser() async {
    try {
      isLoading = true;
      update();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      'fcmToken --> $fcmToken'.logs();
      final UserModel userModel = UserModel(
        userId: FirebaseAuth.instance.currentUser?.uid,
        firstName: firstNameController.text,
        fcmToken: fcmToken,
        lastName: lastNameController.text,
        fullName: '${firstNameController.text} ${lastNameController.text}',
        dateOfBirth: birthDateTime,
        olderAge: selectedOlderAge,
        youngerAge: selectedYoungerAge,
        email: FirebaseAuth.instance.currentUser?.email,
        gender: ListConstant.genderList[selectedGenderIndex],
        partnerPrefs: selectedPartnerGenderIndex.map((index) => ListConstant.genderList[index]).toList(),
        userLocation: UserLocation(country: countryController.text, state: stateController.text, city: cityController.text),
        relocation: selectedRelocationType.map((index) => ListConstant.relocationList[index]).toList(),
        childPref: ChildPreference(
          iHave: [ListConstant.childPreIHaveList[selectedIHavePreference!]],
          iWant: [ListConstant.childPreIWantList[selectedIWantPreference!]],
        ),
        userCoins: 100,
        headShotImage: selectedHeadShotUrl != null ? await authRepository.uploadToFirebase(File(selectedHeadShotUrl!), isHeadShot: true) : null,
        fullBodyImage: selectedFullBodyUrl != null ? await authRepository.uploadToFirebase(File(selectedFullBodyUrl!)) : null,
        introductionVideo: videoPath != null ? await authRepository.uploadToFirebase(File(videoPath), isVideo: true) : null,
        subscription: SubscriptionPlan(),
      );

      'User model --> ${userModel.toMap()}'.infoLogs();

      final bool isUserCreated = await userRepository.updateUser(userModel.toMap());

      if (isUserCreated) {
        'User created successfully'.showSuccessToast();
        RouteHelper.instance.gotoDashboard();
      }
    } catch (e) {
      'Error: $e'.errorLogs();
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getCountries() async {
    try {
      isLoading = true;
      update();
      final response = await RestServices.instance.getRestCall(endpoint: '');
      if (response != null && response.isNotEmpty) {
        final List<dynamic> responseMap = jsonDecode(response);
        countryModel = responseMap.map((e) => CountryModel.fromJson(e)).toList();
        countryList.addAll(countryModel.map((e) => e.name ?? '').toList());
      }
      stateList = [];
      cityList = [];
    } on SocketException catch (e) {
      'Catch SocketException in getCountries --> ${e.message}'.errorLogs();
    }
    isLoading = false;
    update();
  }

  Future<void> getStates() async {
    try {
      isLoading = true;
      update();
      final String? country = countryModel.firstWhere((element) => element.name == countryController.text).iso2;
      final response = await RestServices.instance.getRestCall(endpoint: '${country ?? ''}/states');
      if (response != null && response.isNotEmpty) {
        final List<dynamic> responseMap = jsonDecode(response);
        stateModel = responseMap.map((e) => StatModel.fromJson(e)).toList();
        stateList.addAll(stateModel.map((e) => e.name ?? '').toList());
      }
      cityList = [];
    } on SocketException catch (e) {
      'Catch SocketException in getStates --> ${e.message}'.errorLogs();
    }
    isLoading = false;
    update();
  }

  Future<void> getCity() async {
    try {
      isLoading = true;
      update();
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
    isLoading = false;
    update();
  }
}

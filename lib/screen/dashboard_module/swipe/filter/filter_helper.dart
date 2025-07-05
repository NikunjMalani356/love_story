import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/helper/rest_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/screen/dashboard_module/swipe/filter/filter_screen.dart';
import 'package:love_story_unicorn/serialized/country_model.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';

class FilterScreenHelper {
  FilterScreenState state;
  int? selectedGenderIndex;
  List<int> selectedPartnerGenderIndex = [];
  List<int> selectedRelocationType = [];
  List<int> selectedWantChildPreference = [];
  List<int> selectedHaveChildPreference = [];
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  String? selectedOlderAge;
  String? selectedYoungerAge;
  List<String> countryList = [];
  List<CountryModel> countryModel = [];
  List<String> stateList = [];
  List<StatModel> stateModel = [];
  RangeValues currentAgeRange = const RangeValues(20, 28);
  bool isLoading = false;
  ScrollController scrollController=ScrollController();
  UserModel? existingData;

  FilterScreenHelper(this.state) {
    Future.delayed(const Duration(milliseconds: 100), () async {
      getUserDetails();
    });
  }

  Future<void> getUserDetails() async {
    existingData = await state.filterController?.userRepository.getUserData();
    if (existingData != null) {
      selectedGenderIndex = ListConstant.genderList.indexOf(existingData?.gender ?? '');
      selectedPartnerGenderIndex = existingData!.partnerPrefs.map((gender) => ListConstant.genderList.indexOf(gender)).toList();
      selectedOlderAge = existingData?.olderAge;
      selectedYoungerAge = existingData?.youngerAge;
      countryController.text = existingData?.userLocation?.country ?? '';
      stateController.text = existingData?.userLocation?.state ?? '';
      selectedHaveChildPreference = existingData!.childPref!.iHave!.map((item) => ListConstant.childPreIHaveList.indexOf(item)).toList();
      selectedWantChildPreference = existingData!.childPref!.iWant!.map((item) => ListConstant.childPreIWantList.indexOf(item)).toList();
      selectedRelocationType = existingData?.relocation?.map((item) => ListConstant.relocationList.indexOf(item)).toList() ?? [];
      await getCountries();
      await getStates();
      log("existingData --> ${jsonEncode(existingData)}");
      updateState();
    }
  }

  void updateState() => state.filterController?.update();

  void managePartnerGender(int index) {
    if (selectedPartnerGenderIndex.contains(index)) {
      selectedPartnerGenderIndex.remove(index);
    } else {
      selectedPartnerGenderIndex.add(index);
    }
    updateState();
  }

  Future<void> selectedCountry(String value) async {
    countryController.text = value;
    await getStates();
    updateState();
  }

  void onCountryTap() {
    countryController.clear();
    stateController.clear();
    manageListScroll();
  }

  void manageListScroll() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> selectedState(String value) async {
    stateController.text = value;
    updateState();
  }

  void onStateTap() => stateController.clear();

  void manageRelocation(int index) {
    if (selectedRelocationType.contains(index)) {
      selectedRelocationType.clear();
    } else {
      selectedRelocationType.clear();
      selectedRelocationType.add(index);
    }
    updateState();
  }

  void manageChildPref(int index, int category) {
    if (category == 0) {
      selectedWantChildPreference.clear();
      selectedWantChildPreference.add(index);
    } else if (category == 1) {
      selectedHaveChildPreference.clear();
      selectedHaveChildPreference.add(index);
    }
    updateState();
  }

  Future<void> updateFilterData() async {
    try {
      if (countryList.contains(countryController.text) == false) {
        'Selected Country is invalid'.showErrorToast();
        return;
      } else if (stateList.contains(stateController.text) == false) {
        'Selected State is invalid '.showErrorToast();
        return;
      }
      isLoading = true;
      updateState();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      final filterUpdateData = {
        'gender': (selectedGenderIndex != null && selectedGenderIndex! >= 0 && selectedGenderIndex! < ListConstant.genderList.length) ? ListConstant.genderList[selectedGenderIndex!] : existingData?.gender,
        'partnerPrefs': selectedPartnerGenderIndex.where((index) => index >= 0 && index < ListConstant.genderList.length).map((index) => ListConstant.genderList[index]).toList(),
        'olderAge': selectedOlderAge ?? existingData?.olderAge,
        'youngerAge': selectedYoungerAge ?? existingData?.youngerAge,
        'userLocation': {
          'country': countryController.text.isNotEmpty ? countryController.text : existingData?.userLocation?.country,
          'state': stateController.text.isNotEmpty ? stateController.text : existingData?.userLocation?.state,
          'city': '',
        },
        'relocation': selectedRelocationType.where((index) => index >= 0 && index < ListConstant.relocationList.length).map((index) => ListConstant.relocationList[index]).toList(),
        'childPref': {
          'iHave': selectedHaveChildPreference.where((index) => index >= 0 && index < ListConstant.childPreIHaveList.length).map((index) => ListConstant.childPreIHaveList[index]).toList(),
          'iWant': selectedWantChildPreference.where((index) => index >= 0 && index < ListConstant.childPreIWantList.length).map((index) => ListConstant.childPreIWantList[index]).toList(),
        },
      };
      final bool? isUpdated = await state.filterController?.userRepository.updateMultiData(filterUpdateData);
      if (isUpdated == true) {
        "Filter preferences updated successfully".showSuccessToast();
        RouteHelper.instance.gotoDashboard();
      }
    } catch (error) {
      'Error updating filter data: $error'.errorLogs();
    }
    isLoading = false;
    updateState();
  }

  Future<void> getCountries() async {
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
      isLoading = true;
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
    isLoading = false;
    updateState();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_drop_down.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/app/widgets/app_search_text_form_field.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/filter_controller.dart';
import 'package:love_story_unicorn/screen/dashboard_module/swipe/filter/filter_helper.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => FilterScreenState();
}

class FilterScreenState extends State<FilterScreen> {
  FilterScreenHelper? filterScreenHelper;
  FilterController? filterController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    filterScreenHelper ??= FilterScreenHelper(this);

    return GetBuilder(
      init: FilterController(),
      builder: (FilterController controller) {
        filterController = controller;
        return Scaffold(
          body: Stack(
            children: [
              AppBackground(
                suffixTitle: StringConstant.save,
                showSuffixIcon: true,
                onSuffixTap: () => filterScreenHelper?.updateFilterData(),
                child: buildBodyView(),
              ),
              if (filterScreenHelper?.isLoading ?? false) const AppLoader(),
            ],
          ),
        );
      },
    );
  }

  Widget buildBodyView() {
    return Column(
      children: [
        const SizedBox(height: Dimens.heightLarge),
        Expanded(
          child: ListView(
            controller: filterScreenHelper?.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLargeMedium),
            children: [
              buildGenderFilter(),
              buildAgeFilter(),
              buildLocationFilter(),
              buildChildFilter(),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildGenderFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          StringConstant.iam,
          color: AppColorConstant.appWhite,
          fontSize: Dimens.textSizeExtraLarge,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Column(
          children: List.generate(
            ListConstant.genderList.length,
            (index) {
              final bool isSelected = index == filterScreenHelper?.selectedGenderIndex;
              return AppButton(
                suffixIcon: isSelected ? AppAsset.icCheck : null,
                margin: const EdgeInsets.symmetric(vertical: DimensPadding.paddingSmallMedium),
                title: ListConstant.genderList[index],
                color: isSelected ? AppColorConstant.appBlack : AppColorConstant.appWhite,
                fontColor: isSelected ? AppColorConstant.appWhite : AppColorConstant.appBlack,
                padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
                border: Border.all(color: Colors.transparent),
                fontSize: Dimens.textSizeLarge,
                onTap: () {
                  filterScreenHelper?.selectedGenderIndex = index;
                  filterController?.update();
                },
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        const AppText(
          StringConstant.looking,
          color: AppColorConstant.appWhite,
          fontSize: Dimens.textSizeExtraLarge,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Column(
          children: List.generate(
            ListConstant.genderList.length,
            (index) {
              final bool isSelected = filterScreenHelper!.selectedPartnerGenderIndex.contains(index);
              return AppButton(
                suffixIcon: isSelected ? AppAsset.icCheck : null,
                margin: const EdgeInsets.symmetric(vertical: DimensPadding.paddingSmallMedium),
                title: ListConstant.genderList[index],
                color: isSelected ? AppColorConstant.appBlack : AppColorConstant.appWhite,
                fontColor: isSelected ? AppColorConstant.appWhite : AppColorConstant.appBlack,
                padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
                border: Border.all(color: Colors.transparent),
                fontSize: Dimens.textSizeLarge,
                onTap: () => filterScreenHelper?.managePartnerGender(index),
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
      ],
    );
  }

  Widget buildAgeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          StringConstant.ageFilter,
          color: AppColorConstant.appWhite,
          fontSize: Dimens.textSizeExtraLarge,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        const AppText(
          StringConstant.maxAgeOlder,
          color: AppColorConstant.appWhite,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        AppDropdown<String>(
          items: ListConstant.olderAges,
          selectedValue: filterScreenHelper?.selectedOlderAge,
          hint: StringConstant.selectMaxOlder,
          onChanged: (newValue) {
            filterScreenHelper?.selectedOlderAge = newValue ?? '0';
            filterController?.update();
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        const AppText(
          StringConstant.maxAgeYounger,
          color: AppColorConstant.appWhite,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        AppDropdown<String>(
          items: ListConstant.youngerAges,
          selectedValue: filterScreenHelper?.selectedYoungerAge,
          hint: StringConstant.selectMaxYounger,
          onChanged: (newValue) {
            filterScreenHelper?.selectedYoungerAge = newValue ?? '0';
            filterController?.update();
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
      ],
    );
  }

  Widget buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          ListConstant.basicDetailTitle[2],
          color: AppColorConstant.appWhite,
          fontSize: Dimens.textSizeExtraLarge,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        const AppText(
          StringConstant.iAmIn,
          color: AppColorConstant.appWhite,
          fontSize: Dimens.textSizeSemiLarge,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        AppSearchTextFormField(
          onTap: () => filterScreenHelper?.onCountryTap(),
          headerText: StringConstant.countryName,
          hintText: StringConstant.countryName,
          controller: filterScreenHelper?.countryController,
          onSuggestionSelected: (value) => filterScreenHelper?.selectedCountry(value),
          suggestionsCallback: filterScreenHelper!.countryList,
        ),
        const SizedBox(height: 16),
        AppSearchTextFormField(
          onTap: () => filterScreenHelper?.onStateTap(),
          headerText: StringConstant.stateName,
          hintText: StringConstant.stateName,
          controller: filterScreenHelper?.stateController,
          onSuggestionSelected: (value) => filterScreenHelper?.selectedState(value),
          suggestionsCallback: filterScreenHelper!.stateList,
        ),
        const SizedBox(height: 16),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        const AppText(
          "where you'd relocate for a partner?",
          color: AppColorConstant.appWhite,
          fontSize: Dimens.textSizeSemiLarge,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Column(
          children: List.generate(
            ListConstant.relocationList.length,
            (index) {
              final bool isSelected = filterScreenHelper!.selectedRelocationType.contains(index);
              return AppButton(
                suffixIcon: isSelected ? AppAsset.icCheck : null,
                margin: const EdgeInsets.symmetric(vertical: DimensPadding.paddingSmallMedium),
                title: ListConstant.relocationList[index],
                color: isSelected ? AppColorConstant.appBlack : AppColorConstant.appWhite,
                fontColor: isSelected ? AppColorConstant.appWhite : AppColorConstant.appBlack,
                padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
                border: Border.all(color: Colors.transparent),
                fontSize: Dimens.textSizeLarge,
                onTap: () => filterScreenHelper?.manageRelocation(index),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
      ],
    );
  }

  Widget buildChildFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          ListConstant.basicDetailTitle[4],
          color: AppColorConstant.appWhite,
          fontSize: Dimens.textSizeExtraLarge,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        const AppText(
          StringConstant.iWant,
          color: AppColorConstant.appWhite,
          fontSize: Dimens.textSizeVeryLarge,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Column(
          children: List.generate(
            ListConstant.childPreIWantList.length,
            (index) {
              final bool isSelected = filterScreenHelper!.selectedWantChildPreference.contains(index);
              return AppButton(
                suffixIcon: isSelected ? AppAsset.icCheck : null,
                margin: const EdgeInsets.symmetric(vertical: DimensPadding.paddingSmallMedium),
                title: ListConstant.childPreIWantList[index],
                color: isSelected ? AppColorConstant.appBlack : AppColorConstant.appWhite,
                fontColor: isSelected ? AppColorConstant.appWhite : AppColorConstant.appBlack,
                padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
                border: Border.all(color: Colors.transparent),
                fontSize: Dimens.textSizeLarge,
                onTap: () => filterScreenHelper?.manageChildPref(index, 0),
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        const AppText(
          StringConstant.iHave,
          color: AppColorConstant.appWhite,
          fontSize: Dimens.textSizeVeryLarge,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Column(
          children: List.generate(
            ListConstant.childPreIHaveList.length,
            (index) {
              final bool isSelected = filterScreenHelper!.selectedHaveChildPreference.contains(index);
              return AppButton(
                suffixIcon: isSelected ? AppAsset.icCheck : null,
                margin: const EdgeInsets.symmetric(vertical: DimensPadding.paddingSmallMedium),
                title: ListConstant.childPreIHaveList[index],
                color: isSelected ? AppColorConstant.appBlack : AppColorConstant.appWhite,
                fontColor: isSelected ? AppColorConstant.appWhite : AppColorConstant.appBlack,
                padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
                border: Border.all(color: Colors.transparent),
                fontSize: Dimens.textSizeLarge,
                onTap: () => filterScreenHelper?.manageChildPref(index, 1),
              );
            },
          ),
        ),
      ],
    );
  }
}

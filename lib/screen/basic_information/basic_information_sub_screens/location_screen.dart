import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_search_text_form_field.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/basic_information_controller.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    return GetBuilder<BasicInformationController>(
      init: BasicInformationController(),
      builder: (controller) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLargeMedium),
          children: [
            const SizedBox(height: Dimens.heightLarge),
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
              fontSize: Dimens.textSizeVeryLarge,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            AppSearchTextFormField(
              headerText: StringConstant.countryName,
              controller: controller.countryController,
              errorText: controller.countryError,
              hintText: StringConstant.countryName,
              onSuggestionSelected: (value) => controller.selectedCountry(value),
              suggestionsCallback: controller.countryList,
              onTap: () => controller.countryOnTap(),
              onChanged: (value) => controller.onChangeCountry(value),
            ),
            const SizedBox(height: 16),
            AppSearchTextFormField(
              headerText: StringConstant.stateName,
              controller: controller.stateController,
              errorText: controller.stateError,
              hintText: StringConstant.stateName,
              onSuggestionSelected: (value) => controller.selectedState(value),
              suggestionsCallback: controller.stateList,
              onTap: () => controller.stateOnTap(),
              onChanged: (value) => controller.onChangeState(value),
            ),
            const SizedBox(height: 16),
            AppSearchTextFormField(
              headerText: StringConstant.cityName,
              controller: controller.cityController,
              errorText: controller.cityError,
              hintText: StringConstant.cityName,
              onSuggestionSelected: (value) => controller.selectedCity(value),
              suggestionsCallback: controller.cityList,
              onTap: () => controller.cityController.clear(),
              onChanged: (value) {
                controller.cityError = '';
                controller.update();
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            AppButton(
              title: StringConstant.continueText,
              onTap: () => controller.validateYourLocation(),
            ),
          ],
        );
      },
    );
  }
}

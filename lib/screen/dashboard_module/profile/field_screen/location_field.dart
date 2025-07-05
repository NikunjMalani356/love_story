import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_search_text_form_field.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/profile_controller.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/profile_screen_helper.dart';

class LocationField extends StatefulWidget {
  final ProfileScreenHelper? helper;
  final ProfileController? profileController;

  const LocationField({super.key, this.helper, this.profileController});

  @override
  State<LocationField> createState() => LocationFieldState();
}

class LocationFieldState extends State<LocationField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              StringConstant.location,
              fontSize: Dimens.size20,
              fontWeight: FontWeight.w700,
              color: AppColorConstant.appWhite,
            ),
            if (widget.helper?.isLocationTap == false) InkWell(onTap: () => widget.helper?.onLocationTap(), child: const Icon(Icons.edit, color: AppColorConstant.appWhite)),
          ],
        ),
        if (widget.helper?.isLocationTap == false)
          Wrap(
            children: [
              if (widget.helper?.cityController.text != null && widget.helper?.cityController.text != "") AppText("${widget.helper?.cityController.text}, ", color: AppColorConstant.appWhite),
              AppText("${widget.helper?.stateController.text}, ", color: AppColorConstant.appWhite),
              AppText("${widget.helper?.countryController.text}", color: AppColorConstant.appWhite),
            ],
          ),
        if (widget.helper?.isLocationTap == true) ...[
          AppSearchTextFormField(
            onTap: () => widget.helper?.onCountryTap(),
            headerText: StringConstant.countryName,
            hintText: StringConstant.countryName,
            controller: widget.helper?.countryController,
            onSuggestionSelected: (value) => widget.helper?.selectedCountry(value),
            suggestionsCallback: widget.helper?.countryList ?? [],
          ),
          const SizedBox(height: DimensPadding.paddingSmall),
          buildErrorText(widget.helper?.countryError),
          if (widget.helper?.isLoadingLocation == true)
            buildLoading(StringConstant.stateName)
          else
            AppSearchTextFormField(
              onTap: () => widget.helper?.onStateTap(),
              headerText: StringConstant.stateName,
              hintText: StringConstant.stateName,
              controller: widget.helper?.stateController,
              onSuggestionSelected: (value) => widget.helper?.selectedState(value),
              suggestionsCallback: widget.helper?.stateList ?? [],
            ),
          const SizedBox(height: DimensPadding.paddingSmall),
          buildErrorText(widget.helper?.stateError),
          if (widget.helper?.isLoadingLocation == true) ...[
            buildLoading(StringConstant.cityName),
          ] else
            AppSearchTextFormField(
              onTap: () => widget.helper?.onCityTap(),
              headerText: StringConstant.cityName,
              hintText: StringConstant.cityName,
              controller: widget.helper?.cityController,
              onSuggestionSelected: (value) => widget.helper?.selectedCity(value),
              suggestionsCallback: widget.helper?.cityList ?? [],
            ),
          const SizedBox(height: DimensPadding.paddingSmall),
          buildErrorText(widget.helper?.cityError),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              width: Dimens.widthLarge,
              height: Dimens.heightMedium,
              title: StringConstant.save,
              onTap: () => widget.helper?.manageLocation(),
            ),
          ),
        ],
      ],
    );
  }

  Widget buildLoading(String? text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(text ?? '', color: AppColorConstant.appWhite, fontWeight: FontWeight.w600),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Container(
          height: Dimens.heightLarge,
          width: Get.width,
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColorConstant.appWhite,
            borderRadius: BorderRadius.circular(Dimens.borderRadiusRegular),
          ),
          child: const CircularProgressIndicator(color: AppColorConstant.appBlack),
        ),
      ],
    );
  }

  Widget buildErrorText(String? errorText) {
    return errorText == null ? const SizedBox.shrink() : AppText(errorText, color: AppColorConstant.appWhite, fontSize: Dimens.textSizeSmall);
  }
}

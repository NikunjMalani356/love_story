import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/app/widgets/app_text_form_field.dart';
import 'package:love_story_unicorn/controller/basic_information_controller.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:video_player/video_player.dart';

class NameScreen extends StatelessWidget {
  const NameScreen();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BasicInformationController(),
      builder: (BasicInformationController controller) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLarge),
          children: [
            const SizedBox(height: Dimens.heightLarge),
            AppText(controller.arguments.isEmpty ? StringConstant.profileDetails : StringConstant.editProfile, textAlign: TextAlign.center, fontSize: Dimens.textSizeExtraLarge, fontWeight: FontWeight.w700),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            buildImagesView(controller, context),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            AppText(StringConstant.firstName, color: AppColorConstant.appBlack.withOpacity(0.8)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            AppTextFormField(hintText: StringConstant.enterFirstName, controller: controller.firstNameController, errorText: controller.nameError),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            AppText(StringConstant.lastName, color: AppColorConstant.appBlack.withOpacity(0.8)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            AppTextFormField(hintText: StringConstant.enterLastName, controller: controller.lastNameController, errorText: controller.lastNameError),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            buildCalenderView(context, controller),
            if(controller.dobError.isNotEmpty) AppText(controller.dobError, color: AppColorConstant.appWhite,fontSize: 12),
            buildAgeDisplay(controller),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            const AppText(StringConstant.introVideo, fontSize: Dimens.size20, fontWeight: FontWeight.w600),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            buildVideoView(controller, context),
            // SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            // const AppText(StringConstant.connectedAccounts, fontSize: Dimens.size20, fontWeight: FontWeight.w600),
            // SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            // const AppText(StringConstant.connectYourInstagram),
            // buildAccountView(context),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            AppButton(
              title: controller.arguments['isEdit'] != null  ? StringConstant.save : StringConstant.continueText,
              onTap: () => controller.profileValidation(),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          ],
        );
      },
    );
  }

  Widget buildAgeDisplay(BasicInformationController controller) {
    if (controller.age != null) {
      final List<String> ageParts = [];
      if ((controller.age?.years ?? 0) > 0) {
        ageParts.add('${controller.age?.years} year${(controller.age?.years ?? 0) > 1 ? 's' : ''}');
      }
      if ((controller.age?.month ?? 0) > 0) {
        ageParts.add('${controller.age?.month} month${(controller.age?.month ?? 0) > 1 ? 's' : ''}');
      }
      if ((controller.age?.day ?? 0) > 0) {
        ageParts.add('${controller.age?.day} day${(controller.age?.day ?? 0) > 1 ? 's' : ''}');
      }
      final String ageText = 'Age: ${ageParts.join(', ')}';
      return Padding(
        padding: const EdgeInsets.only(top: DimensPadding.paddingTiny),
        child: AppText(
          ageText,
          textAlign: TextAlign.center,
          color: AppColorConstant.appBlack.withOpacity(0.8),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget buildAccountView(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: Dimens.widthLarge,
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
        padding: const EdgeInsets.all(DimensPadding.paddingNormal),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColorConstant.appWhite.withOpacity(0.2),
          borderRadius: BorderRadius.circular(
            Dimens.borderRadiusRegular,
          ),
          border: Border.all(width: 2),
        ),
        child: const AppImageAsset(
          image: AppAsset.icInstagram,
          height: Dimens.heightMedium,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildCalenderView(BuildContext context, BasicInformationController controller) {
    return InkWell(
      onTap: () => showCalendarBottomSheet(context, controller),
      child: Container(
        height: Dimens.heightLarge,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
        decoration: BoxDecoration(color: AppColorConstant.appBlack.withOpacity(0.2), borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium)),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppImageAsset(image: AppAsset.icCalendar),
            AppText(
              controller.birthDateTime != null ? DateFormat('dd-MM-yyyy').format(controller.birthDateTime ?? DateTime.now()) : StringConstant.selectDob,
            ),
            const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget buildVideoView(BasicInformationController controller, BuildContext context) {
    return Column(
      children: [
        if (controller.videoController != null && controller.videoController!.value.isInitialized)
          Align(
            child: InkWell(onTap: () {
              if(controller.videoController?.value.isPlaying == true) {
                controller.manageVideoPlayer();
              }
            },
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    child: AspectRatio(
                      aspectRatio: controller.videoController!.value.aspectRatio,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                        child: VideoPlayer(controller.videoController!),
                      ),
                    ),
                  ),
                  if(controller.videoController?.value.isPlaying != true)InkWell(
                    onTap: () => controller.manageVideoPlayer(),
                    child: const AppImageAsset(
                      image: AppAsset.icPlay,
                      height: Dimens.heightMedium,
                      width: Dimens.heightMedium,
                    ),
                  ),
                  Positioned(
                    bottom: -8,
                    right: -10,
                    child: buildCameraView(
                      controller,
                      context,
                      onTap: () => controller.pickIntroVideo(),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            height: MediaQuery.of(context).size.width * 0.35,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.borderRadiusLarge),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.width * 0.35,
                    color: AppColorConstant.appWhite,
                    child: const AppImageAsset(
                      image: AppAsset.signUpUnicorn,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -8,
                  right: -10,
                  child: buildCameraView(
                    controller,
                    context,
                    onTap: () => controller.pickIntroVideo(),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
          child: AppText(
            StringConstant.fiveToThirtySecond,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget buildImagesView(BasicInformationController controller, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.borderRadiusLarge),
                    child: Container(
                      color: AppColorConstant.appWhite,
                      padding: const EdgeInsets.all(DimensPadding.paddingTiny),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimens.borderRadiusLarge),
                          child: AppImageAsset(
                            cachingKey: DateTime.now().microsecondsSinceEpoch.toString(),
                            image: controller.selectedHeadShotUrl ?? AppAsset.signUpUnicorn,
                            fit: BoxFit.cover,
                            isFile: controller.selectedHeadShotUrl != null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(bottom: -8, right: -3, child: buildCameraView(controller, context, onTap: () => controller.pickHeadShot())),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.005),
              const AppText(StringConstant.headshot, fontWeight: FontWeight.w700),
            ],
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.15),
        Expanded(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.borderRadiusLarge),
                    child: Container(
                      color: AppColorConstant.appWhite,
                      padding: const EdgeInsets.all(DimensPadding.paddingTiny),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimens.borderRadiusLarge),
                          child: AppImageAsset(
                            cachingKey: DateTime.now().microsecondsSinceEpoch.toString(),
                            image: controller.selectedFullBodyUrl ?? AppAsset.signUpUnicorn,
                            fit: BoxFit.cover,
                            isFile: controller.selectedFullBodyUrl != null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(bottom: -8, right: -3, child: buildCameraView(controller, context, onTap: () => controller.pickFullBody())),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.005),
              const AppText(StringConstant.fullBody, fontWeight: FontWeight.w700),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCameraView(BasicInformationController controller, BuildContext context, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DimensPadding.paddingSmallNormal),
        decoration: BoxDecoration(color: AppColorConstant.appErrorColor, border: Border.all(color: AppColorConstant.appWhite, width: 3), shape: BoxShape.circle),
        child: const AppImageAsset(image: AppAsset.icCamera),
      ),
    );
  }

  void showCalendarBottomSheet(BuildContext context, BasicInformationController basicController) {
    final DateTime today = DateTime.now();
    DateTime? temporaryDate = basicController.birthDateTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppText(
                StringConstant.selectDob,
                fontSize: Dimens.textSizeVeryLarge,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              GetBuilder<BasicInformationController>(
                builder: (controller) => TableCalendar(
                  focusedDay: temporaryDate ?? DateTime(controller.selectedYear, today.month, today.day),
                  firstDay: DateTime(today.year - 100, today.month, today.day),
                  lastDay: DateTime(today.year - 18, today.month, today.day),
                  selectedDayPredicate: (day) {
                    return temporaryDate != null && isSameDay(temporaryDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    temporaryDate = selectedDay;
                    controller.update();
                  },
                  onPageChanged: (focusedDay) {
                    temporaryDate = focusedDay;
                    controller.updateYear(focusedDay.year);
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColorConstant.appBlack,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColorConstant.appGreenColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 0),
                  ),
                  calendarBuilders: CalendarBuilders(
                    headerTitleBuilder: (context, day) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: Dimens.widthXLarge,
                            padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingSmallNormal),
                            child: DropdownButtonFormField<String>(
                              value: DateFormat('MMMM').format(day),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (newMonth) {
                                if (newMonth != null) {
                                  final selectedMonth = DateFormat('MMMM').parse(newMonth).month;
                                  temporaryDate = DateTime(
                                    temporaryDate?.year ?? controller.selectedYear,
                                    selectedMonth,
                                    temporaryDate?.day ?? 1,
                                  );
                                  controller.update();
                                }
                              },
                              items: List.generate(12, (index) {
                                final month = DateFormat('MMMM').format(DateTime(0, index + 1));
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(month),
                                );
                              }),
                            ),
                          ),
                          Container(
                            width: Dimens.widthLarge,
                            padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingSmallNormal),
                            child: DropdownButtonFormField<int>(
                              value: temporaryDate?.year ?? controller.selectedYear,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              items: controller.yearList.map((year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                );
                              }).toList(),
                              onChanged: (year) {
                                if (year != null) {
                                  temporaryDate = DateTime(
                                    year,
                                    temporaryDate?.month ?? today.month,
                                    temporaryDate?.day ?? today.day,
                                  );
                                  controller.updateYear(year);
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                onTap: () {
                  if (temporaryDate != null) {
                    basicController.updateSelectedDate(temporaryDate!);
                  }
                  Get.back();
                },
                title: StringConstant.save,
              ),
            ],
          ),
        );
      },
    );
  }
}

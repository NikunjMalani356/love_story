import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/term_and_condition_controller.dart';
import 'package:love_story_unicorn/screen/term_and_condition/term_and_condition_helper.dart';
import 'package:love_story_unicorn/serialized/privacy_terms_model.dart';

class TermAndConditionScreen extends StatefulWidget {
  const TermAndConditionScreen({super.key});

  @override
  State<TermAndConditionScreen> createState() => TermAndConditionScreenState();
}

class TermAndConditionScreenState extends State<TermAndConditionScreen> {
  TermAndConditionHelper? termAndConditionHelper;
  TermConditionController? termConditionController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    termAndConditionHelper ??= TermAndConditionHelper(this);
    return GetBuilder<TermConditionController>(
      init: TermConditionController(),
      builder: (TermConditionController controller) {
        termConditionController = controller;
        return Scaffold(
          body: AppBackground(
            child: termAndConditionHelper?.isLoading ?? true
                ? const AppLoader()
                : Column(
                    children: [
                      const SizedBox(height: Dimens.heightLarge),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: termAndConditionHelper?.contentData?.sections?.length ?? 0,
                          itemBuilder: (context, index) {
                            final section = termAndConditionHelper?.contentData!.sections?[index];
                            return section != null ? buildSection(section) : const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget buildSection(SectionModel section) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            section.title!,
            fontWeight: FontWeight.bold,
            fontSize: Dimens.textSizeVeryLarge,
            color: AppColorConstant.appWhite,
          ),
          const SizedBox(height: 8),
          if (section.content != null)
            AppText(
              section.content!,
              color: AppColorConstant.appWhite,
            ),
          if (section.points != null) ...buildPointsList(section.points!),
          if (section.subsections != null) ...buildSubsectionsList(section.subsections!),
          if (section.note != null)
            AppText(
              section.note!,
              color: AppColorConstant.appWhite,
            ),
        ],
      ),
    );
  }

// Updated buildPointsList
  List<Widget> buildPointsList(List<String> points) {
    return points.map((point) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              "${points.indexOf(point) + 1}. ",  // Corrected here
              color: AppColorConstant.appWhite,
            ),
            Expanded(
              child: AppText(
                point,
                color: AppColorConstant.appWhite,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> buildSubsectionsList(List<SubSectionModel> subsections) {
    return subsections.map((subsection) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              subsection.title!,
              color: AppColorConstant.appWhite,
              fontSize: Dimens.size20,
              fontWeight: FontWeight.bold,
            ),
            if (subsection.content != null)
              AppText(
                subsection.content!,
                color: AppColorConstant.appWhite,
              ),
            if (subsection.points != null) ...buildPointsList(subsection.points!),
          ],
        ),
      );
    }).toList();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_drop_down.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/app/widgets/app_text_form_field.dart';
import 'package:love_story_unicorn/controller/mandatory_question_controller.dart';
import 'package:love_story_unicorn/screen/mandatory_question/mandatory_question_helper.dart';
import 'package:love_story_unicorn/serialized/question_model.dart';

class MandatoryQuestionScreen extends StatefulWidget {
  const MandatoryQuestionScreen({super.key});

  @override
  State<MandatoryQuestionScreen> createState() => MandatoryQuestionScreenState();
}

class MandatoryQuestionScreenState extends State<MandatoryQuestionScreen> {
  MandatoryQuestionScreenHelper? mandatoryQuestionScreenHelper;
  MandatoryQuestionController? mandatoryQuestionController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    mandatoryQuestionScreenHelper ??= MandatoryQuestionScreenHelper(this);
    return GetBuilder(
      init: MandatoryQuestionController(),
      builder: (MandatoryQuestionController controller) {
        mandatoryQuestionController = controller;
        return Scaffold(
          body: AppBackground(
            showSuffixIcon: mandatoryQuestionScreenHelper?.showOptionalQuestions == false,
            suffixTitle: 'Save',
            onSuffixTap: () {
              FocusScope.of(context).unfocus();
              mandatoryQuestionScreenHelper?.manageSaveContinue(isSave: true);
            },
            titleColor: AppColorConstant.appWhite,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: DimensPadding.paddingFromBackArrow),
                    AppText(
                      mandatoryQuestionScreenHelper?.showOptionalQuestions == false
                          ? mandatoryQuestionScreenHelper?.isEdit ?? false
                              ? StringConstant.editMandatoryQuestion
                              : StringConstant.mandatoryQuestion
                          : mandatoryQuestionScreenHelper?.isEdit ?? false
                              ? StringConstant.editOptionalQuestion
                              : StringConstant.optionalQuestion,
                      fontSize: Dimens.textSizeSemiLarge,
                      fontWeight: FontWeight.w800,
                      color: AppColorConstant.appWhite,
                    ).paddingSymmetric(horizontal: DimensPadding.paddingExtraLarge),
                    const SizedBox(height: DimensPadding.paddingExtraLarge),
                    Expanded(
                      child: ListView.separated(
                        controller: mandatoryQuestionScreenHelper?.scrollController,
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLarge),
                        itemCount: (mandatoryQuestionScreenHelper?.showOptionalQuestions == false)
                            ? mandatoryQuestionController?.requiredQuestions.length ?? 0
                            : mandatoryQuestionController?.optionQuestions.length ?? 0,
                        itemBuilder: (context, index) {
                          final Question? question = (mandatoryQuestionScreenHelper?.showOptionalQuestions == false)
                              ? mandatoryQuestionController?.requiredQuestions[index]
                              : mandatoryQuestionController?.optionQuestions[index];
                          if (question == null) const SizedBox();
                          return buildQuestionWidget(
                            question,
                            onAnswerUpdate: (updatedAnswer) => mandatoryQuestionController?.updateAnswer(index, updatedAnswer),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: Dimens.heightNormal),
                      ),
                    ),
                    ColoredBox(
                      color: AppColorConstant.appPink,
                      child: AppButton(
                        margin: const EdgeInsets.symmetric(vertical: DimensPadding.paddingSmallMedium, horizontal: DimensPadding.paddingExtraLarge),
                        // title: (mandatoryQuestionController?.isRequiredAnswerGiven == false) ? StringConstant.saveAnswers : StringConstant.continueText,
                        title: StringConstant.continueText,
                        color: AppColorConstant.appWhite,
                        fontColor: AppColorConstant.appBlack,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          mandatoryQuestionScreenHelper?.manageSaveContinue();
                        },
                      ),
                    ),
                  ],
                ),
                if (mandatoryQuestionScreenHelper?.isLoading ?? true) const AppLoader(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> showConfirmationDialog(String message, String buttonTitle) async {
    bool result = false;

    await Get.dialog<bool>(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const AppText(StringConstant.confirmation, fontSize: Dimens.textSizeVeryLarge, fontWeight: FontWeight.w700),
            const SizedBox(height: Dimens.heightSmall),
            AppText(message, fontSize: Dimens.size20, textAlign: TextAlign.center),
            const SizedBox(height: Dimens.heightSmallMedium),
            const SizedBox(width: Dimens.heightSmall),
            AppButton(
              title: buttonTitle,
              onTap: () {
                result = true;
                Get.back(result: result);
              },
            ),
          ],
        ),
      ),
    );
    return result;
  }

  Widget buildQuestionWidget(Question? question, {required Function(String) onAnswerUpdate}) {
    if (question == null) return const SizedBox();
    switch (question.inputType) {
      case StringConstant.singleSelection:
        return buildSingleSelectionQuestion(question, onAnswerUpdate: onAnswerUpdate);
      case StringConstant.dropdown:
        return buildDropdownQuestion(question, onAnswerUpdate: onAnswerUpdate);
      case StringConstant.multiSelection:
        return buildMultiSelectionQuestion(
          question,
          onAnswerUpdate: (updatedAnswer) => onAnswerUpdate(updatedAnswer.join(', ')),
        );
      default:
        return buildTextQuestion(question, onAnswerUpdate: onAnswerUpdate);
    }
  }

  Widget buildSingleSelectionQuestion(
    Question question, {
    required Function(String) onAnswerUpdate,
  }) {
    String? selectedOption = question.answer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(question.question, color: AppColorConstant.appWhite),
        Column(
          children: question.answerOptions?.map((option) {
                final bool isSelected = selectedOption == option;
                return AppButton(
                  suffixIcon: AppAsset.icCheck,
                  margin: const EdgeInsets.only(top: DimensPadding.paddingSmallMedium),
                  title: option,
                  color: isSelected ? AppColorConstant.appBlack : AppColorConstant.appWhite,
                  fontColor: isSelected ? AppColorConstant.appWhite : AppColorConstant.appBlack,
                  padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
                  border: Border.all(color: Colors.transparent),
                  fontSize: Dimens.textSizeLarge,
                  onTap: () {
                    selectedOption = option;
                    onAnswerUpdate(option);
                  },
                );
              }).toList() ??
              [],
        ),
      ],
    );
  }

  Widget buildTextQuestion(Question question, {required Function(String) onAnswerUpdate}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(question.question, color: AppColorConstant.appWhite),
        const SizedBox(height: Dimens.heightSmall),
        AppTextFormField(
          controller: mandatoryQuestionController?.questionsController[mandatoryQuestionController?.questions.indexOf(question) ?? 0],
          isMaxLines: true,
          hintText: StringConstant.hintAnswer,
          textInputAction: (question==mandatoryQuestionController?.questions[mandatoryQuestionController!.questions.length-1])?TextInputAction.done:TextInputAction.next,
          onChanged: (text) {
            onAnswerUpdate(text);
            question.answer = text;
            mandatoryQuestionController?.update();
          },
        ),
      ],
    );
  }

  Widget buildDropdownQuestion(
    Question question, {
    required Function(String) onAnswerUpdate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(question.question, color: AppColorConstant.appWhite),
        const SizedBox(height: Dimens.heightSmall),
        AppDropdown<String>(
          items: question.answerOptions!,
          selectedValue: question.answer,
          hint: StringConstant.selectOption,
          onChanged: (value) {
            if (value is String) {
              question.answer = value;
              onAnswerUpdate(value);
            }
          },
        ),
      ],
    );
  }

  Widget buildMultiSelectionQuestion(
    Question question, {
    required Function(List<String>) onAnswerUpdate,
  }) {
    final List<String> selectedOptions = question.multiAnswer ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(question.question, color: AppColorConstant.appWhite),
        Column(
          children: question.answerOptions!.map((option) {
            final isSelected = selectedOptions.contains(option);
            return AppButton(
              title: option,
              color: isSelected ? AppColorConstant.appBlack : AppColorConstant.appWhite,
              fontColor: isSelected ? AppColorConstant.appWhite : AppColorConstant.appBlack,
              padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
              margin: const EdgeInsets.only(top: DimensPadding.paddingSmallMedium),
              fontSize: Dimens.textSizeLarge,
              border: Border.all(color: Colors.transparent),
              suffixIcon: AppAsset.icCheck,
              onTap: () {
                if (isSelected) {
                  selectedOptions.remove(option);
                } else {
                  selectedOptions.add(option);
                }
                question.multiAnswer = selectedOptions;
                onAnswerUpdate(selectedOptions);
                mandatoryQuestionController?.update();
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

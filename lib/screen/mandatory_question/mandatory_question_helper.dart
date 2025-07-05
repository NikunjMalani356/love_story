import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/screen/mandatory_question/mandatory_question_screen.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';

class MandatoryQuestionScreenHelper {
  MandatoryQuestionScreenState state;
  UserModel? userProfile;
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  bool isEdit = false;
  bool showOptionalQuestions = false;
  UserModel? currentUserData;

  MandatoryQuestionScreenHelper(this.state) {
    getProfile();
  }

  void updateState() => state.mandatoryQuestionController?.update();

  Future<void> getProfile() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      userProfile = Get.arguments['currentUser'];
      isEdit = Get.arguments['isEdit'];
      state.showConfirmationDialog(
        "your answers will be visible to your potential matches who are interested in getting to know you more.",
        StringConstant.okText,
      );
      currentUserData = await state.mandatoryQuestionController?.userRepository.getUserData(
        userId: FirebaseAuth.instance.currentUser?.uid,
      );
    });
  }

  Future<void> manageSaveContinue({bool isSave = false}) async {
    isLoading = true;
    updateState();
    if (showOptionalQuestions) {
      await saveOptionalQuestion();
    } else {
      await saveMandatoryQuestion(isSave: isSave);
    }
    isLoading = false;
    updateState();
  }

  bool validateMandatoryQuestions() {
    final bool isValidate = (state.mandatoryQuestionController?.requiredQuestions ?? []).every(
      (model) => !model.isRequired || (model.answer != null && (model.answer?.isNotEmpty == true)) || (model.multiAnswer != null && (model.multiAnswer?.isNotEmpty == true)),
    );
    'isValidate --> $isValidate'.logs();
    return isValidate;
  }

  Future<void> saveMandatoryQuestion({bool isSave = false}) async {
    final List<Map<String, dynamic>> questionAnswer = (state.mandatoryQuestionController?.requiredQuestions ?? []).map((question) {
      return {
        'question': question.question,
        'answer': question.inputType == StringConstant.multiSelection ? question.multiAnswer : question.answer,
      };
    }).toList();

    for (int i = 0; i < questionAnswer.length; i++) {
      final question = questionAnswer[i];
      if (!isSave && question['answer'] == null) {
        'Please fill answer all mandatory questions'.showErrorToast();
        return;
      }
    }

    'Mandatory QuestionAnswer --> $questionAnswer'.logs();
    state.mandatoryQuestionController?.existingAnswersData['mandatory'] = questionAnswer;
    await state.mandatoryQuestionController?.queAnsRepository.saveQuestionAns(state.mandatoryQuestionController?.existingAnswersData ?? {});
    'answers saved successfully'.showSuccess();
    if (validateMandatoryQuestions()) {
      final bool isShow = await state.showConfirmationDialog(StringConstant.mandatoryPopup, StringConstant.continueText);
      if (isShow) {
        await state.mandatoryQuestionController?.loadQuestionsFromJson();
        showOptionalQuestions = true;
        scrollController.jumpTo(0);
        updateState();
      } else {
        if (userProfile != null) {
          RouteHelper.instance.gotoPartnerOffPartnerImages(currentUser: userProfile);
        } else {
          RouteHelper.instance.gotoDashboard(index: 2);
        }
      }
    }
  }

  Future<void> saveOptionalQuestion() async {
    final List<Map<String, dynamic>> questionAnswer = (state.mandatoryQuestionController?.optionQuestions ?? []).map((question) {
      return {
        'question': question.question,
        'answer': question.inputType == StringConstant.multiSelection ? question.multiAnswer : question.answer,
      };
    }).toList();
    'Optional QuestionAnswer --> $questionAnswer'.logs();
    state.mandatoryQuestionController?.existingAnswersData['optional'] = questionAnswer;
    await state.mandatoryQuestionController?.queAnsRepository.saveQuestionAns(state.mandatoryQuestionController?.existingAnswersData ?? {});
    if (currentUserData?.likedUser?.any((element) => element.userId == userProfile?.userId) ?? false) {
      RouteHelper.instance.gotoPartnerProfile(currentUser: userProfile);
    }
    else if (userProfile != null) {
      RouteHelper.instance.gotoPartnerOffPartnerImages(currentUser: userProfile);
    } else {
      RouteHelper.instance.gotoDashboard(index: 2);
    }
  }
}

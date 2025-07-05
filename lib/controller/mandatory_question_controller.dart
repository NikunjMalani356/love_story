import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/que_ans/que_ans_repository.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';
import 'package:love_story_unicorn/repository/utills/utills_repository.dart';
import 'package:love_story_unicorn/serialized/question_model.dart';

class MandatoryQuestionController extends GetxController {
  List<Question> questions = [];
  List<TextEditingController> questionsController = [];
  List<Question> requiredQuestions = [];
  List<Question> optionQuestions = [];
  Map<String, dynamic> existingAnswersData = {};
  final QueAnsRepository queAnsRepository = getIt.get<QueAnsRepository>();
  final UserRepository userRepository = getIt.get<UserRepository>();
  final UtillsRepository utillsRepository = getIt.get<UtillsRepository>();
  bool isRequiredAnswerGiven = false;

  @override
  void onInit() {
    super.onInit();
    loadQuestionsFromJson();
  }

  Future<void> loadQuestionsFromJson() async {
    try {
      final Map<String, dynamic>? questionsData = await utillsRepository.getUtillsData('question_list');
      // final String jsonString = await rootBundle.loadString(AppAsset.questionJson);
      // final Map<String, dynamic> jsonData = json.decode(jsonString);
      if (questionsData?['questions_and_answers'] is List<dynamic>) {
        final List<dynamic> questionsJson = questionsData?['questions_and_answers'];

        existingAnswersData = await queAnsRepository.getQuestion() ?? {};

        'existingAnswersData --> $existingAnswersData'.logs();

        questions = questionsJson.map((e) => Question.fromJson(e)).toList();
        questionsController = List.generate(questions.length, (index) => TextEditingController());
        if (existingAnswersData.containsKey('mandatory')) {
          final List<dynamic>? existingAnswers = existingAnswersData[isRequiredAnswerGiven ? 'optional' : 'mandatory'] ?? [];
          if (existingAnswers == null) return;
          for (final question in questions) {
            final existingAnswer = existingAnswers.firstWhere((item) => item['question'] == question.question, orElse: () => null);
            if (existingAnswer != null) {
              if (existingAnswer['answer'] is String) {
                question.answer = existingAnswer['answer'];
                questionsController[questions.indexOf(question)].text = existingAnswer['answer'];
              } else if (existingAnswer['answer'] is List) {
                question.multiAnswer = List<String>.from(existingAnswer['answer']);
              }
            }
          }
        }
        requiredQuestions = questions.where((q) => q.isRequired == true).toList();
        optionQuestions = questions.where((q) => q.isRequired == false).toList();
        isRequiredAnswerGiven = requiredQuestions.every((model) => !model.isRequired || (model.answer != null && (model.answer?.isNotEmpty == true)) || (model.multiAnswer != null && (model.multiAnswer?.isNotEmpty == true)));
      } else {
        log("Invalid JSON structure: 'questions_and_answers' is not a list.");
      }
    } catch (e, stacktrace) {
      log("Error loading questions JSON: $e", error: e, stackTrace: stacktrace);
    } finally {
      update();
    }
  }

  void updateAnswer(int index, String answer) {
    if (index >= 0 && index < questions.length) {
      questions[index].answer = answer;
      update();
    } else {
      log("Invalid question index: $index");
    }
  }
}

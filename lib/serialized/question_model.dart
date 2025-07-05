import 'package:json_annotation/json_annotation.dart';

part 'question_model.g.dart';

@JsonSerializable()
class Question {
  @JsonKey(name: 'question')
  final String question;

  @JsonKey(name: 'input_type')
  final String inputType;

  @JsonKey(name: 'answer_options')
  final List<String>? answerOptions;

  @JsonKey(name: 'answer')
  String? answer;

  @JsonKey(name: 'multi_answer')
  List<String>? multiAnswer;

  @JsonKey(name: 'is_required')
  bool isRequired;

  Question({
    required this.question,
    this.answerOptions,
    required this.inputType,
    this.answer,
    this.multiAnswer,
    this.isRequired = false,
  });

  // Factory constructor to create a Question instance from JSON
  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);

  // Method to convert a Question instance to JSON
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}

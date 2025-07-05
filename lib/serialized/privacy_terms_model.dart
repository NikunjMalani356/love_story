import 'package:json_annotation/json_annotation.dart';

part 'privacy_terms_model.g.dart';

@JsonSerializable()
class PolicyTermsModel {
  @JsonKey(name: 'effectiveDate')
  final String? effectiveDate;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'sections')
  final List<SectionModel>? sections;

  PolicyTermsModel({
    this.effectiveDate,
    this.title,
    this.sections,
  });

  factory PolicyTermsModel.fromJson(Map<String, dynamic> json) =>
      _$PolicyTermsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyTermsModelToJson(this);
}

@JsonSerializable()
class SectionModel {
  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'content')
  final String? content;

  @JsonKey(name: 'points')
  final List<String>? points;

  @JsonKey(name: 'subsections')
  final List<SubSectionModel>? subsections;

  @JsonKey(name: 'note')
  final String? note;

  SectionModel({
    this.title,
    this.content,
    this.points,
    this.subsections,
    this.note,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) =>
      _$SectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SectionModelToJson(this);
}

@JsonSerializable()
class SubSectionModel {
  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'content')
  final String? content;

  @JsonKey(name: 'points')
  final List<String>? points;

  @JsonKey(name: 'note')
  final String? note;

  SubSectionModel({
    this.title,
    this.content,
    this.points,
    this.note,
  });

  factory SubSectionModel.fromJson(Map<String, dynamic> json) =>
      _$SubSectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubSectionModelToJson(this);
}

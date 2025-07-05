import 'package:json_annotation/json_annotation.dart';

part 'age_model.g.dart'; // Add this line

@JsonSerializable()
class AgeModel {
  @JsonKey(name: "day")
  int? day;

  @JsonKey(name: "month")
  int? month;

  @JsonKey(name: "years")
  int? years;

  AgeModel({
    this.day,
    this.month,
    this.years,
  });

  factory AgeModel.fromJson(Map<String, dynamic> json) => _$AgeModelFromJson(json);

  Map<String, dynamic> toJson() => _$AgeModelToJson(this);
}

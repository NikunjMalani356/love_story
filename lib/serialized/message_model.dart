import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  @JsonKey(name: 'messageId')
  String? messageId;
  @JsonKey(name: 'senderId')
  String? senderId;
  @JsonKey(name: 'message')
  String? message;
  @JsonKey(name: 'time')
  DateTime? time;
  @JsonKey(name: 'seen')
  bool seen;

  MessageModel({this.messageId, this.message, this.time, this.senderId, this.seen = false});

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}

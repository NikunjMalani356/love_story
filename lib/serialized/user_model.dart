import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'userId')
  final String? userId;

  @JsonKey(name: 'createdAt')
  final String? createdAt;

  @JsonKey(name: 'fcmToken')
  final String? fcmToken;

  @JsonKey(name: 'firstName')
  final String? firstName;

  @JsonKey(name: 'lastName')
  final String? lastName;

  @JsonKey(name: 'fullName')
  final String? fullName;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'dateOfBirth')
  final DateTime? dateOfBirth;

  @JsonKey(name: 'olderAge')
  final String? olderAge;

  @JsonKey(name: 'youngerAge')
  final String? youngerAge;

  @JsonKey(name: 'gender')
  final String? gender;

  @JsonKey(name: 'partnerPrefs')
  final List<String> partnerPrefs;

  @JsonKey(name: 'userLocation')
  final UserLocation? userLocation;

  @JsonKey(name: 'relocation')
  final List<String>? relocation;

  @JsonKey(name: 'childPref')
  final ChildPreference? childPref;

  @JsonKey(name: 'headShotImage')
  final String? headShotImage;

  @JsonKey(name: 'fullBodyImage')
  final String? fullBodyImage;

  @JsonKey(name: 'introductionVideo')
  final String? introductionVideo;

  @JsonKey(name: 'userCoins')
  final num userCoins;

  @JsonKey(name: 'subscription')
  final SubscriptionPlan? subscription;

  @JsonKey(name: 'following')
  final List<FollowingModel> following;

  @JsonKey(name: 'followers')
  final List<FollowingModel> followers;

  @JsonKey(name: 'rejected')
  final List<String> rejected;

  @JsonKey(name: 'rejectedFrom')
  final List<String> rejectedFrom;

  @JsonKey(name: 'isEnable')
  final bool isEnable;

  @JsonKey(name: 'videoCallTime')
  final String? videoCallTime;

  @JsonKey(name: 'rejectionTime')
  final String? rejectionTime;

  @JsonKey(name: 'likedUser')
  final List<LikedUser>? likedUser;

  UserModel({
    this.userId,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.dateOfBirth,
    this.olderAge,
    this.createdAt,
    this.youngerAge,
    this.gender,
    this.partnerPrefs = const <String>[],
    this.userLocation,
    this.relocation,
    this.childPref,
    this.headShotImage,
    this.fullBodyImage,
    this.introductionVideo,
    this.subscription,
    this.fcmToken,
    this.userCoins = 0,
    this.isEnable = true,
    this.following = const <FollowingModel>[],
    this.followers = const <FollowingModel>[],
    this.rejected = const <String>[],
    this.rejectedFrom = const <String>[],
    this.rejectionTime,
    this.videoCallTime,
    this.likedUser,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': createdAt,
      'fcmToken': fcmToken,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'email': email,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'olderAge': olderAge,
      'youngerAge': youngerAge,
      'gender': gender,
      'partnerPrefs': partnerPrefs,
      'userLocation': userLocation?.toMap(),
      'relocation': relocation,
      'childPref': childPref?.toMap(),
      'headShotImage': headShotImage,
      'fullBodyImage': fullBodyImage,
      'introductionVideo': introductionVideo,
      'userCoins': userCoins,
      'subscription': subscription?.toMap(),
      'following': following.map((f) => f.toMap()).toList(),
      'followers': followers.map((f) => f.toMap()).toList(),
      'rejected': rejected,
      'rejectedFrom': rejectedFrom,
      'isEnable': isEnable,
      'videoCallTime': videoCallTime,
      'likedUser': likedUser?.map((liked) => liked.toMap()).toList(),
    };
  }
}

@JsonSerializable()
class LikedUser {
  @JsonKey(name: 'isLiked')
  final bool isLiked;

  @JsonKey(name: 'userId')
  final String userId;

  LikedUser({required this.isLiked, required this.userId});

  factory LikedUser.fromJson(Map<String, dynamic> json) => _$LikedUserFromJson(json);

  Map<String, dynamic> toJson() => _$LikedUserToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'isLiked': isLiked,
      'userId': userId,
    };
  }
}

@JsonSerializable()
class FollowingModel {
  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'followedTime')
  final DateTime followedTime;

  @JsonKey(name: 'isIntroMessageSent')
  final bool? isIntroMessageSent;

  FollowingModel({required this.userId, required this.followedTime, this.isIntroMessageSent = false});

  factory FollowingModel.fromJson(Map<String, dynamic> json) => _$FollowingModelFromJson(json);

  Map<String, dynamic> toJson() => _$FollowingModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'followedTime': followedTime.toIso8601String(),
      'isIntroMessageSent': isIntroMessageSent,
    };
  }
}

@JsonSerializable()
class UserLocation {
  @JsonKey(name: 'country')
  final String? country;

  @JsonKey(name: 'state')
  final String? state;

  @JsonKey(name: 'city')
  final String? city;

  UserLocation({this.country, this.state, this.city});

  factory UserLocation.fromJson(Map<String, dynamic> json) => _$UserLocationFromJson(json);

  Map<String, dynamic> toJson() => _$UserLocationToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'country': country,
      'state': state,
      'city': city,
    };
  }
}

@JsonSerializable()
class SubscriptionPlan {
  @JsonKey(name: 'planName')
  final String? planName;

  @JsonKey(name: 'planDescription')
  final String? planDescription;

  @JsonKey(name: 'planPrice')
  final String? planPrice;

  @JsonKey(name: 'planDuration')
  final num? planDuration;

  @JsonKey(name: 'planStartDate')
  final DateTime? planStartDate;

  @JsonKey(name: 'planExpiry')
  final DateTime? planExpiry;

  SubscriptionPlan({
    this.planName,
    this.planDescription,
    this.planPrice,
    this.planDuration,
    this.planStartDate,
    this.planExpiry,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => _$SubscriptionPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPlanToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'planName': planName,
      'planDescription': planDescription,
      'planPrice': planPrice,
      'planDuration': planDuration,
      'planStartDate': planStartDate?.toIso8601String(),
      'planExpiry': planExpiry?.toIso8601String(),
    };
  }
}

@JsonSerializable()
class ChildPreference {
  @JsonKey(name: 'iHave')
  final List<String>? iHave;

  @JsonKey(name: 'iWant')
  final List<String>? iWant;

  ChildPreference({this.iHave = const [], this.iWant = const []});

  factory ChildPreference.fromJson(Map<String, dynamic> json) => _$ChildPreferenceFromJson(json);

  Map<String, dynamic> toJson() => _$ChildPreferenceToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'iHave': iHave,
      'iWant': iWant,
    };
  }
}

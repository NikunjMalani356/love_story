import 'package:json_annotation/json_annotation.dart';

part 'country_model.g.dart';

@JsonSerializable()
class CountryModel {
  @JsonKey(name: 'id')
  int? id;
  @JsonKey(name: 'name')
  String? name;
  @JsonKey(name: 'iso2')
  String? iso2;
  @JsonKey(name: 'iso3')
  String? iso3;
  @JsonKey(name: 'phoneCode')
  String? phoneCode;
  @JsonKey(name: 'capital')
  String? capital;
  @JsonKey(name: 'currency')
  String? currency;
  @JsonKey(name: 'native')
  String? native;
  @JsonKey(name: 'emoji')
  String? emoji;

  CountryModel({this.id, this.name, this.iso2, this.iso3, this.phoneCode, this.capital, this.currency, this.native, this.emoji});

  factory CountryModel.fromJson(Map<String, dynamic> json) => _$CountryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CountryModelToJson(this);
}

@JsonSerializable()
class StatModel {
  @JsonKey(name: 'id')
  int? id;
  @JsonKey(name: 'name')
  String? name;
  @JsonKey(name: 'iso2')
  String? iso2;

  StatModel({this.id, this.name, this.iso2});

  factory StatModel.fromJson(Map<String, dynamic> json) => _$StatModelFromJson(json);

  Map<String, dynamic> toJson() => _$StatModelToJson(this);
}

@JsonSerializable()
class CityModel {
  @JsonKey(name: 'id')
  int? id;
  @JsonKey(name: 'name')
  String? name;
  @JsonKey(name: 'latitude')
  String? latitude;
  @JsonKey(name: 'longitude')
  String? longitude;

  CityModel({this.id, this.name, this.latitude, this.longitude});

  factory CityModel.fromJson(Map<String, dynamic> json) => _$CityModelFromJson(json);

  Map<String, dynamic> toJson() => _$CityModelToJson(this);
}

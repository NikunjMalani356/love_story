import 'package:get/get.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/que_ans/que_ans_repository.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';

class PartnerImagesController extends GetxController{
  final UserRepository userRepository = getIt.get<UserRepository>();
  final QueAnsRepository queAnsRepository = getIt.get<QueAnsRepository>();
}

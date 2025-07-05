import 'package:get/get.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/cheating/cheating_repository.dart';
import 'package:love_story_unicorn/repository/que_ans/que_ans_repository.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';

class PartnerProfileController extends GetxController{
  QueAnsRepository queAnsRepository = getIt.get<QueAnsRepository>();
  UserRepository userRepository = getIt.get<UserRepository>();
  CheatingRepository chattingRepository = getIt.get<CheatingRepository>();
}

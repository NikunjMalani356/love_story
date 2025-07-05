import 'package:get/get.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/authentication/auth_repository.dart';
import 'package:love_story_unicorn/repository/cheating/cheating_repository.dart';
import 'package:love_story_unicorn/repository/que_ans/que_ans_repository.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';
import 'package:love_story_unicorn/repository/utills/utills_repository.dart';

class MatchMakingController extends GetxController {
  final AuthRepository authRepository = getIt.get<AuthRepository>();
  final UserRepository userRepository = getIt.get<UserRepository>();
  final QueAnsRepository queAnsRepository = getIt.get<QueAnsRepository>();
  final CheatingRepository chattingRepository = getIt.get<CheatingRepository>();
  final UtillsRepository utillsRepository = getIt<UtillsRepository>();
}

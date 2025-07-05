import 'package:get/get.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/cheating/cheating_repository.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';

class IntroMessageController extends GetxController {
  UserRepository userRepository = getIt<UserRepository>();
  CheatingRepository cheatingRepository = getIt<CheatingRepository>();
}

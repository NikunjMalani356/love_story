import 'package:get/get.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';

class OnboardingController extends GetxController {
  UserRepository userRepository = getIt.get<UserRepository>();
}

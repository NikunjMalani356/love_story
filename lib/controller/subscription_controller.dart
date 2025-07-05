import 'package:get/get.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/authentication/auth_repository.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';
import 'package:love_story_unicorn/repository/utills/utills_repository.dart';

class SubscriptionController extends GetxController {
  UserRepository userRepository = getIt.get<UserRepository>();
  AuthRepository authRepository = getIt.get<AuthRepository>();
  UtillsRepository utillsRepository = getIt<UtillsRepository>();
}

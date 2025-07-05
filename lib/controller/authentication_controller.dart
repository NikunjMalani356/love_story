import 'package:get/get.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/authentication/auth_repository.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';
import 'package:love_story_unicorn/repository/utills/utills_repository.dart';

class AuthenticationController extends GetxController {
  AuthRepository authRepository = getIt.get<AuthRepository>();
  UserRepository userRepository = getIt.get<UserRepository>();
  UtillsRepository utillsRepository = getIt.get<UtillsRepository>();
}

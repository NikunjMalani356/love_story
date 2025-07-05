import 'package:get/get.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/authentication/auth_repository.dart';

class ForgotPasswordController extends GetxController {
  AuthRepository authRepository = getIt.get<AuthRepository>();
}

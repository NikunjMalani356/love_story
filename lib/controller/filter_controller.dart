import 'package:get/get.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';

class FilterController extends GetxController {
  final UserRepository userRepository = getIt.get<UserRepository>();
}

import 'package:get/get.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';

class DashboardController extends GetxController {
  final UserRepository userRepository = getIt.get<UserRepository>();

  int currentIndex = 0;

  void updateCurrentIndex(int index) {
    currentIndex = index;
    update();
  }
}

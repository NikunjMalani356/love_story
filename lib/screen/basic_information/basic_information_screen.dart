import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/controller/basic_information_controller.dart';
import 'package:love_story_unicorn/screen/basic_information/basic_information_helper.dart';
import 'package:love_story_unicorn/screen/basic_information/basic_information_sub_screens/child_pref_screen.dart';
import 'package:love_story_unicorn/screen/basic_information/basic_information_sub_screens/gender_screen.dart';
import 'package:love_story_unicorn/screen/basic_information/basic_information_sub_screens/location_screen.dart';
import 'package:love_story_unicorn/screen/basic_information/basic_information_sub_screens/name_screen.dart';
import 'package:love_story_unicorn/screen/basic_information/basic_information_sub_screens/partner_age.dart';
import 'package:love_story_unicorn/screen/basic_information/basic_information_sub_screens/relocation_screen.dart';
import 'package:love_story_unicorn/screen/basic_information/basic_information_sub_screens/welcome_screen.dart';

class BasicInformationScreen extends StatefulWidget {
  const BasicInformationScreen({super.key});

  @override
  State<BasicInformationScreen> createState() => BasicInformationScreenState();
}

class BasicInformationScreenState extends State<BasicInformationScreen> {
  BasicInformationController? basicInformationController;
  BasicInformationScreenHelper? basicInformationScreenHelper;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    basicInformationScreenHelper ??= BasicInformationScreenHelper(this);
    return GetBuilder<BasicInformationController>(
      autoRemove: false,
      init: BasicInformationController(),
      builder: (BasicInformationController controller) {
        basicInformationController = controller;
        return Scaffold(
          body: Stack(
            children: [
              buildBodyView(),
              if (controller.isLoading) const AppLoader(),
            ],
          ),
        );
      },
    );
  }

  Widget buildBodyView() {
    return AppBackground(
      onTapShowBack: () => basicInformationController?.goToPreviousPage(),
      showBack: basicInformationController?.currentIndex != 0,
      child: PageView(
        onPageChanged: (value) {
          basicInformationController?.currentIndex = value;
          basicInformationController?.update();
        },
        controller: basicInformationController?.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          WelcomeScreen(),
          NameScreen(),
          PartnerAge(),
          LocationScreen(),
          RelocationScreen(),
          GenderScreen(),
          ChildPrefScreen(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:love_story_unicorn/screen/dashboard_module/perfetct_match/perfect_match_screen.dart';

class PerfectMatchScreenHelper {
  final PerfectMatchScreenState state;

  AnimationController? controller;
  Animation<Offset>? leftImageAnimation;
  Animation<Offset>? rightImageAnimation;
  Animation<double>? leftImageRotation;
  Animation<double>? rightImageRotation;

  PerfectMatchScreenHelper(this.state) {
    initializeAnimations();
  }

  void initializeAnimations() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: state,
    );

    leftImageAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: const Offset(-0.3, 0.2),
    ).animate(
      CurvedAnimation(
        parent: controller!,
        curve: Curves.easeInOut,
      ),
    );

    rightImageAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: const Offset(0.3, -0.25),
    ).animate(
      CurvedAnimation(
        parent: controller!,
        curve: Curves.easeInOut,
      ),
    );

    leftImageRotation = Tween<double>(begin: 0.1, end: -0.025).animate(
      CurvedAnimation(
        parent: controller!,
        curve: Curves.easeInOut,
      ),
    );

    rightImageRotation = Tween<double>(begin: -0.1, end: 0.025).animate(
      CurvedAnimation(
        parent: controller!,
        curve: Curves.easeInOut,
      ),
    );

    controller?.forward();
  }

  void disposeController() {
    controller?.dispose();
  }
}

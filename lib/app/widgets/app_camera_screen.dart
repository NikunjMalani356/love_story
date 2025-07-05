import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/utills/date_utils.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/controller/basic_information_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class AppCameraScreen extends StatefulWidget {
  const AppCameraScreen({super.key});

  @override
  State<AppCameraScreen> createState() => _AppCameraScreenState();
}

class _AppCameraScreenState extends State<AppCameraScreen> {
  CameraController? cameraController;
  bool isCameraInitialized = false;
  bool isRecording = false;
  late Stopwatch _stopwatch;
  Timer? _timer;

  @override
  void initState() {
    initializeVideoService();
    _stopwatch = Stopwatch();
    super.initState();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BasicInformationController(),
      builder: (BasicInformationController controller) {
        return AppBackground(
          onTapShowBack: () => Get.back(result: ''),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraLargeMedium),
            children: [
              const SizedBox(height: Dimens.heightSmallMedium),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              if (isCameraInitialized && cameraController?.value.isInitialized == true)
                Stack(alignment: Alignment.topRight,
                  children: [
                    CameraPreview(cameraController!),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppText(DateTimeUtils.formatTime(_stopwatch.elapsedMilliseconds),color: AppColorConstant.appWhite,),
                    ),
                  ],
                ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: AppButton(
                      title: 'Start',
                      color: isRecording ? AppColorConstant.appLightGrey : AppColorConstant. appBlack,
                      fontColor: isRecording ? AppColorConstant.appBlack : AppColorConstant. appWhite,
                      onTap: isRecording ? null : () async => await startRecording(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      title: 'Stop',
                      color: !isRecording ? AppColorConstant.appLightGrey : AppColorConstant. appBlack,
                      fontColor: !isRecording ? AppColorConstant.appBlack : AppColorConstant. appWhite,
                      onTap: () => manageRecording(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              if (!isRecording) ...[
                AppButton(
                  title: 'Go back',
                  onTap: isRecording ? null : () async => await startRecording(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> initializeVideoService() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      cameraController = CameraController(cameras[1], ResolutionPreset.medium);
      await cameraController?.initialize();
      isCameraInitialized = true;
    } else {
      'Camera is not available for this device'.showErrorToast();
      isCameraInitialized = false;
    }
    setState(() {});
  }

  Future<void> startRecording() async {
    try {
      await cameraController?.startVideoRecording();
      isRecording = true;
      handleStartStop();
      setState(() {});

      await Future.delayed(
        const Duration(seconds: 30),
        () async {
          if (isRecording) {
            final XFile? videoPath = await stopRecording();
            'videoPath --> $videoPath'.logs();
            Get.back(result: videoPath?.path ?? '');
          }
        },
      );
    } catch (e) {
      'Error starting recording: $e'.logs();
    }
  }

  Future<XFile?> stopRecording() async {
    try {
      if (isRecording) {
        final videoFile = await cameraController?.stopVideoRecording();
        isRecording = false;
        setState(() {});
        return videoFile;
      }
    } catch (e) {
      'Error stopping recording: $e'.logs();
    }
    return null;
  }

  void handleStartStop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
    } else {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {});
      });
    }
    setState(() {});
  }

  Future<String> saveVideoToCustomLocation(String originalFilePath) async {
    try {
      final Directory appDirectory = await getApplicationSupportDirectory();
      final String customPath = '${appDirectory.path}/CustomVideos';

      final customDir = Directory(customPath);
      if (!customDir.existsSync()) {
        await customDir.create(recursive: true);
      }

      final String newFilePath = '$customPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

      final originalFile = File(originalFilePath);
      final newFile = await originalFile.copy(newFilePath);

      return newFile.path;
    } on Exception catch (e) {
      'Error saving video: $e'.logs();
      return originalFilePath;
    }
  }

  Future<void> manageRecording() async {
    if (isRecording) {
      final XFile? videoPath = await stopRecording();
      'videoPath --> $videoPath'.logs();
      final String pathValue = await saveVideoToCustomLocation(videoPath?.path ?? '');
      'new pathValue --> $pathValue'.logs();
      Get.back(result: pathValue);
    } else {
      Get.back();
    }
  }
  Future<void> checkVideoAspectRatio(String videoPath) async {
    final videoController = VideoPlayerController.file(File(videoPath));

    await videoController.initialize();

    final videoSize = videoController.value.size;
    final aspectRatio = videoSize.width / videoSize.height;

    'Video Aspect Ratio: $aspectRatio (Width: ${videoSize.width}, Height: ${videoSize.height})'.logs();
    await videoController.dispose();
  }
}

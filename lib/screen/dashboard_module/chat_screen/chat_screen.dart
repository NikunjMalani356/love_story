import 'dart:io';

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/enum_constant.dart';
import 'package:love_story_unicorn/app/constant/list_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/date_utils.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_loader.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/app/widgets/app_text_form_field.dart';
import 'package:love_story_unicorn/controller/chat_controller.dart';
import 'package:love_story_unicorn/controller/dashboard_controller.dart';
import 'package:love_story_unicorn/helper/validation_helper.dart';
import 'package:love_story_unicorn/screen/dashboard_module/chat_screen/chat_helper.dart';
import 'package:love_story_unicorn/service/audio_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  ChatHelper? helper;
  ChatController? controller;
  DashboardController? dashboardController;
  late AudioPlayer _audioPlayer;
  late AudioPlayer _audioPlayerCheck;
  bool isPlaying = false;
  bool isPlayingCheck = false;
  String? currentlyPlayingUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _audioPlayerCheck = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
  }

  Future<void> _playAudio(url) async {
    try {
      if (!isPlaying) {
        currentlyPlayingUrl = url;
        helper!.updateState();
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
      } else {
        currentlyPlayingUrl = null;
        helper!.updateState();
        await _audioPlayer.stop();
      }
    } catch (e) {
      'Error playing audio: $e'.logs();
    }
  }

  @override
  void dispose() {
    super.dispose();
    helper?.updateOnlineStatus(false);
    _audioPlayer.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      helper?.updateOnlineStatus(true);
    } else {
      helper?.updateOnlineStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    "Current screen --> $runtimeType".logs();
    helper ??= ChatHelper(this);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        RouteHelper.instance.gotoDashboard();
      },
      child: GetBuilder<ChatController>(
        init: ChatController(),
        builder: (ChatController controller) {
          this.controller = controller;
          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      buildHeader(),
                      rejectTimer(),
                      Expanded(child: buildMessageList()),
                      buildMessageInput(),
                    ],
                  ),
                  if (helper?.isLoading == false && helper?.isFollowing == false) buildNoPartnerWidget(),
                  if (helper?.isLoading ?? false) const AppLoader(backgroundColor: AppColorConstant.appWhite),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildNoPartnerWidget() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: AppColorConstant.appWhite,
      padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingExtraSemiLarge),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppText(
              "Messaging becomes available after you and your match double green dragon each other",
              fontSize: Dimens.size22,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: Dimens.heightLarge,
            ),
            AppButton(
              title: 'Go To Matches',
              onTap: () => Get.find<DashboardController>().updateCurrentIndex(0),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      height: Dimens.heightExtraLarge,
      padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingMedium),
      child: Row(
        children: [
          if (helper?.message != null)
            InkWell(
              onTap: () => RouteHelper.instance.gotoDashboard(),
              child: const AppImageAsset(image: AppAsset.icBack, height: Dimens.heightSmallMedium).paddingOnly(right: DimensPadding.paddingSmallMedium),
            ),
          InkWell(onTap: () => RouteHelper.instance.gotoPartnerProfile(currentUser: helper?.selectedUser, isDragonShow: false), child: buildProfilePicture()),
          buildUserDetails(helper?.roomId ?? '', helper?.userId ?? ''),
          buildHeaderActions(),
        ],
      ),
    );
  }

  Widget buildProfilePicture() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: Dimens.heightLarge,
          width: Dimens.widthMedium,
          decoration: BoxDecoration(
            color: AppColorConstant.appTransparent,
            shape: BoxShape.circle,
            border: Border.all(width: 3),
          ),
        ),
        Container(
          height: Dimens.heightSemiMedium,
          width: Dimens.widthSemiNormal,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(Dimens.borderRadiusHuge)),
            child: AppImageAsset(image: helper?.selectedUser?.headShotImage ?? AppAsset.signUpUnicorn, fit: BoxFit.cover),
          ),
        ),
      ],
    ).paddingOnly(right: DimensPadding.paddingExtraLargeMedium);
  }

  Widget buildUserDetails(String? roomId, String userId) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: AppText(
              helper?.selectedUser?.fullName ?? '',
              fontSize: Dimens.size22,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: roomId == null || roomId.isEmpty || userId.isEmpty
                ? const SizedBox(height: 17)
                : StreamBuilder<Map<String, dynamic>?>(
                    stream: controller?.cheatingRepository.getUserOnlineStatus(roomId, userId),
                    builder: (context, snapshot) {
                      final userStatus = snapshot.data;
                      final bool isOnline = userStatus?['isOnline'] ?? false;
                      return Row(
                        children: [
                          Container(
                            height: 5,
                            width: 5,
                            margin: const EdgeInsets.only(right: DimensPadding.paddingTiny),
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : AppColorConstant.appErrorColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          AppText(
                            isOnline ? "Online" : "Offline",
                            fontSize: Dimens.textSizeSmall,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget rejectTimer() {
    return StreamBuilder(
      stream: controller?.userRepository.rejectionTimeStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox();

        final String rejectionTimeStr = snapshot.data!;
        final DateTime? rejectionTime = DateTime.tryParse(rejectionTimeStr);

        if (rejectionTime == null) return const SizedBox();

        final int remainingSeconds = (helper?.rejectTimeInSecond ?? 0) - DateTime.now().toUtc().difference(rejectionTime.toUtc()).inSeconds;

        return StreamBuilder<int>(
          stream: Stream.periodic(const Duration(seconds: 1), (counter) => remainingSeconds - counter),
          builder: (context, timerSnapshot) {
            final int timeLeft = timerSnapshot.data ?? remainingSeconds;
            if (timeLeft <= 0) return const SizedBox();

            final hours = (timeLeft ~/ 3600).toString().padLeft(2, '0');
            final minutes = ((timeLeft % 3600) ~/ 60).toString().padLeft(2, '0');
            final seconds = (timeLeft % 60).toString().padLeft(2, '0');
            final timeText = "$hours : $minutes : $seconds";

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: const BoxDecoration(color: AppColorConstant.appPurple),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    timeText,
                    fontSize: Dimens.textSizeSmall,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimerContainer(int timeLeft) {
    final hours = (timeLeft ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((timeLeft % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeLeft % 60).toString().padLeft(2, '0');
    final timeText = "$hours : $minutes : $seconds";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: const BoxDecoration(color: AppColorConstant.appPurple),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            timeText,
            fontSize: Dimens.textSizeSmall,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }

  Widget buildHeaderActions() {
    return StreamBuilder(
      stream: controller?.userRepository.rejectionTimeStream(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return InkWell(
            onTap: () async => await helper?.onTapReject(),
            child: AppImageAsset(
              image: helper?.isBackwardGifShow == true ? AppAsset.backwardCard : AppAsset.showBackwardGif,
              height: Dimens.heightSemiMedium,
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<bool> showConfirmationDialog(String message, String buttonTitle) async {
    bool result = false;

    await Get.dialog<bool>(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Dimens.heightSmall),
            AppText(message, fontSize: Dimens.size20, textAlign: TextAlign.center),
            const SizedBox(height: Dimens.heightSmallMedium),
            const SizedBox(width: Dimens.heightSmall),
            AppButton(
              title: buttonTitle,
              onTap: () {
                result = true;
                Get.back(result: result);
              },
            ),
          ],
        ),
      ),
    );
    return result;
  }

  Future<bool> showRejectionDialog(String message) async {
    bool result = false;

    await Get.dialog<bool>(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(StringConstant.confirmation, fontSize: Dimens.textSizeVeryLarge, fontWeight: FontWeight.w700),
            const SizedBox(height: Dimens.heightSmall),
            AppText(message, fontSize: Dimens.size20, textAlign: TextAlign.center),
            const SizedBox(height: Dimens.heightSmallMedium),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    title: StringConstant.no,
                    onTap: () {
                      result = false;
                      Get.back(result: result);
                    },
                  ),
                ),
                const SizedBox(width: Dimens.heightSmall),
                Expanded(
                  child: AppButton(
                    title: StringConstant.yes,
                    onTap: () {
                      result = true;
                      Get.back(result: result);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return result;
  }

  Widget buildIconButton(String icon, {GestureTapCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DimensPadding.paddingSmallNormal),
        height: Dimens.heightMedium,
        width: Dimens.widthExtraNormal,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColorConstant.appTransparent),
        child: AppImageAsset(image: icon),
      ),
    );
  }

  Widget buildMessageList() {
    return ListView.builder(
      controller: helper?.scrollController,
      padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingSmallNormal),
      itemCount: helper?.messages.length ?? 0,
      itemBuilder: (context, index) {
        final bool isMe = helper?.messages[index].senderId == FirebaseAuth.instance.currentUser?.uid;
        return Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (helper!.messages[index].message!.contains(ExtensionType.audio) || helper!.messages[index].message!.contains(ExtensionType.iOSAudio))
              audioView(url: helper?.messages[index].message ?? '', isMe: isMe)
            else if (helper?.messages[index].message?.contains(ExtensionType.image) ?? false)
              imageView(url: helper?.messages[index].message ?? '', isMe: isMe)
            else
              BubbleNormal(
                text: helper?.messages[index].message ?? '',
                color: isMe ? AppColorConstant.appLightGrey : AppColorConstant.appCustomRed,
                isSender: isMe,
              ),
            buildMessageTime(index, isMe),
          ],
        ).paddingSymmetric(vertical: DimensPadding.paddingTiny);
      },
    );
  }

  Widget audioView({required String url, required bool isMe}) {
    final isPlaying = currentlyPlayingUrl == url;
    return Container(
      decoration: BoxDecoration(
        color: AppColorConstant.appLightGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: isMe ? const EdgeInsets.only(left: 80, right: 15) : const EdgeInsets.only(left: 15, right: 80),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.audiotrack, size: 24, color: Colors.blue),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Audio Message",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isPlaying ? Icons.stop : Icons.play_arrow,
              color: Colors.blue,
            ),
            onPressed: () {
              _playAudio(url);
            },
          ),
        ],
      ),
    );
  }

  Widget imageView({required String url, required bool isMe}) {
    // onTap: () => RouteHelper.instance.gotoPhotoPreview(url),
    return Container(
      decoration: BoxDecoration(
        color: AppColorConstant.appLightGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: isMe ? const EdgeInsets.only(left: 80, right: 15) : const EdgeInsets.only(left: 15, right: 80),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AppImageAsset(
          image: url,
          height: 200,
          width: 200,
        ),
      ),
    );
  }

  Widget buildMessageTime(int index, bool isMe) {
    final message = helper?.messages[index];
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        AppText(
          DateTimeUtils.getTimeStamp(message?.time?.toLocal() ?? DateTime.now()),
          color: AppColorConstant.appGrey,
          fontSize: Dimens.textSizeSmall,
        ),
        if (isMe)
          AppImageAsset(
            image: message?.seen == true ? AppAsset.icSeen : AppAsset.icUnseen,
          ).paddingSymmetric(horizontal: 3),
      ],
    ).paddingSymmetric(horizontal: DimensPadding.paddingMedium, vertical: 2);
  }

  Widget buildMessageInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (ValidationUtils.instance.checkForAudio(helper?.messageController.text ?? ''))
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: Dimens.heightLarge,
                  padding: const EdgeInsets.only(left: DimensPadding.paddingMedium),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                    border: Border.all(color: AppColorConstant.appLightGrey, width: 2),
                  ),
                  child: Row(
                    children: [
                      StreamBuilder<Duration>(
                        stream: _audioPlayerCheck.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          return AppText(_formatDuration(position));
                        },
                      ),
                      const SizedBox(width: 5),
                      StreamBuilder<Duration?>(
                        stream: _audioPlayerCheck.durationStream,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ?? Duration.zero;
                          return AppText(_formatDuration(duration));
                        },
                      ),
                      StreamBuilder<PlayerState>(
                        stream: _audioPlayerCheck.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final isPlaying = playerState?.playing ?? false;
                          final processingState = playerState?.processingState;
                          if (processingState == ProcessingState.completed) {
                            _audioPlayerCheck.seek(Duration.zero);
                            _audioPlayerCheck.pause();
                          }
                          return IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                _audioPlayerCheck.pause();
                              } else {
                                _audioPlayerCheck.play();
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => helper?.cleatTextFormField(),
                  child: Container(
                    height: Dimens.heightLarge,
                    width: Dimens.widthMedium,
                    padding: const EdgeInsets.all(DimensPadding.paddingMedium),
                    margin: const EdgeInsets.only(left: DimensPadding.paddingSemiNormal),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                      border: Border.all(color: AppColorConstant.appLightGrey, width: 2),
                    ),
                    child: const Icon(Icons.delete),
                  ),
                ),
              ],
            ),
          )
        else if (helper!.messageController.text.contains('.jpg'))
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // onTap: () => RouteHelper.instance.gotoPhotoPreview(helper!.messageController.text),
                Container(
                  height: Dimens.heightLarge,
                  padding: const EdgeInsets.all(DimensPadding.paddingMedium),
                  margin: const EdgeInsets.only(left: DimensPadding.paddingSemiNormal),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                    border: Border.all(color: AppColorConstant.appLightGrey, width: 2),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText('Image', color: AppColorConstant.appDarkGrey),
                      SizedBox(width: 10),
                      Icon(Icons.image),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    helper!.messageController.clear();
                    helper!.updateState();
                  },
                  child: Container(
                    height: Dimens.heightLarge,
                    width: Dimens.widthMedium,
                    padding: const EdgeInsets.all(DimensPadding.paddingMedium),
                    margin: const EdgeInsets.only(left: DimensPadding.paddingSemiNormal),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                      border: Border.all(color: AppColorConstant.appLightGrey, width: 2),
                    ),
                    child: const Icon(Icons.delete),
                  ),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: (AudioRecorder.instance.recorderController.isRecording)
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: AppText(
                      'recording...',
                      color: AppColorConstant.appGrey,
                    ),
                  )
                : AppTextFormField(
                    controller: helper?.messageController,
                    hintText: "Type a message",
                    borderColor: AppColorConstant.appLightGrey,
                    suffixIcon: AppAsset.icPhotosCamera,
                    isMaxLines: true,
                    onSuffixPressed: () async {
                      helper?.messageController.text = await helper?.pickImage() ?? '';
                      helper?.updateState();
                    },
                    onChanged: (value) => controller?.update(),
                  ),
          ),
        buildMicrophoneButton(),
      ],
    ).paddingAll(DimensPadding.paddingSmallNormal);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Widget buildMicrophoneButton() {
    return GestureDetector(
      onTap: () async {
        // if (ValidationUtils.instance.checkForAudio(helper?.messageController.text ?? '')) {
        //   isLoading = true;
        //   helper!.updateState();
        //   final String url = await helper!.uploadAudioToFirebase(File(helper!.messageController.text)) ?? '';
        //   isLoading = false;
        //   helper!.updateState();
        //   helper!.messageController.text = url;
        //   if (helper?.messageController.text.isNotEmpty == true) helper?.addMessage(message: '🎤 Audio');
        // }
        if (!isLoading) {
          final String? fileExtension = helper?.messageController.text.split('.').last.toLowerCase();
          final bool isImage = ListConstant.supportedExtensions.contains(fileExtension);
          if (isImage) {
            isLoading = true;
            helper!.updateState();
            final String url = await helper!.uploadImageToFirebase(File(helper!.messageController.text)) ?? '';
            isLoading = false;
            helper!.updateState();
            helper!.messageController.text = url;
            if (helper?.messageController.text.isNotEmpty == true) helper?.addMessage(message: '🖼️ Image');
          }
          if (isImage == false && ValidationUtils.instance.checkForAudio(helper?.messageController.text ?? '') == false && helper?.messageController.text.isNotEmpty == true) {
            helper?.addMessage();
          }
        }
      },
      // onLongPress: () async {
      //   final bool isMicrophoneGranted = await PermissionService.instance.requestPermission(Permission.microphone);
      //   'isMicrophoneGranted --> $isMicrophoneGranted'.logs();
      //   if (isMicrophoneGranted) {
      //     final String path = await helper!.getFilePath();
      //     await AudioRecorder.instance.startRecording(path);
      //     helper!.updateState();
      //   }
      // },
      // onLongPressEnd: (details) async {
      //   helper!.messageController.text = await AudioRecorder.instance.stopRecording() ?? '';
      //   _audioPlayerCheck.setFilePath(helper!.messageController.text);
      //   helper!.updateState();
      // },
      child: Container(
        height: Dimens.heightLarge,
        width: Dimens.widthMedium,
        padding: const EdgeInsets.all(DimensPadding.paddingMedium),
        margin: const EdgeInsets.only(left: DimensPadding.paddingSemiNormal),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
          border: Border.all(color: AppColorConstant.appLightGrey, width: 2),
        ),
        child: isLoading == true ? const CircularProgressIndicator(color: AppColorConstant.appBlack) : const AppImageAsset(image: AppAsset.icSend),
      ),
    );
  }
}

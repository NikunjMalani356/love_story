import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:love_story_unicorn/app/constant/enum_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/app_function.dart';
import 'package:love_story_unicorn/screen/dashboard_module/chat_screen/chat_screen.dart';
import 'package:love_story_unicorn/serialized/message_model.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';
import 'package:love_story_unicorn/service/config_service.dart';
import 'package:love_story_unicorn/service/send_notification_service.dart';
import 'package:path_provider/path_provider.dart';

class ChatHelper {
  ChatScreenState? state;
  bool isLoading = true;
  bool isSend = false;
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  List<MessageModel> messages = [];
  UserModel? selectedUser;
  UserModel? currentUser;
  String? roomId;
  String? userId;
  String? message;
  bool isFollowing = false;
  bool isFollowedBackMessage = false;
  double hours = 0.0;
  int rejectTimeInSecond = 0;
  bool isBackwardGifShow = false;

  ChatHelper(this.state) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // await AudioRecorder.instance.recorderController.checkPermission();
      await getProfile();
      await searchUser();
      scrollToBottom();
      if (currentUser?.rejectionTime != null) {
        await validateRejectionTime();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    hours = ConfigService.instance.getHourAsSeconds().toDouble();
    rejectTimeInSecond = ConfigService.instance.getRejectTimeHourAsSeconds();
  }

  Future<void> getProfile() async {
    if (Get.arguments != null) {
      message = Get.arguments['introMessage'];
      isFollowedBackMessage = Get.arguments['isFollowBack'] ?? false;
    }
    currentUser = await state?.controller?.userRepository.getUserData();
    if (currentUser?.following.isEmpty == true) {
      isFollowing = false;
    } else {
      isFollowing = true;
      userId = currentUser?.following.first.userId ?? '';
    }
  }

  Future<void> searchUser() async {
    selectedUser = await state?.controller?.getUserData(userId);
    await buildRoom();
    isLoading = false;
    updateState();
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        final roomSnapshot = await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();

        if (roomSnapshot.exists) {
          final roomData = roomSnapshot.data();
          final List<dynamic> users = roomData?['users'] ?? [];
          for (int i = 0; i < users.length; i++) {
            if (users[i]['uid'] != userId) {
              users[i]['isOnline'] = isOnline;
              break;
            }
          }
          await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({'users': users});

          'User online status updated: $isOnline'.logs();
        }
      } catch (error) {
        'Failed to update user online status: $error'.logs();
      }
    }
  }

  Future<void> onTapReject() async {
    bool isFollowingEachOther = false;
    UserModel? oppositeUser;
    final UserModel? user = await state?.controller?.userRepository.getUserData(userId: FirebaseAuth.instance.currentUser?.uid);
    if (user?.following.isNotEmpty == true) {
      oppositeUser = await state?.controller?.userRepository.getUserData(userId: user?.following.first.userId);
      if (oppositeUser?.following.isNotEmpty == true && oppositeUser?.following.first.userId == user?.userId) {
        isFollowingEachOther = true;
      } else {
        isFollowingEachOther = false;
      }
    }
    if (isFollowingEachOther) {
      await manageRejection();
    } else {
      if (user != null && oppositeUser != null) {
        final bool shouldReject = await state?.showRejectionDialog('are you sure you want to unMatch with this person?\nthis person not followed to you yet.') ?? false;
        if (shouldReject) {
          await clearFollowFollowingAndRoom(user: user, oppositeUser: oppositeUser);
        }
      }
    }
  }

  Future<void> manageRejection() async {
    isBackwardGifShow = true;
    updateState();
    final bool shouldReject = await state?.showRejectionDialog('are you sure you want to unMatch with this person?') ?? false;
    isBackwardGifShow = false;
    updateState();
    'shouldReject --> $shouldReject'.infoLogs();
    if (shouldReject) {
      'User --> ${FirebaseAuth.instance.currentUser?.uid}'.logs();
      'selectedUser --> ${selectedUser?.userId}'.logs();
      await state?.controller?.userRepository.updateUserMap('rejectionTime', DateTime.now().toUtc().toIso8601String());
      await state?.controller?.userRepository.updateUserMap('rejectionTime', DateTime.now().toUtc().toIso8601String(), userId: selectedUser?.userId);
      await state?.showConfirmationDialog("you will be unmatched in 2 hours please use this time to message this person letting them know you've decided it's not a match and wishing them well", StringConstant.okText);
      messageController.text =
          "We wanted to let you know that ${currentUser?.fullName} has decided to unmatch. You have 2 hours to exchange any parting messages or good wishes before the match is permanently removed. We wish you the best in your journey!";
      await addMessage();
    }
  }

  Future<void> clearFollowFollowingAndRoom({required UserModel user, required UserModel oppositeUser}) async {
    final Map<String, dynamic> oppositeUserMap = oppositeUser.toMap();
    oppositeUserMap['followers'] = [];
    oppositeUserMap['following'] = [];
    final Map<String, dynamic> userMap = user.toMap();
    userMap['followers'] = [];
    userMap['following'] = [];
    final roomId = await state?.controller?.cheatingRepository.findExistingRoom(user.userId, appositeUserId: oppositeUser.userId);
    await state?.controller?.userRepository.updateUser(userMap, userId: user.userId);
    await state?.controller?.userRepository.updateUser(oppositeUserMap, userId: oppositeUser.userId);
    if (roomId != null) await state?.controller?.cheatingRepository.deleteChatRoom(roomId);
    RouteHelper.instance.gotoDashboard();
  }

  Future<void> validateRejectionTime() async {
    final DateTime currentDateTime = DateTime.now().toUtc();
    'currentUser RejectionTime --> ${currentUser?.rejectionTime}'.logs();
    final int differenceInHours = currentUser?.rejectionTime != null ? currentDateTime.difference(DateTime.parse(currentUser?.rejectionTime ?? '')).inMinutes : 0;
    'Difference in hours --> $differenceInHours'.logs();
    if (differenceInHours >= 20) {
      'roomId --> $roomId'.logs();
      if (roomId != null) {
        final Map<String, dynamic> updatedUserMap = {
          'following': [],
          'followers': [],
          'rejectionTime': null,
          // 'rejectedFrom': FieldValue.arrayUnion([currentUser?.userId]),
          'rejected': FieldValue.arrayUnion([currentUser?.userId]),
        };
        final Map<String, dynamic> updatedCurrentUserMap = {
          'following': [],
          'followers': [],
          'rejectionTime': null,
          // 'rejected': FieldValue.arrayUnion([selectedUser?.userId]),
          'rejectedFrom': FieldValue.arrayUnion([selectedUser?.userId]),
        };
        await state?.controller?.userRepository.updateUser(updatedCurrentUserMap);
        await state?.controller?.userRepository.updateUser(updatedUserMap, userId: selectedUser?.userId);
        await state?.controller?.cheatingRepository.deleteChatRoom(roomId ?? '');
      }
    }
  }

  /// Old method ///
  // Future<void> manageRejection() async {
  //   isBackwardGifShow = true;
  //   updateState();
  //   final bool shouldReject = await state?.showRejectionDialog('are you sure you want to unMatch with this person?') ?? false;
  //   isBackwardGifShow = false;
  //   updateState();
  //   if (shouldReject) {
  //     final DateTime startTime = DateTime.now();
  //     final DateTime endTime = DateTime.now().add(const Duration(hours: 2));
  //     final RejectedModel rejectedModel = RejectedModel(userId: selectedUser?.userId ?? '', rejectStart: startTime, rejectEnd: endTime);
  //     final RejectedModel rejectModelForUser = RejectedModel(userId: currentUser?.userId ?? '', rejectStart: startTime, rejectEnd: endTime);
  //     await state?.controller?.userRepository.addUserToList('rejected', rejectedModel.toMap());
  //     await state?.controller?.userRepository.addUserToList('rejectedFrom', rejectModelForUser.toMap(), userid: selectedUser?.userId);
  //     await state?.controller?.userRepository.addUserToList('rejected', rejectModelForUser.toMap(), userid: selectedUser?.userId);
  //     await state?.controller?.userRepository.addUserToList('rejectedFrom', rejectedModel.toMap(), userid: currentUser?.userId);
  //     "roomId --> $roomId".logs();
  //     if(roomId != null) {
  //     await state?.controller?.cheatingRepository.deleteChatRoom(roomId!);
  //     }
  //   }
  // }

  Stream<Map<String, int>> followedTimeStream() async* {
    final followedTime = DateTime.tryParse(selectedUser?.videoCallTime ?? DateTime.now().toString());
    final durationToAdd = Duration(seconds: hours.toInt());

    final endTime = followedTime?.add(durationToAdd);

    while (true) {
      final now = DateTime.now();
      if (now.isAfter(endTime!)) {
        yield {'hours': 0, 'minutes': 0, 'seconds': 0};
        break;
      }

      final remaining = endTime.difference(now);
      final hoursLeft = remaining.inHours;
      final minutesLeft = remaining.inMinutes % 60;
      final secondsLeft = remaining.inSeconds % 60;

      yield {
        'hours': hoursLeft,
        'minutes': minutesLeft,
        'seconds': secondsLeft,
      };

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> buildRoom() async {
    roomId = await state?.controller?.findExistingRoom(selectedUser?.userId);
    roomId ??= await state?.controller?.createNewRoom(id: userId, message: message ?? '');
    'roomId --> $roomId'.logs();
    if (roomId != null) await getAllMessages();
    'isFollowedBackMessage --> $isFollowedBackMessage'.logs();
    if (roomId != null && isFollowedBackMessage == true) {
      await getAllMessages();
      messageController.text = message ?? '';
      await addMessage();
    }
    await updateOnlineStatus(true);
    state?.controller?.update();
  }

  Future<void> getAllMessages() async {
    final Stream<QuerySnapshot<Map<String, dynamic>>> chats = state?.controller?.getRoomsStream(roomId) ?? const Stream.empty();
    chats.listen((snapshot) async {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      messages = snapshot.docs.map((doc) {
        final message = MessageModel.fromJson(doc.data());

        if (!message.seen && message.senderId != currentUserId) {
          markMessageAsSeen(doc.id);
        }
        return message;
      }).toList();
      messages.sort((a, b) => (a.time ?? DateTime.now().toUtc()).compareTo(b.time ?? DateTime.now().toUtc()));
      state?.controller?.update();
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    });
  }

  Future<void> markMessageAsSeen(String messageId) async {
    try {
      await state?.controller?.markMessageAsSeen(roomId: roomId, messageId: messageId, updates: {'seen': true});
    } catch (e) {
      'Error updating message status: $e'.errorLogs();
    }
  }

  Future<String> getFilePath() async {
    try {
      final Directory storageDirectory = await (Platform.isIOS ? getApplicationSupportDirectory() : getApplicationDocumentsDirectory());
      'storageDirectory --> ${storageDirectory.path}'.infoLogs();
      final String sdPath = "${storageDirectory.path}/record";
      final d = Directory(sdPath);
      if (!d.existsSync()) {
        d.createSync(recursive: true);
      }
      return Platform.isIOS ? '$sdPath/audioFile.m4a' :'$sdPath/audioFile.mp3';
    } on PathNotFoundException catch (e) {
      'Catch PathNotFoundException in getFilePath --> $e'.errorLogs();
    } on PathAccessException catch (e) {
      'Catch PathAccessException in getFilePath --> $e'.errorLogs();
    }
    return '';
  }

  Future<String?> pickImage() async {
    final File? image = await AppFunction.selectImage();
    "image of file --> $image".infoLogs();
    if (image != null) {
      return image.path;
    }
    return null;
  }

  Future<String?> uploadAudioToFirebase(File audioFile) async {
    try {
      final String fileName = audioFile.path.split('/').last;
      'Audio File name --> $fileName'.infoLogs();
      final folderRef = FirebaseStorage.instance.ref().child('${FirebaseAuth.instance.currentUser?.uid}/audio');

      final Uint8List audioData = await audioFile.readAsBytes();
      final Reference ref = folderRef.child('recordedAudio_$fileName${DateTime.now().microsecondsSinceEpoch}');
      await ref.putData(
        audioData,
        SettableMetadata(
          contentType: 'audio/mpeg',
          cacheControl: 'no-store',
        ),
      );

      final String downloadUrl = (await ref.getDownloadURL()).split('&token').first;
      'Audio file uploaded successfully! Download URL: $downloadUrl'.logs();
      return downloadUrl;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in uploadAudioToFirebase --> ${e.message}'.errorLogs();
    }
    return null;
  }

  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      final String fileName = imageFile.path.split('/').last;
      'Image File name --> $fileName'.infoLogs();
      final folderRef = FirebaseStorage.instance.ref().child('${FirebaseAuth.instance.currentUser?.uid}/chatImage');
      final Uint8List imageData = await imageFile.readAsBytes();
      final Reference ref = folderRef.child(
        '${ExtensionType.image}$fileName${DateTime.now().microsecondsSinceEpoch}',
      );
      await ref.putData(
        imageData,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'no-store',
        ),
      );

      final String downloadUrl = (await ref.getDownloadURL()).split('&token').first;
      'Image file uploaded successfully! Download URL: $downloadUrl'.logs();
      return downloadUrl;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in uploadImageToFirebase --> ${e.message}'.errorLogs();
    }
    return null;
  }

  bool isMessageValid(String message) => message.trim().isNotEmpty;

  Future<void> addMessage({String? message}) async {
    final String msg = message ?? messageController.text;
    final MessageModel messageModel = MessageModel(
      message: messageController.text,
      time: DateTime.now().toUtc(),
      senderId: FirebaseAuth.instance.currentUser?.uid,
      messageId: DateTime.now().toUtc().microsecondsSinceEpoch.toString(),
    );
    messageController.clear();
    updateState();
    if (roomId != null) {
      messages.add(messageModel);
      'MessageModel --> ${messageModel.toJson()}'.logs();
      await state?.controller?.cheatingRepository.sendMessage(messageModel, roomId ?? '');
      if(selectedUser?.fcmToken != null) SendNotificationService.instance.sendNotification(fcmToken: selectedUser?.fcmToken ?? '', senderMessage: msg, senderName: currentUser?.fullName ?? '');
    }
    updateState();
  }

  void updateState() => state?.controller?.update();

  void scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  void cleatTextFormField() {
    messageController.clear();
    updateState();
  }
}

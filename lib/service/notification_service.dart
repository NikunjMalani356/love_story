import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  NotificationService._privateConstructor();

  UserRepository userRepository = getIt.get<UserRepository>();

  static final NotificationService instance = NotificationService._privateConstructor();
  String? fcmToken;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initializeNotification() async {
    initializeLocalNotification();
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission();
    final String? apnsToken = await firebaseMessaging.getAPNSToken();
    if (apnsToken != null) {
      "APNs Token: $apnsToken".logs();
    } else {
      "APNs Token is not available yet".logs();
    }
    fcmToken = await firebaseMessaging.getToken();
    'fcmToken --> $fcmToken'.logs();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) await userRepository.updateUserMap('fcmToken', fcmToken, userId: user.uid);
    'FCM Token --> $fcmToken'.logs();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final NotificationSettings notificationSettings = await firebaseMessaging.requestPermission(announcement: true);

    'Notification permission status : ${notificationSettings.authorizationStatus.name}'.logs();
    if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen(
        (RemoteMessage remoteMessage) async {
          'Message title: ${remoteMessage.notification?.title}, body: ${remoteMessage.notification?.body}'.logs();

          const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
            'CHANNEL ID',
            'CHANNEL NAME',
            channelDescription: 'CHANNEL DESCRIPTION',
            importance: Importance.max,
            priority: Priority.max,
          );
          const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );
          const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails);

          await flutterLocalNotificationsPlugin.show(
            0,
            remoteMessage.notification?.title ?? '',
            remoteMessage.notification?.body ?? '',
            notificationDetails,
          );
        },
      );
    }
  }

  void initializeLocalNotification() {
    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings();
    const InitializationSettings platform = InitializationSettings(android: android, iOS: ios);
    flutterLocalNotificationsPlugin.initialize(platform);
  }
}

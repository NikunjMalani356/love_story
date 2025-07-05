import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:love_story_unicorn/app/helper/extension_helper.dart';

class SendNotificationService {
  SendNotificationService._privateConstructor();

  static final SendNotificationService instance = SendNotificationService._privateConstructor();

  Future<void> sendNotification({
    required String fcmToken,
    required String senderMessage,
    required String senderName,
  }) async {
    final ByteData data = await rootBundle.load('config/service_account.json');
    final String jsonString = utf8.decode(data.buffer.asUint8List());

    try {
      final jsonKey = jsonDecode(jsonString);
      final accountCredentials = ServiceAccountCredentials.fromJson(jsonKey);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await clientViaServiceAccount(accountCredentials, scopes);
      try {
        final url = Uri.parse('https://fcm.googleapis.com/v1/projects/love-story-434917/messages:send');
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${client.credentials.accessToken.data}',
        };
        final message = {
          "message": {
            "notification": {"title": senderName, "body": senderMessage},
            "token": fcmToken,
          }
        };
        final response = await http.post(url, headers: headers, body: jsonEncode(message));

        if (response.statusCode == 200) {
          'Notification sent successfully.'.logs();
        } else {
          'Error sending notification: ${response.body}'.logs();
        }
      } catch (e) {
        'Error sending notification: $e'.logs();
      }
    } catch (e) {
      'Error reading service account key file: $e'.logs();
    }
  }
}

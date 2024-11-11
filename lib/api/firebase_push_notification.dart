import 'package:autocare_carowners/Authentication/screens/login.dart';
import 'package:autocare_carowners/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class FirebaseNotificationAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final logger = Logger();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    navigatorKey.currentState?.pushNamed(const LoginScreen() as String, arguments: message);
  }

  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      handleMessage(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  Future<void> handleBackgroundMessages(RemoteMessage message) async {
    final logger = Logger();
    logger.i('Title: ${message.notification?.title}');
    logger.i('Body: ${message.notification?.body}');
    logger.i('Payload: ${message.data}');
  }

  Future<void> initializeNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    logger.i('FCM Token: $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessages);
    initPushNotification();
  }
}



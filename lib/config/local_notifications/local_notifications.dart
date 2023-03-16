import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications {
  static Future<void> requestPermissionLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  static Future<void> initializedLocalNotifications() async {
    final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    //TODO ios configurations

    const intializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    //TODO ios configuration settings

    await flutterLocalNotificationPlugin.initialize(
      intializationSettings,
    );
  }

  static void showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? data,
  }) {
    const androidDetails = AndroidNotificationDetails(
        'channelId', 'channelName',
        playSound: true, importance: Importance.max, priority: Priority.high);

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: data,
    );
  }
}

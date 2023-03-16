import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_push_app/config/local_notifications/local_notifications.dart';
import 'package:flutter_push_app/domain/entities/push_message.dart';
import 'package:flutter_push_app/firebase_options.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHanlder(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  int pushNumberId = 0;

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final Future<void> Function()? requestLocalNotificationPermissions;
  final void Function({
    required int id,
    String? title,
    String? body,
    String? data,
  })? showLocalNotification;

  NotificationsBloc(
      {this.showLocalNotification, this.requestLocalNotificationPermissions})
      : super(const NotificationsState()) {
    on<NotificationStatusChanged>(_notificationStatusChanged);
    on<NotificationReceived>(_onPushMessageReceived);

    //verificar estado de las notificaciones
    _initialStatusCheck();
    _onForegroundMessage();
  }

  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _notificationStatusChanged(
      NotificationStatusChanged event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(
      status: event.status,
    ));
    _getFCMToken();
  }

  void _onPushMessageReceived(
      NotificationReceived event, Emitter<NotificationsState> emit) {
    emit(state
        .copyWith(notifications: [event.pushMessage, ...state.notifications]));
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  void _getFCMToken() async {
    // final settings = await messaging.getNotificationSettings();
    if (state.status != AuthorizationStatus.authorized) return;
    final token = await messaging.getToken();
    print(token);
  }

  void _handleRemoteMessage(RemoteMessage message) {
    final notification = PushMessage(
        messageId:
            message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        sentDate: message.sentTime ?? DateTime.now(),
        data: message.data,
        imageUrl: Platform.isAndroid
            ? message.notification!.android?.imageUrl
            : message.notification!.apple?.imageUrl);
    //if (message.notification != null) return;

    if (showLocalNotification != null) {
      showLocalNotification!(
        id: ++pushNumberId,
        body: notification.body,
        data: notification.data.toString(),
        title: notification.title,
      );
    }

    add(NotificationReceived(notification));
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
  }

  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    //Solicitar permiso a las localNotifications
    if (requestLocalNotificationPermissions != null) {
      await requestLocalNotificationPermissions!();
    }

    add(NotificationStatusChanged(settings.authorizationStatus));
    //settings.authorizationStatus;
  }

  PushMessage? getMessageById(String pushMessageId) {
    final exists = state.notifications
        .any((element) => element.messageId == pushMessageId);
    if (!exists) return null;

    return state.notifications
        .firstWhere((element) => element.messageId == pushMessageId);
  }
}

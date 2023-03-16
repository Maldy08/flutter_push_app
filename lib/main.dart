import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_push_app/config/local_notifications/local_notifications.dart';
import 'package:flutter_push_app/config/router/app_router.dart';
import 'package:flutter_push_app/config/theme/app_theme.dart';
import 'package:flutter_push_app/presentation/blocs/notifications/notifications_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHanlder);
  await NotificationsBloc.initializeFCM();
  await LocalNotifications.initializedLocalNotifications();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => NotificationsBloc(
          requestLocalNotificationPermissions:
              LocalNotifications.requestPermissionLocalNotifications,
          showLocalNotification: LocalNotifications.showLocalNotification,
        ),
      )
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}

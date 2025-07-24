/*
import 'dart:io';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../resources/constants.dart';

class LocalNotificationService {
  //Singleton pattern
  static final LocalNotificationService _notificationService =
      LocalNotificationService._internal();
  factory LocalNotificationService() {
    return _notificationService;
  }
  LocalNotificationService._internal();

  // Instance of LocalNotificationService plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialization  setting for android
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("app_icon"),
      iOS: DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: true,
        )
    );
    tz.initializeTimeZones();

    await _notificationsPlugin.initialize(
      initializationSettings,
      // to handle event when we receive notification
      onDidReceiveNotificationResponse: (details) {
        if (details.input != null) {
          print("onDidReceiveNotificationResponse");
        }
      },
    );

    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }*/
/* else if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }*//*
 else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
    }
  }

  */
/*
      For current time testing you can use
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
  *//*

  static void scheduleNotification({required int id, required String title,
        required String body, DateTime? dateTime}) {

    if(dateTime!=null && DateTime.now().isAfter(dateTime)){
      return;
    }
    print("datetime");
    _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        dateTime!=null
            ? tz.TZDateTime.from(dateTime, tz.local)
            : tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
        const NotificationDetails(
          // Android details
          android: AndroidNotificationDetails('main_channel', 'we360 Channel',
              channelDescription: AppConstants.appName,
              importance: Importance.max,
              priority: Priority.max),
          // iOS details
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  static void showLocalNotification(int id, String title, String body) {
    const androidNotificationDetail = AndroidNotificationDetails(
        'single', // channel Id
        'general notify' // channel Name
        );
    const iosNotificatonDetail = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      iOS: iosNotificatonDetail,
      android: androidNotificationDetail,
    );
    _notificationsPlugin.show(id, title, body, notificationDetails);

    print("Notification function executed..!");
  }

  static Future<void> cancelNotifications(int notificationId) async {
    await _notificationsPlugin.cancel(notificationId);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
*/

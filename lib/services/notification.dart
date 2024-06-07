import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meetoplay/home_page.dart';
import 'package:meetoplay/menu_page.dart';
import "auth.dart";
import "database.dart";
import "package:meetoplay/main.dart";
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;



 class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    final token = await _firebaseMessaging.getToken();
        print("for android device token: $token");
  }

  static Future getDeviceToken({int maxRetires = 3}) async {
    try {
      String? token;
      if (kIsWeb) {
        token = await _firebaseMessaging.getToken(
            vapidKey:
                "BPA9r_00LYvGIV9GPqkpCwfIl3Es4IfbGqE9CSrm6oeYJslJNmicXYHyWOZQMPlORgfhG8RNGe7hIxmbLXuJ92k");
        print("for web device token: $token");
      } else {
        token = await _firebaseMessaging.getToken();
        print("for android device token: $token");
      }
      saveTokentoFirestore(token: token!);
      return token;
    } catch (e) {
      print("failed to get device token");
      if (maxRetires > 0) {
        print("try after 10 sec");
        await Future.delayed(const Duration(seconds: 10));
        return getDeviceToken(maxRetires: maxRetires - 1);
      } else {
        return null;
      }
    }
  }

  static saveTokentoFirestore({required String token}) async {
    bool isUserLoggedin = await AuthService.isLoggedIn();
    print("User is logged in $isUserLoggedin");
    if (isUserLoggedin) {
      await DatabaseService.saveUserToken(token);
      print("save to firestore");
    }
    _firebaseMessaging.onTokenRefresh.listen((event) async {
      if (isUserLoggedin) {
        await DatabaseService.saveUserToken(token);
        print("save to firestore");
      }
    });
  }

  static Future localNotiInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  static void onNotificationTap(NotificationResponse notificationResponse) {
    navigatorKey.currentState!
        .pushNamed('', arguments: notificationResponse);
  }

  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future scheduleNotification(String eventName, DateTime eventDate) async {
  tz.initializeTimeZones();
  var location = tz.getLocation('Europe/Warsaw');
  tz.setLocalLocation(location);


  var scheduledNotificationDateTime =
      tz.TZDateTime.from(eventDate.subtract(const Duration(hours: 1)), tz.local);

      print(scheduledNotificationDateTime);
      print(tz.TZDateTime.now(tz.local));
  if(scheduledNotificationDateTime.isBefore(tz.TZDateTime.now(tz.local))){
    showSimpleNotification(title: 'Przypomnienie o wydarzeniu', body: 'Spotkanie "$eventName" odbędzie się z mniej niż godzinę', payload: 'data');
  }
  else{
    var androidDetails = const AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker'
    );
    var notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Przypomnienie o wydarzeniu',
      'Spotkanie "$eventName" odbędzie się za godzinę',
      scheduledNotificationDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: "data",
    );
  }
}
Future unscheduleNotification(int id) async{
  final List<PendingNotificationRequest> pendingNotificationRequests =
  await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  if(pendingNotificationRequests.isNotEmpty) {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
}

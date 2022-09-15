import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/models/storage_model.dart';

void showToast(String text) {
  Fluttertoast.showToast(
    fontSize: 13,
    msg: '   $text   ',
    backgroundColor: Colors.black,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      text,
      textAlign: TextAlign.center,
    ),
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.grey[400],
  ));
}

void showAlertDialog(BuildContext context, {String? text, dynamic action}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('알림'),
      content: Text(text ?? ""),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'OK');
            action();
          },
          child: const Text('확인'),
        ),
      ],
    ),
  );
}

//노티알람 종류 선택, iOS같은 경우에는 사운드랑 진동이 하나로 묶여있다...
Future<void> selectNotificationType(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, String tag, String subtitle) async {
  late SecureStorage strage = SecureStorage();

  String? soundCheck = await strage.read(Env.KEY_SETTING_SOUND);
  String? vibCheck = await strage.read(Env.KEY_SETTING_VIBRATE);

  //초기설정은 null값이니 ture 로 변환해서 실행해줘야 한다.
  if (soundCheck == 'true' && vibCheck == 'true') {
    //사운드 / 진동 둘다 체크되어있는 정상상태일 경우
    showNotification(flutterLocalNotificationsPlugin, tag, subtitle);
  } else if (soundCheck == 'true' && vibCheck == 'false') {
    //사운드만 체크되어있는 경우
    showNotificationWithNoVibration(flutterLocalNotificationsPlugin, tag, subtitle);
  } else if (soundCheck == 'false' && vibCheck == 'true') {
    //진동만 체크되어있는 경우
    _showNotificationWithNoSound(flutterLocalNotificationsPlugin, tag, subtitle);
  } else {
    //진동 , 소리 둘다 안되있는경우
    showNotificationWithNoOptions(flutterLocalNotificationsPlugin, tag, subtitle);
  }
}

Future<void> _showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, String tag, String subtitle, AndroidNotificationDetails androidNotificationDetails,
    IOSNotificationDetails iOSNotificationDetails) async {
  int id = 0;
  var notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: iOSNotificationDetails);
  flutterLocalNotificationsPlugin.show(id, tag, subtitle, notificationDetails, payload: 'item x');
}

// 진동, 소리 둘다 켜져있을때
Future<void> showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, String tag, String subtitle) async {
  const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(Env.NOTIFICATION_CHANNEL_ID, Env.NOTIFICATION_CHANNEL_NAME,
      playSound: true, enableVibration: true, enableLights: false, ongoing: true, importance: Importance.high, priority: Priority.high);
  const IOSNotificationDetails iOSNotificationDetails = IOSNotificationDetails(presentSound: true);
  _showNotification(flutterLocalNotificationsPlugin, tag, subtitle, androidNotificationDetails, iOSNotificationDetails);
}

//진동만 켜져있을때
Future<void> _showNotificationWithNoSound(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, String tag, String subtitle) async {
  const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(Env.NOTIFICATION_CHANNEL_ID, Env.NOTIFICATION_CHANNEL_NAME,
      playSound: false, enableVibration: true, enableLights: false, ongoing: true, importance: Importance.high, priority: Priority.high);
  const IOSNotificationDetails iOSNotificationDetails = IOSNotificationDetails(presentSound: false);
  _showNotification(flutterLocalNotificationsPlugin, tag, subtitle, androidNotificationDetails, iOSNotificationDetails);
}

//소리만 켜져있을때
Future<void> showNotificationWithNoVibration(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, String tag, String subtitle) async {
  const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(Env.NOTIFICATION_CHANNEL_ID, Env.NOTIFICATION_CHANNEL_NAME,
      playSound: true, enableVibration: false, enableLights: false, ongoing: true, importance: Importance.high, priority: Priority.high);
  const IOSNotificationDetails iOSNotificationDetails = IOSNotificationDetails(presentSound: true);
  _showNotification(flutterLocalNotificationsPlugin, tag, subtitle, androidNotificationDetails, iOSNotificationDetails);
}

//진동, 소리 모두 꺼져있을때
Future<void> showNotificationWithNoOptions(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, String tag, String subtitle) async {
  const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(Env.NOTIFICATION_CHANNEL_ID_NO_ALARM, Env.NOTIFICATION_CHANNEL_NAME_NO_ALARM,
      playSound: false, enableVibration: false, enableLights: false, ongoing: true, importance: Importance.high, priority: Priority.high);
  const IOSNotificationDetails iOSNotificationDetails = IOSNotificationDetails(presentSound: false);
  _showNotification(flutterLocalNotificationsPlugin, tag, subtitle, androidNotificationDetails, iOSNotificationDetails);
}

//로그아웃 다이얼로그
void showLogoutDialog(BuildContext context) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('알림'),
      content: const Text('로그인 페이지로 이동하시겠습니까?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'OK');
            SecureStorage? secureStorage;
            secureStorage = SecureStorage();

            secureStorage.read(Env.KEY_ID_CHECK).then((value) {
              if (value == null && value == "false") {
                secureStorage!.write(Env.LOGIN_ID, "");
              }
            });
            secureStorage.write(Env.LOGIN_PW, "");
            secureStorage.write(Env.LOGIN_STATE, "false");
            secureStorage.write(Env.KEY_ACCESS_TOKEN, "");
            secureStorage.write(Env.KEY_REFRESH_TOKEN, "");
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
          child: const Text('확인'),
        ),
      ],
    ),
  );
}

// 동기화 다이얼로그
void showSyncDialog(BuildContext context, {required Widget widget}) {
  Timer? timer;

  showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        timer = Timer(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });
        return widget;
      }).then((value) {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
  });
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/models/view_models/notifications/notification_payload.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
final _notificationsSerializer = NotificationPayloadJsonSerializer();

class NotificationsProvider {
  Future<void> showNotification(
      int id, String title, String body, NotificationPayload payload) async {
    final String payloadString =
        jsonEncode(_notificationsSerializer.toMap(payload));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id, title, body, platformChannelSpecifics,
        payload: payloadString);
  }

  Future<void> scheduleNotification(
      int id,
      String title,
      String body,
      DateTime scheduledDate,
      NotificationPayload payload,
      String channelId,
      String channelName,
      String channelDesc) async {
    final String payloadString =
        jsonEncode(_notificationsSerializer.toMap(payload));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId, channelName, channelDesc,
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        id, title, body, scheduledDate, platformChannelSpecifics,
        payload: payloadString);
  }

  Future<List<PendingNotificationRequest>>
      getPendingNotificationRequests() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> cancelAllPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleRoutineCompletableNotifications(
      List<Complete> completablesWithRWU) async {
    await cancelAllPendingNotifications();

    completablesWithRWU.forEach(
      (Complete c) => scheduleNotification(
          c.id,
          c.routine_workout_user.workout.name,
          'You have a Workout scheuled today for your subscribed Routine!',
          c.routine_workout_user.day.add(Duration(seconds: 20)),
          NotificationPayload(
              fullRoute:
                  '/workouts/${c.routine_workout_user.workout_id}/${c.id}'),
          'mxf-channel-id-completables',
          'Moxie Scheduled Workout',
          'Notifications for upcoming scheduled workouts.'),
    );
  }

  static Future<void> onDidReceiveLocalNotification(BuildContext context,
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page

    final NotificationPayload notificationPayload =
        _notificationsSerializer.fromMap(jsonDecode(payload));

    await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(body),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Ok'),
                  onPressed: () async {
                    await Routes.router.navigateTo(
                        context, notificationPayload.fullRoute,
                        clearStack: true, replace: true);
                  },
                )
              ],
            ));
  }

  static Future<void> onSelectNotification(
      BuildContext context, String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);

      final NotificationPayload notificationPayload =
          _notificationsSerializer.fromMap(jsonDecode(payload));

      await Routes.router.navigateTo(context, notificationPayload.fullRoute,
          clearStack: true, replace: true);
    } else {
      // default go to app root
      await Routes.router
          .navigateTo(context, '/', clearStack: true, replace: true);
    }
  }

  void dispose() {}
}

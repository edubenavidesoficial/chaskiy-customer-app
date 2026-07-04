import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart'
    hide NotificationModel;
import 'package:flutter/services.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/notification.dart';
import 'package:chaskiy/services/firebase.service.dart';

import 'local_storage.service.dart';

class NotificationService {
  //
  static const platform = MethodChannel('notifications.manage');
  static String? _cachedNotificationsString;
  static List<NotificationModel>? _cachedNotifications;

  //
  static initializeAwesomeNotification() async {
    await AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/notification_icon',
      [appNotificationChannel()],
    );
    //requet notifcation permission if not allowed
    await AwesomeNotifications().isNotificationAllowed().then((
      isAllowed,
    ) async {
      if (!isAllowed) {
        // Insert here your friendly dialog box before call the request method
        // This is very important to not harm the user experience
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> clearIrrelevantNotificationChannels() async {
    if (!Platform.isAndroid) {
      return;
    }
    try {
      // get channels
      final List<dynamic> notificationChannels = await platform.invokeMethod(
        'getChannels',
      );

      //confirm is more than the required channels is found
      final notificationChannelNames =
          notificationChannels
              .map((e) => e.toString().split(" -- ")[1])
              .toList();

      //
      final totalFound =
          notificationChannelNames
              .where(
                (e) =>
                    e.toLowerCase() ==
                    appNotificationChannel().channelName?.toLowerCase(),
              )
              .toList();

      if (totalFound.length > 1) {
        //delete all app created notifications
        for (final notificationChannel in notificationChannels) {
          //
          final notificationChannelData = "$notificationChannel".split(" -- ");
          final notificationChannelId = notificationChannelData[0];
          final notificationChannelName = notificationChannelData[1];
          final isSystemOwned =
              notificationChannelName.toLowerCase() == "miscellaneous";
          //
          if (!isSystemOwned) {
            //
            await platform.invokeMethod('deleteChannel', {
              "id": notificationChannelId,
            });
          }
        }

        //
        await initializeAwesomeNotification();
      }
    } on PlatformException catch (e) {
      print("Failed to get notificaiton channels: '${e.message}'.");
    }
  }

  static NotificationChannel appNotificationChannel() {
    //firebase fall back channel key
    //fcm_fallback_notification_channel
    return NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Notificaciones',
      channelDescription: 'Canal de notificaciones de Chaskiy',
      importance: NotificationImportance.High,
      soundSource: "resource://raw/alert",
      playSound: true,
    );
  }

  //
  static Future<List<NotificationModel>> getNotifications() async {
    //
    final notificationsStringList = (await LocalStorageService.getPrefs())
        .getString(AppStrings.notificationsKey);

    if (notificationsStringList == _cachedNotificationsString &&
        _cachedNotifications != null) {
      return _cachedNotifications!;
    }

    _cachedNotificationsString = notificationsStringList;

    if (notificationsStringList == null || notificationsStringList.isEmpty) {
      _cachedNotifications = [];
      return [];
    }

    _cachedNotifications =
        (jsonDecode(notificationsStringList) as List).asMap().entries.map((
      notificationObject,
    ) {
      //
      return NotificationModel(
        index: notificationObject.key,
        title: notificationObject.value["title"],
        body: notificationObject.value["body"],
        image: notificationObject.value["image"],
        read:
            notificationObject.value["read"] is bool
                ? notificationObject.value["read"]
                : false,
        timeStamp: notificationObject.value["timeStamp"],
      );
    }).toList();
    return _cachedNotifications!;
  }

  static void addNotification(NotificationModel notification) async {
    //
    final notifications = await getNotifications();
    notifications.insert(0, notification);
    _syncIndexes(notifications);

    //
    await _saveNotifications(notifications);
  }

  static void updateNotification(NotificationModel notificationModel) async {
    //
    final notifications = await getNotifications();
    notifications.removeAt(notificationModel.index!);
    notifications.insert(notificationModel.index!, notificationModel);
    _syncIndexes(notifications);
    await _saveNotifications(notifications);
  }

  static void _syncIndexes(List<NotificationModel> notifications) {
    for (int index = 0; index < notifications.length; index++) {
      notifications[index].index = index;
    }
  }

  static Future<void> _saveNotifications(
    List<NotificationModel> notifications,
  ) async {
    final rawNotifications = jsonEncode(notifications);
    _cachedNotificationsString = rawNotifications;
    _cachedNotifications = notifications;
    await LocalStorageService.prefs?.setString(
      AppStrings.notificationsKey,
      rawNotifications,
    );
  }

  static listenToActions() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedNotification,
  ) async {
    //try opening page associated with the notification data
    FirebaseService().saveNewNotification(
      null,
      title: receivedNotification.title,
      body: receivedNotification.body,
    );
    FirebaseService().notificationPayloadData = receivedNotification.payload;
    FirebaseService().selectNotification("");
  }
}

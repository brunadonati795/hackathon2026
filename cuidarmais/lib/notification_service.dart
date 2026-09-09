import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'models.dart';

abstract interface class ReminderNotificationScheduler {
  Future<void> initialize();

  Future<bool> requestPermissions();

  Future<void> schedule(CareReminder reminder);

  Future<void> cancel(int reminderId);

  Future<void> rescheduleAll(Iterable<CareReminder> reminders);

  Future<bool> showTestNotification();
}

class LocalNotificationService implements ReminderNotificationScheduler {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'care_reminders';
  static const _channelName = 'Lembretes de cuidado';
  static const _channelDescription =
      'Avisos de medicamentos, consultas e atividades.';

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize() async {
    if (!kIsWeb) {
      tz_data.initializeTimeZones();
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        final localTimezone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
      }
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (_) {},
    );
  }

  @override
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                WebFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final notificationPermission =
          await android?.requestNotificationsPermission() ?? true;
      return notificationPermission;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return true;
  }

  @override
  Future<void> schedule(CareReminder reminder) async {
    if (!await requestPermissions()) return;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final canScheduleExactly =
          await android?.canScheduleExactNotifications() ?? true;
      if (!canScheduleExactly &&
          !(await android?.requestExactAlarmsPermission() ?? false)) {
        return;
      }
    }
    final parts = reminder.time.split(':');
    if (parts.length != 2) return;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: reminder.id,
      title: 'Hora de ${reminder.title}',
      body: reminder.instructions,
      scheduledDate: scheduledDate,
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: reminder.isDaily
          ? DateTimeComponents.time
          : null,
      payload: 'reminder:${reminder.id}',
    );
  }

  @override
  Future<void> cancel(int reminderId) => _plugin.cancel(id: reminderId);

  @override
  Future<void> rescheduleAll(Iterable<CareReminder> reminders) async {
    await _plugin.cancelAll();
    for (final reminder in reminders) {
      if (reminder.isDaily || reminder.status != ReminderStatus.confirmed) {
        await schedule(reminder);
      }
    }
  }

  @override
  Future<bool> showTestNotification() async {
    if (!await requestPermissions()) return false;
    await _plugin.show(
      id: 900000,
      title: 'Teste do Cuidar+',
      body: 'As notificações estão funcionando neste celular.',
      notificationDetails: _notificationDetails,
      payload: 'notification-test',
    );
    return true;
  }

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
    macOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );
}

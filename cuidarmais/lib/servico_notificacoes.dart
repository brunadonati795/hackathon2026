import 'dart:ui' show Color;

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
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

  Future<void> scheduleAfter(CareReminder reminder, Duration delay);

  Future<void> rescheduleAll(Iterable<CareReminder> reminders);
}

class LocalNotificationService implements ReminderNotificationScheduler {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _alarmChannelId = 'care_reminders_alarm_v2';
  static const _notificationChannelId = 'care_reminders_standard_v1';
  static const _channelName = 'Alarmes de cuidado';
  static const _channelDescription =
      'Alarmes sonoros de medicamentos, consultas e atividades.';
  static const _alarmIdBase = 100000;
  static const _alarmIdStride = 64;
  static const _dailyAlarmHorizon = 30;

  final FlutterLocalNotificationsPlugin _plugin;
  final ValueNotifier<int?> selectedReminderId = ValueNotifier<int?>(null);
  bool _alarmInitialized = false;

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
      windows: WindowsInitializationSettings(
        appName: 'Cuidar+',
        appUserModelId: 'IFC.Concordia.CuidarMais',
        guid: '2f37e647-74a6-4d14-a9ed-9a848b9fdc0c',
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if ((launchDetails?.didNotificationLaunchApp ?? false) &&
        launchDetails?.notificationResponse != null) {
      _handleNotificationResponse(launchDetails!.notificationResponse!);
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await Alarm.init();
      _alarmInitialized = true;
      Alarm.ringing.listen(_handleRingingAlarms);
    }
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
    if (!await _ensureExactSchedulingPermission()) return;
    final parts = reminder.time.split(':');
    if (parts.length != 2) return;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    final now = tz.TZDateTime.now(tz.local);
    final date = reminder.scheduledDate ?? now;
    var scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (_usesAndroidAlarm && reminder.alertMode == ReminderAlertMode.alarm) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestFullScreenIntentPermission();
      await _cancelAndroidAlarmsForReminder(reminder.id);
      await _scheduleAndroidAlarmSeries(reminder, scheduledDate);
      return;
    }

    await _plugin.zonedSchedule(
      id: reminder.id,
      title: 'Hora de ${reminder.title}',
      body: reminder.instructions,
      scheduledDate: scheduledDate,
      notificationDetails: _notificationDetailsFor(reminder.alertMode),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: reminder.isDaily
          ? DateTimeComponents.time
          : null,
      payload: 'reminder:${reminder.id}',
    );
  }

  @override
  Future<void> cancel(int reminderId) async {
    await _plugin.cancel(id: reminderId);
    await _plugin.cancel(id: 500000 + reminderId);
    if (_usesAndroidAlarm) {
      await _cancelAndroidAlarmsForReminder(reminderId);
    }
  }

  @override
  Future<void> scheduleAfter(CareReminder reminder, Duration delay) async {
    if (!await requestPermissions()) return;
    if (!await _ensureExactSchedulingPermission()) return;
    if (_usesAndroidAlarm && reminder.alertMode == ReminderAlertMode.alarm) {
      await _cancelAndroidAlarmsForReminder(reminder.id);
      await _setAndroidAlarm(
        reminder,
        DateTime.now().add(delay),
        alarmId: _androidAlarmId(reminder.id, _alarmIdStride - 1),
      );
      if (reminder.isDaily) {
        final tomorrow = _nextReminderOccurrence(reminder);
        await _scheduleAndroidAlarmSeries(reminder, tomorrow);
      }
      return;
    }
    await _plugin.zonedSchedule(
      id: 500000 + reminder.id,
      title: 'Lembrete: ${reminder.title}',
      body: reminder.instructions,
      scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
      notificationDetails: _notificationDetailsFor(reminder.alertMode),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'reminder:${reminder.id}',
    );
  }

  @override
  Future<void> rescheduleAll(Iterable<CareReminder> reminders) async {
    await _plugin.cancelAll();
    if (_usesAndroidAlarm) {
      await _cancelAllCuidarAlarms();
    }
    for (final reminder in reminders) {
      if (reminder.isDaily || reminder.status != ReminderStatus.confirmed) {
        await schedule(reminder);
      }
    }
  }

  static final Int64List _strongVibrationPattern = Int64List.fromList([
    0,
    700,
    250,
    700,
    250,
    1100,
  ]);

  NotificationDetails _notificationDetailsFor(ReminderAlertMode mode) {
    final isAlarm = mode == ReminderAlertMode.alarm;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        isAlarm ? _alarmChannelId : _notificationChannelId,
        isAlarm ? _channelName : 'Notificações de cuidado',
        channelDescription: isAlarm
            ? _channelDescription
            : 'Avisos comuns de medicamentos, consultas e atividades.',
        importance: isAlarm ? Importance.max : Importance.high,
        priority: isAlarm ? Priority.max : Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: isAlarm ? _strongVibrationPattern : null,
        audioAttributesUsage: isAlarm
            ? AudioAttributesUsage.alarm
            : AudioAttributesUsage.notification,
        category: isAlarm
            ? AndroidNotificationCategory.alarm
            : AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: isAlarm
            ? InterruptionLevel.timeSensitive
            : InterruptionLevel.active,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: isAlarm
            ? InterruptionLevel.timeSensitive
            : InterruptionLevel.active,
      ),
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || !payload.startsWith('reminder:')) return;
    selectedReminderId.value = int.tryParse(payload.substring(9));
  }

  bool get _usesAndroidAlarm =>
      _alarmInitialized &&
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android;

  void _handleRingingAlarms(AlarmSet alarms) {
    for (final alarm in alarms.alarms) {
      final payload = alarm.payload;
      if (payload == null || !payload.startsWith('reminder:')) continue;
      selectedReminderId.value = int.tryParse(payload.substring(9));
      break;
    }
  }

  Future<void> _scheduleAndroidAlarmSeries(
    CareReminder reminder,
    DateTime firstDate,
  ) async {
    final count = reminder.isDaily ? _dailyAlarmHorizon : 1;
    for (var dayOffset = 0; dayOffset < count; dayOffset++) {
      final date = DateTime(
        firstDate.year,
        firstDate.month,
        firstDate.day + dayOffset,
        firstDate.hour,
        firstDate.minute,
      );
      await _setAndroidAlarm(
        reminder,
        date,
        alarmId: _androidAlarmId(reminder.id, dayOffset),
      );
    }
  }

  Future<void> _setAndroidAlarm(
    CareReminder reminder,
    DateTime dateTime, {
    required int alarmId,
  }) {
    return Alarm.set(
      alarmSettings: _alarmSettings(
        id: alarmId,
        dateTime: dateTime,
        title: 'Hora de ${reminder.title}',
        body: reminder.instructions,
        payload: 'reminder:${reminder.id}',
      ),
    ).then((_) {});
  }

  AlarmSettings _alarmSettings({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required String payload,
  }) {
    return AlarmSettings(
      id: id,
      dateTime: dateTime,
      volumeSettings: const VolumeSettings.fixed(
        volume: 1,
        volumeEnforced: true,
        showSystemUI: false,
      ),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'PARAR ALARME',
        iconColor: const Color(0xFF6C52B8),
        androidStopAlarmOnDismiss: false,
      ),
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: false,
      androidFullScreenIntent: true,
      androidStopAlarmOnTermination: false,
      allowSameSecondScheduling: true,
      payload: payload,
      androidStaleAfter: null,
    );
  }

  int _androidAlarmId(int reminderId, int offset) =>
      _alarmIdBase + (reminderId * _alarmIdStride) + offset;

  DateTime _nextReminderOccurrence(CareReminder reminder) {
    final parts = reminder.time.split(':');
    final now = DateTime.now();
    final hour = parts.length == 2 ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length == 2 ? int.tryParse(parts[1]) ?? 0 : 0;
    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next;
  }

  Future<void> _cancelAndroidAlarmsForReminder(int reminderId) async {
    final payload = 'reminder:$reminderId';
    final alarms = await Alarm.getAlarms();
    for (final alarm in alarms.where((item) => item.payload == payload)) {
      await Alarm.stop(alarm.id);
    }
  }

  Future<void> _cancelAllCuidarAlarms() async {
    final alarms = await Alarm.getAlarms();
    for (final alarm in alarms.where(
      (item) => item.payload?.startsWith('reminder:') ?? false,
    )) {
      await Alarm.stop(alarm.id);
    }
  }

  Future<bool> _ensureExactSchedulingPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canScheduleExactly =
        await android?.canScheduleExactNotifications() ?? true;
    return canScheduleExactly ||
        (await android?.requestExactAlarmsPermission() ?? false);
  }
}

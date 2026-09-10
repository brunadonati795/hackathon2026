import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'app_storage.dart';
import 'models.dart';
import 'notification_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    this.storage,
    this.notificationScheduler,
    bool seedDemoData = true,
  }) {
    if (seedDemoData) _seedDemoData();
  }

  final AppStorage? storage;
  final ReminderNotificationScheduler? notificationScheduler;
  Future<void> _pendingSave = Future<void>.value();
  bool _initialized = false;

  void _seedDemoData() {
    _accounts.addAll([
      Account(
        name: 'Maria',
        contact: 'maria@cuidar.app',
        password: '123456',
        role: UserRole.elder,
        linkKey: 'MARIA2026',
      ),
      Account(
        name: 'Rômulo',
        contact: 'romulo@cuidar.app',
        password: '123456',
        role: UserRole.caregiver,
        linkedElderKey: 'MARIA2026',
      ),
    ]);
    _allReminders.addAll([
      CareReminder(
        id: 1,
        title: 'Losartana',
        time: '08:00',
        type: ReminderType.medicine,
        instructions: '1 comprimido com água',
        createdBy: 'Rômulo',
        elderKey: 'MARIA2026',
        status: ReminderStatus.confirmed,
        isDaily: true,
      ),
      CareReminder(
        id: 2,
        title: 'Remédio da pressão',
        time: '10:00',
        type: ReminderType.medicine,
        instructions: 'Tomar depois do café',
        createdBy: 'Rômulo',
        elderKey: 'MARIA2026',
        isDaily: true,
      ),
      CareReminder(
        id: 3,
        title: 'Consulta médica',
        time: '14:30',
        type: ReminderType.appointment,
        instructions: 'Clínica São Lucas',
        createdBy: 'Rômulo',
        elderKey: 'MARIA2026',
      ),
    ]);
  }

  final List<Account> _accounts = [];
  final List<CareReminder> _allReminders = [];

  /// Returns reminders scoped to the current account's linked elder.
  List<CareReminder> get reminders {
    final elderKey = _currentElderKey;
    if (elderKey == null) return _allReminders;
    return _allReminders.where((r) => r.elderKey == elderKey).toList();
  }

  String? get _currentElderKey {
    final account = currentAccount;
    if (account == null) return null;
    if (account.role == UserRole.elder) return account.linkKey;
    return account.linkedElderKey;
  }

  final List<AppNotification> notifications = [];

  Account? currentAccount;
  double textScale = 1;
  double brightness = .72;
  bool highContrast = false;
  int _nextId = 4;
  int _nextNotifId = 1;
  int _nextLinkCode = 1000;
  final Set<String> _issuedLinkKeys = {};

  Future<void> initialize() async {
    if (_initialized) return;
    final storedState = await storage?.read();
    if (storedState != null) {
      try {
        _restore(jsonDecode(storedState) as Map<String, dynamic>);
      } on Object {
        // Keep the current safe state if local data is incomplete or corrupted.
      }
    }
    _initialized = true;
    if (storedState == null) {
      _saveLater();
      await flushPersistence();
    }
  }

  Future<void> flushPersistence() => _pendingSave;

  void _changed() {
    notifyListeners();
    _saveLater();
  }

  void _saveLater() {
    final persistentStorage = storage;
    if (!_initialized || persistentStorage == null) return;
    final snapshot = jsonEncode(_toJson());
    _pendingSave = _pendingSave
        .catchError((Object _) {})
        .then((_) => persistentStorage.write(snapshot));
    unawaited(_pendingSave.catchError((Object _) {}));
  }

  Map<String, dynamic> _toJson() => {
    'accounts': _accounts
        .map(
          (a) => {
            'name': a.name,
            'contact': a.contact,
            'password': a.password,
            'role': a.role.name,
            'linkKey': a.linkKey,
            'linkedElderKey': a.linkedElderKey,
          },
        )
        .toList(),
    'reminders': _allReminders
        .map(
          (r) => {
            'id': r.id,
            'title': r.title,
            'time': r.time,
            'type': r.type.name,
            'instructions': r.instructions,
            'createdBy': r.createdBy,
            'elderKey': r.elderKey,
            'scheduledDate': r.scheduledDate?.toIso8601String(),
            'photoPath': r.photoPath,
            'audioPath': r.audioPath,
            'customType': r.customType,
            'alertMode': r.alertMode.name,
            'status': r.status.name,
            'isDaily': r.isDaily,
          },
        )
        .toList(),
    'notifications': notifications
        .map(
          (n) => {
            'id': n.id,
            'title': n.title,
            'message': n.message,
            'timestamp': n.timestamp.toIso8601String(),
            'targetRole': n.targetRole.name,
            'elderKey': n.elderKey,
            'reminderId': n.reminderId,
            'isRead': n.isRead,
          },
        )
        .toList(),
    'currentContact': currentAccount?.contact,
    'textScale': textScale,
    'brightness': brightness,
    'highContrast': highContrast,
    'nextId': _nextId,
    'nextNotifId': _nextNotifId,
    'nextLinkCode': _nextLinkCode,
  };

  void _restore(Map<String, dynamic> data) {
    final restoredAccounts = (data['accounts'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (a) => Account(
            name: a['name'] as String,
            contact: a['contact'] as String,
            password: a['password'] as String,
            role: UserRole.values.byName(a['role'] as String),
            linkKey: a['linkKey'] as String?,
            linkedElderKey: a['linkedElderKey'] as String?,
          ),
        )
        .toList();
    final restoredReminders = (data['reminders'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (r) => CareReminder(
            id: r['id'] as int,
            title: r['title'] as String,
            time: r['time'] as String,
            type: ReminderType.values.byName(r['type'] as String),
            instructions: r['instructions'] as String,
            createdBy: r['createdBy'] as String,
            elderKey: r['elderKey'] as String?,
            scheduledDate: r['scheduledDate'] == null
                ? null
                : DateTime.parse(r['scheduledDate'] as String),
            photoPath: r['photoPath'] as String?,
            audioPath: r['audioPath'] as String?,
            customType: r['customType'] as String?,
            alertMode: ReminderAlertMode.values.byName(
              r['alertMode'] as String? ?? ReminderAlertMode.alarm.name,
            ),
            status: ReminderStatus.values.byName(r['status'] as String),
            isDaily: r['isDaily'] as bool,
          ),
        )
        .toList();
    final restoredNotifications = (data['notifications'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (n) => AppNotification(
            id: n['id'] as int,
            title: n['title'] as String,
            message: n['message'] as String,
            timestamp: DateTime.parse(n['timestamp'] as String),
            targetRole: UserRole.values.byName(n['targetRole'] as String),
            elderKey: n['elderKey'] as String?,
            reminderId: n['reminderId'] as int?,
            isRead: n['isRead'] as bool,
          ),
        )
        .toList();

    _accounts
      ..clear()
      ..addAll(restoredAccounts);
    _allReminders
      ..clear()
      ..addAll(restoredReminders);
    notifications
      ..clear()
      ..addAll(restoredNotifications);
    final currentContact = data['currentContact'] as String?;
    currentAccount = _accounts
        .where((a) => a.contact == currentContact)
        .firstOrNull;
    textScale = (data['textScale'] as num).toDouble();
    brightness = (data['brightness'] as num).toDouble();
    highContrast = data['highContrast'] as bool;
    _nextId = data['nextId'] as int;
    _nextNotifId = data['nextNotifId'] as int;
    _nextLinkCode = data['nextLinkCode'] as int;
  }

  String generateUniqueLinkKey() {
    final existingKeys = _accounts
        .map((a) => a.linkKey == null ? null : _canonicalLinkKey(a.linkKey!))
        .whereType<String>()
        .toSet();
    String candidate;
    do {
      candidate = 'CD-${_nextLinkCode.toString().padLeft(4, '0')}';
      _nextLinkCode = _nextLinkCode == 9999 ? 1000 : _nextLinkCode + 1;
    } while (existingKeys.contains(_canonicalLinkKey(candidate)) ||
        _issuedLinkKeys.contains(_canonicalLinkKey(candidate)));
    _issuedLinkKeys.add(_canonicalLinkKey(candidate));
    return candidate;
  }

  /// Makes pasted connection codes tolerant to spaces and punctuation.
  /// `CD-1000`, `cd1000` and `CD 1000` therefore identify the same account.
  String _canonicalLinkKey(String value) =>
      value.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  String get elderName {
    if (currentAccount?.role == UserRole.elder) return currentAccount!.name;
    final key = currentAccount?.linkedElderKey;
    return _accounts
            .where(
              (a) =>
                  a.role == UserRole.elder &&
                  a.linkKey != null &&
                  key != null &&
                  _canonicalLinkKey(a.linkKey!) == _canonicalLinkKey(key),
            )
            .map((a) => a.name)
            .firstOrNull ??
        'Maria';
  }

  String? get linkedCaregiverName {
    final elderKey = currentAccount?.role == UserRole.elder
        ? currentAccount?.linkKey
        : currentAccount?.linkedElderKey;
    if (elderKey == null) return null;
    return _accounts
        .where(
          (a) =>
              a.role == UserRole.caregiver &&
              a.linkedElderKey != null &&
              _canonicalLinkKey(a.linkedElderKey!) ==
                  _canonicalLinkKey(elderKey),
        )
        .map((a) => a.name)
        .firstOrNull;
  }

  List<AppNotification> get notificationsForCurrentRole {
    final role = currentAccount?.role ?? UserRole.elder;
    final elderKey = _currentElderKey;
    return notifications
        .where(
          (n) =>
              n.targetRole == role &&
              (elderKey == null ||
                  n.elderKey == null ||
                  _canonicalLinkKey(n.elderKey!) ==
                      _canonicalLinkKey(elderKey)),
        )
        .toList();
  }

  int get unreadNotificationsCount {
    return notificationsForCurrentRole.where((n) => !n.isRead).length;
  }

  CareReminder? reminderById(int id) =>
      _allReminders.where((reminder) => reminder.id == id).firstOrNull;

  void markNotificationsAsRead() {
    for (final n in notificationsForCurrentRole) {
      n.isRead = true;
    }
    _changed();
  }

  /// Sign in by contact + password only – role is detected automatically.
  String? signIn(String contact, String password, [UserRole? roleHint]) {
    final normalized = contact.trim().toLowerCase();
    // Try matching with hint first, then without role restriction
    Iterable<Account> matches = _accounts.where(
      (a) =>
          a.contact.toLowerCase() == normalized &&
          a.password == password &&
          (roleHint == null || a.role == roleHint),
    );
    if (matches.isEmpty) {
      return 'E-mail ou senha incorretos. Verifique e tente novamente.';
    }
    currentAccount = matches.first;
    _changed();
    return null;
  }

  String? createAccount({
    required String name,
    required String contact,
    required String password,
    required UserRole role,
    required String key,
  }) {
    final trimmedName = name.trim();
    final trimmedContact = contact.trim();
    var finalKey = key.trim().toUpperCase();

    if (trimmedName.isEmpty ||
        trimmedContact.isEmpty ||
        password.trim().isEmpty) {
      return 'Preencha todos os campos para continuar.';
    }
    if (role == UserRole.caregiver && finalKey.isEmpty) {
      return 'Digite a palavra-chave do idoso para conectar.';
    }
    if (role == UserRole.elder && finalKey.isEmpty) {
      finalKey = generateUniqueLinkKey();
    }

    if (password.length < 6) {
      return 'A senha precisa ter pelo menos 6 números ou letras.';
    }
    if (_accounts.any(
      (a) => a.contact.toLowerCase() == trimmedContact.toLowerCase(),
    )) {
      return 'Já existe uma conta com este e-mail ou telefone.';
    }
    if (role == UserRole.elder &&
        _accounts.any(
          (a) =>
              a.linkKey != null &&
              _canonicalLinkKey(a.linkKey!) == _canonicalLinkKey(finalKey),
        )) {
      return 'Essa palavra-chave já está em uso. Escolha outra.';
    }
    if (role == UserRole.caregiver) {
      final matchingElders = _accounts.where(
        (a) =>
            a.role == UserRole.elder &&
            a.linkKey != null &&
            _canonicalLinkKey(a.linkKey!) == _canonicalLinkKey(finalKey),
      );
      if (matchingElders.isEmpty) {
        return 'Não encontramos um idoso com essa palavra-chave.';
      }
      // Store the elder's displayed code, not the possibly differently formatted
      // text typed or pasted by the caregiver.
      finalKey = matchingElders.first.linkKey!;
    }
    final account = Account(
      name: trimmedName,
      contact: trimmedContact,
      password: password,
      role: role,
      linkKey: role == UserRole.elder ? finalKey : null,
      linkedElderKey: role == UserRole.caregiver ? finalKey : null,
    );
    _accounts.add(account);
    currentAccount = account;
    _changed();
    return null;
  }

  Future<String?> createAccountAndSave({
    required String name,
    required String contact,
    required String password,
    required UserRole role,
    required String key,
  }) async {
    final result = createAccount(
      name: name,
      contact: contact,
      password: password,
      role: role,
      key: key,
    );
    if (result == null) await flushPersistence();
    return result;
  }

  void addReminder({
    required String title,
    required String time,
    required ReminderType type,
    required String instructions,
    required bool isDaily,
    DateTime? scheduledDate,
    String? photoPath,
    String? audioPath,
    String? customType,
    ReminderAlertMode alertMode = ReminderAlertMode.alarm,
  }) {
    final newReminder = CareReminder(
      id: _nextId++,
      title: title,
      time: time,
      type: type,
      instructions: instructions,
      createdBy: currentAccount?.name ?? 'Familiar',
      elderKey: _currentElderKey,
      scheduledDate: scheduledDate,
      photoPath: photoPath,
      audioPath: audioPath,
      customType: customType,
      alertMode: alertMode,
      isDaily: isDaily,
    );
    _allReminders.insert(0, newReminder);

    notifications.insert(
      0,
      AppNotification(
        id: _nextNotifId++,
        title: 'Lembrete criado',
        message: 'Você adicionou "$title" para às $time.',
        timestamp: DateTime.now(),
        targetRole: UserRole.caregiver,
        elderKey: _currentElderKey,
        reminderId: newReminder.id,
      ),
    );
    notifications.insert(
      0,
      AppNotification(
        id: _nextNotifId++,
        title: 'Novo lembrete',
        message: 'Lembrete "$title" adicionado para às $time.',
        timestamp: DateTime.now(),
        targetRole: UserRole.elder,
        elderKey: _currentElderKey,
        reminderId: newReminder.id,
      ),
    );

    final scheduler = notificationScheduler;
    if (scheduler != null) {
      unawaited(scheduler.schedule(newReminder));
    }
    _changed();
  }

  void confirm(CareReminder reminder) {
    reminder.status = ReminderStatus.confirmed;
    notifications.insert(
      0,
      AppNotification(
        id: _nextNotifId++,
        title: 'Lembrete confirmado',
        message:
            '${currentAccount?.name ?? "Idoso"} confirmou: ${reminder.title}.',
        timestamp: DateTime.now(),
        targetRole: UserRole.caregiver,
        elderKey: reminder.elderKey,
        reminderId: reminder.id,
      ),
    );
    final scheduler = notificationScheduler;
    if (scheduler != null) {
      unawaited(_stopAlarmAndPrepareNext(reminder, scheduler));
    }
    _changed();
  }

  void postpone(CareReminder reminder) {
    reminder.status = ReminderStatus.delayed;
    notifications.insert(
      0,
      AppNotification(
        id: _nextNotifId++,
        title: 'Lembrete adiado',
        message: '$elderName pediu para lembrar mais tarde: ${reminder.title}.',
        timestamp: DateTime.now(),
        targetRole: UserRole.caregiver,
        elderKey: reminder.elderKey,
        reminderId: reminder.id,
      ),
    );
    final scheduler = notificationScheduler;
    if (scheduler != null) {
      unawaited(scheduler.scheduleAfter(reminder, const Duration(minutes: 10)));
    }
    _changed();
  }

  void resolve(CareReminder reminder) {
    reminder.status = ReminderStatus.confirmed;
    notifications.insert(
      0,
      AppNotification(
        id: _nextNotifId++,
        title: 'Alerta resolvido',
        message: 'O lembrete "${reminder.title}" foi marcado como resolvido.',
        timestamp: DateTime.now(),
        targetRole: UserRole.elder,
        elderKey: reminder.elderKey,
        reminderId: reminder.id,
      ),
    );
    final scheduler = notificationScheduler;
    if (scheduler != null) {
      unawaited(_stopAlarmAndPrepareNext(reminder, scheduler));
    }
    _changed();
  }

  Future<void> _stopAlarmAndPrepareNext(
    CareReminder reminder,
    ReminderNotificationScheduler scheduler,
  ) async {
    await scheduler.cancel(reminder.id);
    if (reminder.isDaily) await scheduler.schedule(reminder);
  }

  void setTextScale(double value) {
    textScale = value;
    _changed();
  }

  void setBrightness(double value) {
    brightness = value.clamp(0.3, 1.0);
    _changed();
  }

  void setHighContrast(bool value) {
    highContrast = value;
    _changed();
  }

  void signOut() {
    currentAccount = null;
    _changed();
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

import 'package:cuidarmais/app_storage.dart';
import 'package:cuidarmais/app_state.dart';
import 'package:cuidarmais/models.dart';
import 'package:cuidarmais/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generateUniqueLinkKey creates unique non-duplicating codes', () {
    final state = AppState();
    final key1 = state.generateUniqueLinkKey();
    final key2 = state.generateUniqueLinkKey();

    expect(key1, startsWith('CD-'));
    expect(key1.length, greaterThanOrEqualTo(6));
    expect(key1, isNot(equals('MARIA2026')));
    expect(key2, isNot(equals(key1)));
  });

  test(
    'elder account can auto-generate unique link key and connect to caregiver',
    () {
      final state = AppState();

      final elderResult = state.createAccount(
        name: 'Vovô João',
        contact: 'joao@teste.com',
        password: '123456',
        role: UserRole.elder,
        key: '', // Empty key triggers auto-generation
      );
      expect(elderResult, isNull);
      final generatedKey = state.currentAccount?.linkKey;
      expect(generatedKey, isNotNull);
      expect(generatedKey, startsWith('CD-'));

      // Caregiver connects using auto-generated key
      final caregiverResult = state.createAccount(
        name: 'Carlos Cuidador',
        contact: 'carlos@teste.com',
        password: '123456',
        role: UserRole.caregiver,
        key: generatedKey!,
      );
      expect(caregiverResult, isNull);
      expect(state.elderName, 'Vovô João');
    },
  );

  test('caregiver can only register with an existing elder keyword', () {
    final state = AppState();

    final invalid = state.createAccount(
      name: 'Ana',
      contact: 'ana@teste.com',
      password: '123456',
      role: UserRole.caregiver,
      key: 'NAOEXISTE',
    );
    expect(invalid, contains('Não encontramos'));

    final valid = state.createAccount(
      name: 'Ana',
      contact: 'ana@teste.com',
      password: '123456',
      role: UserRole.caregiver,
      key: 'MARIA2026',
    );
    expect(valid, isNull);
    expect(state.elderName, 'Maria');
  });

  test(
    'caregiver connection accepts a copied code with different formatting',
    () {
      final state = AppState();
      expect(
        state.createAccount(
          name: 'João',
          contact: 'joao@teste.com',
          password: '123456',
          role: UserRole.elder,
          key: 'CD-4321',
        ),
        isNull,
      );

      expect(
        state.createAccount(
          name: 'Ana',
          contact: 'ana2@teste.com',
          password: '123456',
          role: UserRole.caregiver,
          key: ' cd 4321 ',
        ),
        isNull,
      );
      expect(state.currentAccount?.linkedElderKey, 'CD-4321');
      expect(state.elderName, 'João');
    },
  );

  test(
    'new reminder generates notification for elder and can be confirmed',
    () {
      final state = AppState();
      state.signIn('romulo@cuidar.app', '123456');

      state.addReminder(
        title: 'Caminhada',
        time: '16:00',
        type: ReminderType.activity,
        instructions: 'Levar água',
        isDaily: false,
      );

      expect(state.reminders.first.title, 'Caminhada');
      expect(state.reminders.first.status, ReminderStatus.pending);

      // Notification generated for elder
      expect(state.notifications, isNotEmpty);
      expect(state.notifications.first.targetRole, UserRole.elder);
      expect(state.notifications.first.title, 'Novo lembrete');
      expect(
        state.notifications
            .where((n) => n.targetRole == UserRole.caregiver)
            .single
            .title,
        'Lembrete criado',
      );

      // Confirm reminder generates caregiver notification
      state.confirm(state.reminders.first);
      expect(state.reminders.first.status, ReminderStatus.confirmed);
      expect(state.notifications.first.targetRole, UserRole.caregiver);
    },
  );

  test('postponing reminder generates caregiver notification alert', () {
    final state = AppState();
    state.signIn('maria@cuidar.app', '123456');

    final reminder = state.reminders.first;
    state.postpone(reminder);

    expect(reminder.status, ReminderStatus.delayed);
    final caregiverNotifications = state.notifications
        .where((n) => n.targetRole == UserRole.caregiver)
        .toList();
    expect(caregiverNotifications, isNotEmpty);
    expect(caregiverNotifications.first.title, 'Lembrete adiado');
  });

  test('notifications stay scoped to the elder connected by the code', () {
    final state = AppState();
    state.createAccount(
      name: 'João',
      contact: 'joao3@teste.com',
      password: '123456',
      role: UserRole.elder,
      key: 'CD-5555',
    );
    state.createAccount(
      name: 'Ana',
      contact: 'ana3@teste.com',
      password: '123456',
      role: UserRole.caregiver,
      key: 'CD-5555',
    );
    state.addReminder(
      title: 'Vitamina',
      time: '09:00',
      type: ReminderType.medicine,
      instructions: '',
      isDaily: true,
    );

    state.signIn('maria@cuidar.app', '123456');
    expect(state.notificationsForCurrentRole, isEmpty);

    state.signIn('joao3@teste.com', '123456');
    expect(state.notificationsForCurrentRole.single.title, 'Novo lembrete');
  });

  test('creating a reminder schedules the phone notification', () {
    final scheduler = _RecordingNotificationScheduler();
    final state = AppState(notificationScheduler: scheduler);
    state.signIn('romulo@cuidar.app', '123456');

    state.addReminder(
      title: 'Tomar vitamina',
      time: '18:30',
      type: ReminderType.medicine,
      instructions: 'Depois do jantar',
      isDaily: true,
    );

    expect(scheduler.scheduled.single.title, 'Tomar vitamina');
    expect(scheduler.scheduled.single.time, '18:30');
    expect(scheduler.scheduled.single.isDaily, isTrue);
  });

  test('accessibility settings state updates correctly', () {
    final state = AppState();

    state.setTextScale(1.5);
    expect(state.textScale, 1.5);

    state.setBrightness(0.4);
    expect(state.brightness, 0.4);

    state.setHighContrast(true);
    expect(state.highContrast, isTrue);
  });

  test(
    'account login and notifications survive a complete app restart',
    () async {
      final storage = _MemoryStorage();
      final firstRun = AppState(storage: storage);
      await firstRun.initialize();

      final elderResult = await firstRun.createAccountAndSave(
        name: 'Helena',
        contact: 'helena@teste.com',
        password: 'abcdef',
        role: UserRole.elder,
        key: '',
      );
      expect(elderResult, isNull);
      final code = firstRun.currentAccount!.linkKey!;
      firstRun.signOut();
      await firstRun.flushPersistence();

      final secondRun = AppState(storage: storage);
      await secondRun.initialize();
      expect(secondRun.currentAccount, isNull);
      expect(secondRun.signIn('HELENA@TESTE.COM', 'abcdef'), isNull);
      secondRun.signOut();
      await secondRun.createAccountAndSave(
        name: 'Paulo',
        contact: 'paulo@teste.com',
        password: 'abcdef',
        role: UserRole.caregiver,
        key: code,
      );
      secondRun.addReminder(
        title: 'Beber água',
        time: '11:00',
        type: ReminderType.activity,
        instructions: 'Um copo',
        isDaily: true,
      );
      await secondRun.flushPersistence();

      final thirdRun = AppState(storage: storage);
      await thirdRun.initialize();
      thirdRun.signOut();
      expect(thirdRun.signIn('helena@teste.com', 'abcdef'), isNull);
      expect(thirdRun.reminders.single.title, 'Beber água');
      expect(
        thirdRun.notificationsForCurrentRole.single.title,
        'Novo lembrete',
      );
    },
  );
}

class _MemoryStorage implements AppStorage {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

class _RecordingNotificationScheduler implements ReminderNotificationScheduler {
  final List<CareReminder> scheduled = [];

  @override
  Future<void> schedule(CareReminder reminder) async {
    scheduled.add(reminder);
  }

  @override
  Future<void> cancel(int reminderId) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> rescheduleAll(Iterable<CareReminder> reminders) async {}

  @override
  Future<bool> showTestNotification() async => true;
}

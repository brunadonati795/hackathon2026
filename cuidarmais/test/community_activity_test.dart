import 'package:cuidarmais/app_state.dart';
import 'package:cuidarmais/app_storage.dart';
import 'package:cuidarmais/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('community activity calculates its next valid weekly occurrence', () {
    final activity = _activity();

    expect(
      activity.nextOccurrence(DateTime(2026, 9, 9, 12)),
      DateTime(2026, 9, 10, 14),
    );
    expect(
      activity.nextOccurrence(DateTime(2026, 9, 10, 15)),
      DateTime(2026, 9, 17, 14),
    );
  });

  test('community activity becomes one reminder and cannot be duplicated', () {
    final state = AppState();
    state.signIn('romulo@cuidar.app', '123456');
    final activity = _activity();

    expect(
      state.addCommunityActivityReminder(
        activity,
        now: DateTime(2026, 9, 9, 12),
      ),
      isTrue,
    );
    expect(
      state.addCommunityActivityReminder(
        activity,
        now: DateTime(2026, 9, 9, 12),
      ),
      isFalse,
    );
    final reminder = state.reminders.first;
    expect(reminder.title, activity.title);
    expect(reminder.communityActivityId, activity.id);
    expect(reminder.alertMode, ReminderAlertMode.notification);
    expect(reminder.scheduledDate, DateTime(2026, 9, 10, 14));
  });

  test(
    'institution submission receives protocol and survives restart',
    () async {
      final storage = _MemoryStorage();
      final firstRun = AppState(storage: storage, seedDemoData: false);
      await firstRun.initialize();

      final protocol = firstRun.submitCommunityActivity(
        organizer: 'Associação Comunitária',
        contact: '(49) 99999-0000',
        title: 'Oficina de artesanato',
        schedule: 'Quartas, às 14h',
        address: 'Rua Central, 100',
        description: 'Atividade gratuita para pessoas com 60 anos ou mais.',
      );
      await firstRun.flushPersistence();

      expect(protocol, 'CM-0001');
      expect(
        firstRun.activitySubmissions.single.statusLabel,
        'Aguardando verificação',
      );

      final secondRun = AppState(storage: storage, seedDemoData: false);
      await secondRun.initialize();
      expect(
        secondRun.activitySubmissions.single.title,
        'Oficina de artesanato',
      );
      expect(secondRun.activitySubmissions.single.protocol, 'CM-0001');
    },
  );
}

CommunityActivity _activity() => CommunityActivity(
  id: 'atividade-teste',
  title: 'Encontro comunitário',
  organizer: 'Centro de Convivência',
  description: 'Encontro em grupo.',
  category: CommunityActivityCategory.social,
  address: 'Rua Central, 100',
  phone: '(49) 3444-0000',
  scheduleLabel: 'Quintas, às 14h',
  weekday: DateTime.thursday,
  hour: 14,
  minute: 0,
  audience: 'Pessoas com 60 anos ou mais',
  priceLabel: 'Gratuito',
  accessibilityLabel: 'Entrada acessível',
  verifiedAt: DateTime(2026, 9, 9),
  sourceUrl: 'https://example.org',
  endDate: DateTime(2026, 12, 31, 23, 59),
);

class _MemoryStorage implements AppStorage {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;
}

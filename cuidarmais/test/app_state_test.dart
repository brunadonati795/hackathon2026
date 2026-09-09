import 'package:cuidarmais/app_state.dart';
import 'package:cuidarmais/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  test('new reminder is immediately shared and can be confirmed', () {
    final state = AppState();
    state.addReminder(
      title: 'Caminhada',
      time: '16:00',
      type: ReminderType.activity,
      instructions: 'Levar água',
      isDaily: false,
    );

    expect(state.reminders.first.title, 'Caminhada');
    expect(state.reminders.first.status, ReminderStatus.pending);

    state.confirm(state.reminders.first);
    expect(state.reminders.first.status, ReminderStatus.confirmed);
  });
}

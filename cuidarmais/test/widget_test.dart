import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cuidarmais/app_state.dart';
import 'package:cuidarmais/main.dart';
import 'package:cuidarmais/models.dart';
import 'package:cuidarmais/screens/community_activities_screen.dart';
import 'package:cuidarmais/screens/elder_screen.dart';
import 'package:cuidarmais/screens/settings_screen.dart';
import 'package:cuidarmais/theme.dart';

void main() {
  testWidgets('login screen has single entry button', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byKey(const Key('app-logo')), findsOneWidget);
    expect(find.text('ENTRAR NA MINHA CONTA'), findsOneWidget);
    expect(find.byKey(const Key('create-account')), findsOneWidget);
  });

  testWidgets(
    'elder demo account opens accessible home with connection code badge',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.enterText(
        find.byKey(const Key('login-contact')),
        'maria@cuidar.app',
      );
      await tester.enterText(find.byKey(const Key('login-password')), '123456');
      await tester.tap(find.byKey(const Key('sign-in-elder')));
      await tester.pumpAndSettle();
      expect(find.text('Olá, Maria!'), findsOneWidget);
      expect(find.byKey(const Key('settings-button')), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, -360));
      await tester.pumpAndSettle();
      expect(find.text('Falar com familiar'), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, -320));
      await tester.pumpAndSettle();
      expect(find.text('Seu Código de Conexão'), findsOneWidget);
      expect(find.text('MARIA2026'), findsOneWidget);
    },
  );

  testWidgets('elder adds a verified community activity to the agenda', (
    tester,
  ) async {
    final state = AppState();
    state.signIn('maria@cuidar.app', '123456');
    await tester.pumpWidget(MyApp(state: state));

    await tester.scrollUntilVisible(
      find.byKey(const Key('community-activities')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    final activitiesTapTarget = find.descendant(
      of: find.byKey(const Key('community-activities')),
      matching: find.byType(InkWell),
    );
    tester.widget<InkWell>(activitiesTapTarget).onTap!();
    await tester.pumpAndSettle();

    expect(find.byType(CommunityActivitiesScreen), findsOneWidget);
    expect(find.text('Conecta 60+'), findsOneWidget);
    await tester.tap(
      find.byKey(
        const Key('community-activity-sesc-conecta-60-concordia-2026'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CommunityActivityDetailScreen), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -420));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-activity-to-agenda')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('activity-reminder-notification')));
    await tester.pumpAndSettle();

    expect(find.text('Atividade adicionada à agenda.'), findsOneWidget);
    expect(
      state.reminders.where((reminder) => reminder.title == 'Conecta 60+'),
      hasLength(1),
    );
  });

  testWidgets('institution submits an activity for verification', (
    tester,
  ) async {
    final state = AppState();
    await tester.pumpWidget(MyApp(state: state));
    await tester.ensureVisible(find.byKey(const Key('institution-entry')));
    await tester.tap(find.byKey(const Key('institution-entry')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('submission-organizer')),
      'Associação Comunitária',
    );
    await tester.enterText(
      find.byKey(const Key('submission-contact')),
      '(49) 99999-0000',
    );
    await tester.enterText(
      find.byKey(const Key('submission-title')),
      'Oficina de artesanato',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('submission-schedule')),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.enterText(
      find.byKey(const Key('submission-schedule')),
      'Quartas, às 14h',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('submission-address')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.enterText(
      find.byKey(const Key('submission-address')),
      'Rua Central, 100',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('submission-description')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.enterText(
      find.byKey(const Key('submission-description')),
      'Atividade gratuita e acessível.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('submit-institution-activity')),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    final submitButton = tester.widget<FilledButton>(
      find.byKey(const Key('submit-institution-activity')),
    );
    submitButton.onPressed!();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('activity-submission-protocol')),
      findsOneWidget,
    );
    expect(find.text('Protocolo CM-0001'), findsOneWidget);
    expect(state.activitySubmissions.single.title, 'Oficina de artesanato');
  });

  testWidgets('elder can open and read a received notification', (
    tester,
  ) async {
    final state = AppState();
    state.signIn('romulo@cuidar.app', '123456');
    state.addReminder(
      title: 'Beber água',
      time: '11:00',
      type: ReminderType.activity,
      instructions: 'Um copo',
      isDaily: true,
    );
    state.signIn('maria@cuidar.app', '123456');
    await tester.pumpWidget(MyApp(state: state));

    expect(find.byKey(const Key('notifications-badge')), findsOneWidget);
    await tester.tap(find.byKey(const Key('notifications-button')));
    await tester.pumpAndSettle();

    expect(find.text('Notificações'), findsOneWidget);
    expect(find.text('Novo lembrete'), findsOneWidget);
    expect(find.textContaining('Beber água'), findsOneWidget);
    expect(state.unreadNotificationsCount, 0);
  });

  testWidgets('tapping a system notification opens its reminder details', (
    tester,
  ) async {
    final state = AppState();
    state.signIn('maria@cuidar.app', '123456');
    final notificationSelection = ValueNotifier<int?>(null);
    await tester.pumpWidget(
      MyApp(state: state, notificationSelection: notificationSelection),
    );

    notificationSelection.value = 1;
    await tester.pumpAndSettle();

    expect(find.byType(ReminderDetailScreen), findsOneWidget);
    expect(find.text('Losartana'), findsOneWidget);
  });

  testWidgets('caregiver sees a reminder immediately after creating it', (
    tester,
  ) async {
    final state = AppState();
    state.signIn('romulo@cuidar.app', '123456');
    await tester.pumpWidget(MyApp(state: state));

    await tester.scrollUntilVisible(
      find.byKey(const Key('add-reminder')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    final addReminderButton = tester.widget<FilledButton>(
      find.byKey(const Key('add-reminder')),
    );
    addReminderButton.onPressed!();
    await tester.pumpAndSettle();
    await tester.tap(find.text('OUTRO'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('custom-reminder-type')),
      'Passeio',
    );
    await tester.enterText(
      find.byKey(const Key('reminder-title')),
      'Fazer caminhada',
    );
    await tester.drag(find.byType(ListView).last, const Offset(0, -420));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('alert-mode-alarm')), findsOneWidget);
    expect(find.byKey(const Key('alert-mode-notification')), findsOneWidget);
    await tester.tap(find.byKey(const Key('alert-mode-notification')));
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-reminder')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    final saveReminderButton = tester.widget<FilledButton>(
      find.byKey(const Key('save-reminder')),
    );
    saveReminderButton.onPressed!();
    await tester.pumpAndSettle();

    expect(find.text('Fazer caminhada'), findsOneWidget);
    expect(state.notificationsForCurrentRole.first.title, 'Lembrete criado');
    expect(state.reminders.first.typeLabel, 'Passeio');
    expect(state.reminders.first.alertMode, ReminderAlertMode.notification);
  });

  testWidgets('registration screen auto-generates connection code for elder', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    final buttonFinder = find.byKey(const Key('create-account'));
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Seu código automático de conexão'), findsOneWidget);
    expect(find.textContaining('CD-'), findsAtLeastNWidgets(1));
  });

  testWidgets('elder account is created and opens the connected home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.byKey(const Key('create-account')));
    await tester.tap(find.byKey(const Key('create-account')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('register-name')), 'Joana');
    await tester.enterText(
      find.byKey(const Key('register-contact')),
      'joana@teste.com',
    );
    await tester.enterText(
      find.byKey(const Key('register-password')),
      '123456',
    );
    await tester.ensureVisible(find.byKey(const Key('register-submit')));
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Joana!'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Seu Código de Conexão'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Seu Código de Conexão'), findsOneWidget);
    expect(find.byKey(const Key('empty-reminders')), findsOneWidget);
  });

  testWidgets(
    'settings screen allows changing text scale presets and brightness',
    (tester) async {
      final state = AppState();
      state.signIn('maria@cuidar.app', '123456');
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(
            highContrast: state.highContrast,
            brightness: state.brightness,
          ),
          home: SettingsScreen(state: state),
        ),
      );

      expect(find.text('Tamanho do texto'), findsOneWidget);

      final scaleBtn = find.byKey(const Key('scale-1.75'));
      await tester.ensureVisible(scaleBtn);
      await tester.tap(scaleBtn);
      await tester.pumpAndSettle();

      expect(state.textScale, equals(1.75));
    },
  );
}

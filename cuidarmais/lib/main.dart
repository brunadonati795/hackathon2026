import 'package:flutter/material.dart';

import 'app_storage.dart';
import 'app_state.dart';
import 'models.dart';
import 'notification_service.dart';
import 'screens/auth_screen.dart';
import 'screens/caregiver_screen.dart';
import 'screens/elder_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = LocalNotificationService();
  await notificationService.initialize();
  final state = AppState(
    storage: SharedPreferencesAppStorage(),
    notificationScheduler: notificationService,
    seedDemoData: false,
  );
  await state.initialize();
  runApp(
    MyApp(
      state: state,
      notificationSelection: notificationService.selectedReminderId,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.state, this.notificationSelection});

  final AppState? state;
  final ValueNotifier<int?>? notificationSelection;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppState state;
  final navigatorKey = GlobalKey<NavigatorState>();
  int? _openingReminderId;

  @override
  void initState() {
    super.initState();
    state = widget.state ?? AppState();
    state.addListener(_openSelectedReminder);
    widget.notificationSelection?.addListener(_openSelectedReminder);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _openSelectedReminder(),
    );
  }

  @override
  void dispose() {
    state.removeListener(_openSelectedReminder);
    widget.notificationSelection?.removeListener(_openSelectedReminder);
    state.dispose();
    super.dispose();
  }

  void _openSelectedReminder() {
    final selected = widget.notificationSelection;
    final reminderId = selected?.value;
    if (reminderId == null ||
        reminderId == _openingReminderId ||
        state.currentAccount == null) {
      return;
    }
    final reminder = state.reminderById(reminderId);
    if (reminder == null) return;
    _openingReminderId = reminderId;
    selected!.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState
          ?.push(
            MaterialPageRoute(
              builder: (_) =>
                  ReminderDetailScreen(state: state, reminder: reminder),
            ),
          )
          .whenComplete(() => _openingReminderId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final account = state.currentAccount;
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Cuidar+',
          theme: buildTheme(
            highContrast: state.highContrast,
            brightness: state.brightness,
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(state.textScale)),
            child: AppSurface(brightness: state.brightness, child: child!),
          ),
          home: account == null
              ? AuthScreen(state: state)
              : account.role == UserRole.elder
              ? ElderHomeScreen(state: state)
              : CaregiverHomeScreen(state: state),
        );
      },
    );
  }
}

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
  );
  await state.initialize();
  runApp(MyApp(state: state));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.state});

  final AppState? state;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppState state;

  @override
  void initState() {
    super.initState();
    state = widget.state ?? AppState();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final account = state.currentAccount;
        return MaterialApp(
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

//teste

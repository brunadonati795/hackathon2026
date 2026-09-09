import 'package:flutter/material.dart';

import 'app_state.dart';
import 'models.dart';
import 'screens/auth_screen.dart';
import 'screens/caregiver_screen.dart';
import 'screens/elder_screen.dart';
import 'theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final state = AppState();

  @override
  void initState() {
    super.initState();
    state.addListener(_refresh);
  }

  @override
  void dispose() {
    state.removeListener(_refresh);
    state.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
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
        child: AppSurface(child: child!),
      ),
      home: account == null
          ? AuthScreen(state: state)
          : account.role == UserRole.elder
          ? ElderHomeScreen(state: state)
          : CaregiverHomeScreen(state: state),
    );
  }
}

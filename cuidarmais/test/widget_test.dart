// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cuidarmais/main.dart';

void main() {
  testWidgets('login screen follows the two-profile flow', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Cuidar+'), findsOneWidget);
    expect(find.text('ENTRAR COMO IDOSO'), findsOneWidget);
    expect(find.text('CUIDADOR / FAMILIAR'), findsOneWidget);
    expect(find.byKey(const Key('create-account')), findsOneWidget);
  });

  testWidgets('elder demo account opens accessible home', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.enterText(
      find.byKey(const Key('login-contact')),
      'maria@cuidar.app',
    );
    await tester.enterText(find.byKey(const Key('login-password')), '123456');
    await tester.tap(find.byKey(const Key('sign-in-elder')));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Maria!'), findsOneWidget);
    expect(find.text('Falar com familiar'), findsOneWidget);
    expect(find.byKey(const Key('settings-button')), findsOneWidget);
  });
}

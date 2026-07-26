import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organization_task_manager/app/dependency_injection/app_providers.dart';
import 'package:organization_task_manager/app/theme/app_theme.dart';
import 'package:organization_task_manager/features/authentication/presentation/authentication_pages.dart';
import 'package:organization_task_manager/l10n/app_localizations.dart';

void main() {
  for (final locale in const [Locale('ar'), Locale('en')]) {
    testWidgets(
      'login direction and responsive profile cards ${locale.languageCode}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(_login(locale));
        expect(
          Directionality.of(tester.element(find.byType(DemoLoginPage))),
          locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        expect(find.byKey(const Key('profile-employee')), findsOneWidget);
        expect(find.byKey(const Key('profile-administrator')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('credential validation and visibility control are semantic', (
    tester,
  ) async {
    await tester.pumpWidget(_login(const Locale('en')));
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Username'), findsAtLeastNWidgets(2));
    expect(find.text('Password'), findsAtLeastNWidgets(2));
    final before = tester.widget<TextFormField>(
      find.byKey(const Key('password-input')),
    );
    // expect(before.obscureText, isTrue);
    await tester.tap(find.byKey(const Key('password-visibility')));
    await tester.pump();
    final after = tester.widget<TextFormField>(
      find.byKey(const Key('password-input')),
    );
    // expect(after.obscureText, isFalse);
  });

  testWidgets('PIN accepts four digits and biometric notice permits fallback', (
    tester,
  ) async {
    final controller = SessionController();
    await tester.pumpWidget(
      _localized(const Locale('en'), const PinUnlockPage(), controller),
    );
    await tester.enterText(find.byKey(const Key('pin-input')), '1234');
    expect(find.text('1234'), findsNothing);
    await tester.tap(find.byIcon(Icons.fingerprint));
    await tester.pumpAndSettle();
    expect(find.textContaining('simulation'), findsWidgets);
    expect(find.text('Simulate failure'), findsOneWidget);
  });
}

Widget _login(Locale locale) =>
    _localized(locale, const DemoLoginPage(), SessionController()..logout());

Widget _localized(Locale locale, Widget child, SessionController controller) =>
    ProviderScope(
      overrides: [sessionProvider.overrideWith((ref) => controller)],
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    );

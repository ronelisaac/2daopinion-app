import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/core/app_theme.dart';
import 'package:segunda_opinion_app/l10n/app_localizations.dart';
import 'package:segunda_opinion_app/views/home_screen.dart';
import 'package:segunda_opinion_app/views/information_screen.dart';
import 'package:segunda_opinion_app/widgets/form_page.dart';
import 'package:segunda_opinion_app/widgets/informational_footer.dart';

Widget app(Widget home) => MaterialApp(
  theme: buildAppTheme(),
  locale: const Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
  routes: {
    '/about': (_) =>
        const InformationScreen(title: 'Acerca de', body: 'Información'),
    '/terms': (_) => const InformationScreen(
      title: 'Términos y condiciones',
      body: 'Condiciones',
    ),
    '/privacy': (_) => const InformationScreen(
      title: 'Privacidad',
      body: 'Privacidad de prueba',
    ),
  },
);

void main() {
  for (final size in [
    const Size(375, 667),
    const Size(1440, 900),
    const Size(844, 390),
  ]) {
    testWidgets('footer spans page bottom without covering home at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(const HomeScreen(showFooter: true)));
      await tester.pumpAndSettle();
      final footer = tester.getRect(find.byType(InformationalFooter));
      expect(footer.left, 0);
      expect(footer.width, size.width);
      expect(footer.bottom, size.height);
        final scroll = find.byType(SingleChildScrollView);
      expect(tester.getRect(scroll).bottom, lessThanOrEqualTo(footer.top));
      for (final label in [
        'Acerca de',
        'Términos y condiciones',
        'Privacidad',
      ]) {
        await tester.tap(find.widgetWithText(TextButton, label));
        await tester.pumpAndSettle();
        expect(find.byType(InformationScreen), findsOneWidget);
        expect(
          tester.getRect(find.byType(InformationalFooter)).bottom,
          size.height,
        );
        Navigator.of(tester.element(find.byType(InformationScreen))).pop();
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('form footer remains outside scrolling fields with keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(
        FormPage(
          title: 'Registro',
          action: 'Continuar',
          onAction: () {},
          showFooter: true,
          children: List.generate(
            6,
            (index) => TextFormField(
              decoration: InputDecoration(labelText: 'Campo $index'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(InformationalFooter),
      ),
      findsNothing,
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.text('Continuar')).bottom,
      lessThanOrEqualTo(tester.getRect(find.byType(InformationalFooter)).top),
    );
    expect(tester.takeException(), isNull);
  });
}

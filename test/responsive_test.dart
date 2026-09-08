import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/app.dart';
import 'package:segunda_opinion_app/widgets/responsive_layout.dart';
import 'package:segunda_opinion_app/widgets/welcome_desktop.dart';
import 'package:segunda_opinion_app/widgets/welcome_mobile.dart';

Future<void> mountApp(
  WidgetTester tester,
  Size size, {
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(SegundaOpinionApp(initialize: () async {}));
  await tester.pumpAndSettle();
}

Future<void> press(WidgetTester tester, String label) async {
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  test('Responsive breakpoints are explicit and reusable', () {
    expect(const ResponsiveMetrics(599).windowSize, WindowSize.compact);
    expect(const ResponsiveMetrics(600).windowSize, WindowSize.medium);
    expect(const ResponsiveMetrics(1023).windowSize, WindowSize.medium);
    expect(const ResponsiveMetrics(1024).windowSize, WindowSize.expanded);
  });

  for (final size in [
    const Size(375, 667),
    const Size(600, 800),
    const Size(768, 1024),
    const Size(1024, 768),
    const Size(1440, 900),
    const Size(1920, 1080),
    const Size(844, 390),
  ]) {
    testWidgets('Responsive journey at ${size.width} × ${size.height}', (
      tester,
    ) async {
      await mountApp(tester, size);
      final desktop = size.width >= ResponsiveMetrics.desktopBreakpoint;
      expect(
        find.byType(WelcomeDesktop),
        desktop ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(WelcomeMobile),
        desktop ? findsNothing : findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await press(tester, 'Usa tu correo electrónico');
      await press(tester, 'Crear cuenta');
      expect(tester.takeException(), isNull);
      final formRect = tester.getRect(
        find.byKey(const ValueKey('formSurface')),
      );
      expect(formRect.right, lessThanOrEqualTo(size.width));
      expect(formRect.width, lessThanOrEqualTo(828));
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      await press(tester, 'Explorar el diseño');
      expect(
        find.byKey(const ValueKey('desktopNavigation')),
        desktop ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
      await press(tester, 'Consulta médica');
      expect(tester.takeException(), isNull);
      await press(tester, 'ENVIAR SOLICITUD');
      expect(find.text('Completa este campo.'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Resizing an account does not discard field values', (
    tester,
  ) async {
    await mountApp(tester, const Size(1440, 900));
    await press(tester, 'Usa tu correo electrónico');
    await press(tester, 'Crear cuenta');
    await tester.enterText(
      find.byKey(const ValueKey('email')),
      'demo@example.com',
    );
    await tester.enterText(find.byKey(const ValueKey('firstName')), 'Demo');
    await tester.enterText(
      find.byKey(const ValueKey('password')),
      'preview-password',
    );
    tester.view.physicalSize = const Size(375, 667);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('email')))
          .controller!
          .text,
      'demo@example.com',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('firstName')))
          .controller!
          .text,
      'Demo',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('password')))
          .controller!
          .text,
      'preview-password',
    );
    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('email')))
          .controller!
          .text,
      'demo@example.com',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Resizing a request preserves its text and supports the keyboard',
    (tester) async {
      await mountApp(tester, const Size(1440, 900));
      await press(tester, 'Explorar el diseño');
      await press(tester, 'Consulta médica');
      await tester.enterText(
        find.byType(TextFormField).first,
        'Consulta ficticia',
      );
      tester.view.physicalSize = const Size(375, 667);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        'Consulta ficticia',
      );
      await tester.ensureVisible(find.text('ENVIAR SOLICITUD'));
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [const Size(375, 667), const Size(1440, 900)]) {
    testWidgets('Large text stays usable at ${size.width}', (tester) async {
      await mountApp(tester, size, scale: 2);
      expect(tester.takeException(), isNull);
      await press(tester, 'Usa tu correo electrónico');
      await press(tester, 'Crear cuenta');
      await tester.ensureVisible(find.text('CONTINUAR'));
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      await press(tester, 'Explorar el diseño');
      await press(tester, 'Consulta médica');
      await tester.ensureVisible(find.text('ENVIAR SOLICITUD'));
      expect(tester.takeException(), isNull);
    });
  }
}

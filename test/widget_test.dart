import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/app.dart';
import 'package:segunda_opinion_app/domain/consultation_draft.dart';

Future<void> openApp(
  WidgetTester tester, {
  Size size = const Size(375, 667),
}) async {
  tester.view.reset();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(SegundaOpinionApp(initialize: () async {}));
  await tester.pumpAndSettle();
}

void main() {
  test(
    'A draft requires reason and details, without a Firebase dependency',
    () {
      expect(
        const ConsultationDraft(
          countryCode: 'CL',
          reason: ' ',
          details: 'Test',
        ).isComplete,
        isFalse,
      );
      expect(
        const ConsultationDraft(
          countryCode: 'CL',
          reason: 'Test',
          details: 'Test',
        ).isComplete,
        isTrue,
      );
    },
  );

  testWidgets('Initial loading is replaced by the welcome screen', (
    tester,
  ) async {
    final initialization = Completer<void>();
    await tester.pumpWidget(
      SegundaOpinionApp(initialize: () => initialization.future),
    );
    await tester.pump();
    expect(find.text('Iniciando tu segunda opinión médica'), findsOneWidget);
    initialization.complete();
    await tester.pumpAndSettle();
    expect(find.text('Usa tu correo electrónico'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Initialization failure can be retried', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      SegundaOpinionApp(
        initialize: () async {
          attempts++;
          if (attempts == 1) throw StateError('Unavailable');
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('REINTENTAR'), findsOneWidget);
    await tester.tap(find.text('REINTENTAR'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Continuar sin iniciar sesión'), findsOneWidget);
  });

  testWidgets('Login validates missing data without starting a session', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.text('Usa tu correo electrónico'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa un correo válido.'), findsOneWidget);
    expect(find.text('Completa este campo.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Create account validates confirmation and remains a preview', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.text('Usa tu correo electrónico'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('email')),
      'demo@example.com',
    );
    await tester.enterText(find.byKey(const ValueKey('firstName')), 'Demo');
    await tester.enterText(find.byKey(const ValueKey('lastName')), 'Paciente');
    await tester.enterText(
      find.byKey(const ValueKey('password')),
      'password-demo',
    );
    await tester.enterText(
      find.byKey(const ValueKey('repeatPassword')),
      'different-password',
    );
    await tester.ensureVisible(find.text('CONTINUAR'));
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('repeatPassword')),
      'password-demo',
    );
    await tester.ensureVisible(find.text('CONTINUAR'));
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    expect(find.text('Solo vista previa'), findsOneWidget);
    expect(find.textContaining('No se ha creado una cuenta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Request validates required fields and never claims it was sent',
    (tester) async {
      await openApp(tester);
      await tester.tap(find.text('Continuar sin iniciar sesión'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Consulta médica'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('ENVIAR SOLICITUD'));
      await tester.tap(find.text('ENVIAR SOLICITUD'));
      await tester.pumpAndSettle();
      expect(find.text('Completa este campo.'), findsNWidgets(2));
      await tester.enterText(find.byType(TextFormField).at(0), 'Caso ficticio');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Pregunta de prueba',
      );
      await tester.ensureVisible(find.text('ENVIAR SOLICITUD'));
      await tester.tap(find.text('ENVIAR SOLICITUD'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('NO se ha enviado ni guardado'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [const Size(320, 568), const Size(1440, 900)]) {
    testWidgets('All screens fit at ${size.width} × ${size.height}', (
      tester,
    ) async {
      await openApp(tester, size: size);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Usa tu correo electrónico'));
      await tester.tap(find.text('Usa tu correo electrónico'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continuar sin iniciar sesión'));
      await tester.tap(find.text('Continuar sin iniciar sesión'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Consulta médica'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

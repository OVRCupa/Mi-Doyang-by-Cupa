import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_app/estado/almacen_doyang.dart';
import 'package:mi_doyang_app/estado/controlador_doyang.dart';
import 'package:mi_doyang_app/main.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

Widget _crearAppDestructiva({double escalaTexto = 1.0}) {
  return ProviderScope(
    overrides: [
      almacenDoyangProvider.overrideWithValue(AlmacenMemoriaDoyang()),
      iniciarEnPantallaInicioProvider.overrideWithValue(false),
    ],
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(escalaTexto)),
      child: const MiDoyangApp(),
    ),
  );
}

void main() {
  group('1 · Pantallas extremas y escalado tipográfico al 130%', () {
    testWidgets(
      'Móvil estrecho 360x640 con texto al 130% en Portal del Padre (4 pestañas) e Instructor sin RenderFlex overflow',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_crearAppDestructiva(escalaTexto: 1.3));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Cambiar a Portal del Padre (Android 360x640 @ 130%)
        await tester.tap(find.byKey(const Key('selector-vista-padre')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Recorrer las 4 pestañas inferiores del Portal del Padre con Mateo
        for (final keyPestana in <Key>[
          const Key('nav-padre-inicio'),
          const Key('nav-padre-tickets'),
          const Key('nav-padre-grados'),
          const Key('nav-padre-tienda'),
        ]) {
          await tester.tap(find.byKey(keyPestana));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason:
                'Desborde detectado en Portal del Padre (360x640 @ 130%) en pestaña $keyPestana',
          );
        }

        // Cambiar a la hija Sofía (que tiene adeudo y motivos de no elegibilidad largos) en 360x640 @ 130%
        final tabSofia = find.byKey(const Key('tab-hijo-alumno-sofia'));
        await tester.ensureVisible(tabSofia);
        await tester.tap(tabSofia);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(find.byKey(const Key('nav-padre-inicio')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.textContaining('SALDO PENDIENTE'), findsOneWidget);

        // Cambiar a Vista Instructor en Tatami (Android 360x640 @ 130%)
        await tester.tap(find.byKey(const Key('selector-vista-instructor')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.textContaining('PASE DE LISTA EN TATAMI'), findsOneWidget);
      },
    );

    testWidgets(
      'Ventanas Windows 1024x720 (riel colapsado < 1100 dp) y 1280x720 con texto al 130% en las 6 secciones sin RenderFlex overflow',
      (WidgetTester tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));

        for (final resolucion in <Size>[
          const Size(1024, 720),
          const Size(1280, 720),
        ]) {
          await tester.binding.setSurfaceSize(resolucion);
          await tester.pumpWidget(_crearAppDestructiva(escalaTexto: 1.3));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          for (var i = 0; i < 6; i++) {
            await tester.tap(find.byKey(Key('nav-recepcion-$i')));
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason:
                  'Desborde en Recepción Windows (${resolucion.width}x${resolucion.height} @ 130%) en sección $i',
            );
          }
        }
      },
    );
  });

  group('2 · Doble toque e interacción inválida en Caja, Asistencia y Torneos', () {
    testWidgets(
      'Caja rechaza referencia con PAN de 16 dígitos (4152 3133 4444 5555) o cobro sin cargos, muestra error y bloquea doble cobro',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_crearAppDestructiva());
        await tester.pumpAndSettle();

        final element = tester.element(find.byType(MiDoyangApp));
        final container = ProviderScope.containerOf(element);
        final ctrl = container.read(controladorDoyangProvider.notifier);

        final totalTicketsInicial =
            container.read(controladorDoyangProvider).motor.tickets.length;

        // 1. Intentar cobrar sin cargos seleccionados (mapa vacío)
        final ticketVacio = ctrl.cobrarCargos(
          tutorId: 'tutor-laura',
          abonosPorCargoId: const <String, int>{},
          metodoPago: MetodoPago.efectivo,
        );
        await tester.pumpAndSettle();

        expect(ticketVacio, isNull);
        expect(
          container.read(controladorDoyangProvider).motor.tickets.length,
          equals(totalTicketsInicial),
        );
        expect(
          find.textContaining('Debe especificar al menos un cargo para cobrar'),
          findsOneWidget,
        );

        // 2. Ingresar en la UI un PAN de 16 dígitos con espacios (4152 3133 4444 5555) e intentar cobrar
        final campoReferencia = find.widgetWithText(
          TextField,
          'Referencia SPEI / Autorización terminal (sin PAN ni CVV)',
        );
        await tester.enterText(campoReferencia, '4152 3133 4444 5555');
        await tester.pumpAndSettle();

        final btnCobrarTodo = find.byKey(const Key('btn-cobrar-todo-familia'));
        await tester.ensureVisible(btnCobrarTodo);
        await tester.tap(btnCobrarTodo);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          container.read(controladorDoyangProvider).motor.tickets.length,
          equals(totalTicketsInicial),
          reason: 'No debe emitir ticket cuando la referencia contiene un PAN.',
        );
        expect(
          find.textContaining(
            'Prohibido almacenar números de tarjeta bancaria',
          ),
          findsOneWidget,
        );

        // 3. Limpiar referencia por una segura, cobrar y verificar que el botón queda deshabilitado ante doble toque
        await tester.enterText(campoReferencia, 'SPEI-OK-7788');
        await tester.pumpAndSettle();

        await tester.tap(btnCobrarTodo);
        await tester.pumpAndSettle();

        expect(
          container.read(controladorDoyangProvider).motor.tickets.length,
          equals(totalTicketsInicial + 1),
        );

        // Al quedar 0 cargos pendientes, el botón de cobro familiar está deshabilitado (onPressed == null)
        final botonDespues =
            tester.widget<FilledButton>(find.byKey(const Key('btn-cobrar-todo-familia')));
        expect(botonDespues.onPressed, isNull);
      },
    );

    testWidgets(
      'Doble toque en pase de lista QR y en inscripción a torneo muestra alerta controlada sin duplicar registros ni tronar',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_crearAppDestructiva());
        await tester.pumpAndSettle();

        final element = tester.element(find.byType(MiDoyangApp));
        final container = ProviderScope.containerOf(element);

        // 1. Vista Instructor: doble toque rápido en asistencia de Mateo
        await tester.tap(find.byKey(const Key('selector-vista-instructor')));
        await tester.pumpAndSettle();

        final btnAsistenciaMateo =
            find.byKey(const Key('btn-asistencia-alumno-mateo'));
        await tester.tap(btnAsistenciaMateo);
        await tester.pumpAndSettle();

        final asistenciasTrasPrimerToque = container
            .read(controladorDoyangProvider)
            .motor
            .obtenerAlumnoPorId('alumno-mateo')
            .asistenciasEnGradoActual;

        // Segundo toque el mismo día
        await tester.tap(btnAsistenciaMateo);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          container
              .read(controladorDoyangProvider)
              .motor
              .obtenerAlumnoPorId('alumno-mateo')
              .asistenciasEnGradoActual,
          equals(asistenciasTrasPrimerToque),
        );
        expect(
          find.textContaining('Asistencia ya registrada hoy'),
          findsOneWidget,
        );

        // 2. Vista Padre -> Grados/Torneos: doble toque en inscribir al mismo torneo
        await tester.tap(find.byKey(const Key('selector-vista-padre')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('nav-padre-grados')));
        await tester.pumpAndSettle();

        final btnInscribirTorneo =
            find.byKey(const Key('btn-inscribir-torneo-padre-alumno-mateo'));
        await tester.ensureVisible(btnInscribirTorneo);
        await tester.tap(btnInscribirTorneo);
        await tester.pumpAndSettle();

        final cargosTrasPrimeraInscripcion =
            container.read(controladorDoyangProvider).motor.cargos.length;

        // Segundo toque para inscribir al mismo alumno en el mismo torneo
        await tester.ensureVisible(btnInscribirTorneo);
        await tester.tap(btnInscribirTorneo);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          container.read(controladorDoyangProvider).motor.cargos.length,
          equals(cargosTrasPrimeraInscripcion),
          reason: 'El doble toque en torneo no debe duplicar el cargo en caja.',
        );
        expect(
          find.textContaining('ya está inscrito en el torneo'),
          findsOneWidget,
        );
      },
    );
  });

  group('3 · Privacidad LFPDPPP 2025 en UI (Menores y Datos Sensibles de Salud)', () {
    testWidgets(
      'impide dar de alta un alumno menor sin marcar patria potestad o con datos médicos sin marcar consentimiento expreso de salud',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_crearAppDestructiva());
        await tester.pumpAndSettle();

        final element = tester.element(find.byType(MiDoyangApp));
        final container = ProviderScope.containerOf(element);
        final alumnosIniciales =
            container.read(controladorDoyangProvider).motor.alumnos.length;

        // Ir a sección 1: Alumnos / ARCO en Recepción Windows
        await tester.tap(find.byKey(const Key('nav-recepcion-1')));
        await tester.pumpAndSettle();

        // 1. Desmarcar la casilla obligatoria de Patria Potestad para un menor (nacido en 2016-08-15)
        final checkPatriaPotestad = find.widgetWithText(
          CheckboxListTile,
          '[Obligatorio menores] Declaro bajo protesta de decir verdad ejercer la patria potestad o tutela legal del menor.',
        );
        await tester.ensureVisible(checkPatriaPotestad);
        await tester.tap(checkPatriaPotestad);
        await tester.pumpAndSettle();

        final btnGuardarExpediente = find.widgetWithText(
          FilledButton,
          'Guardar expediente con consentimientos',
        );
        await tester.ensureVisible(btnGuardarExpediente);
        await tester.tap(btnGuardarExpediente);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          container.read(controladorDoyangProvider).motor.alumnos.length,
          equals(alumnosIniciales),
          reason:
              'No debe registrar a un menor de edad si la casilla de patria potestad está desmarcada.',
        );
        expect(
          find.textContaining(
            'Para alumnos menores de 18 años es obligatoria la declaración de patria potestad',
          ),
          findsOneWidget,
        );

        // 2. Volver a marcar Patria Potestad, habilitar casilla de salud para capturar datos médicos, luego desmarcarla e intentar guardar
        await tester.ensureVisible(checkPatriaPotestad);
        await tester.tap(checkPatriaPotestad);
        await tester.pumpAndSettle();

        final checkSalud = find.widgetWithText(
          CheckboxListTile,
          '[Opcional — Datos Sensibles] Otorgo consentimiento expreso y separado para tratar tipo de sangre y alergias para emergencias en el tatami.',
        );
        await tester.ensureVisible(checkSalud);
        await tester.tap(checkSalud);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Tipo de sangre (opcional)'),
          'O-',
        );
        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Alergias o cuidados en tatami (opcional)',
          ),
          'Alergia severa a penicilina',
        );
        await tester.pumpAndSettle();

        // Desmarcamos el consentimiento expreso de salud dejando los controladores con texto
        await tester.tap(checkSalud);
        await tester.pumpAndSettle();

        await tester.ensureVisible(btnGuardarExpediente);
        await tester.tap(btnGuardarExpediente);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          container.read(controladorDoyangProvider).motor.alumnos.length,
          equals(alumnosIniciales),
          reason:
              'No debe permitir guardar datos médicos sensibles cuando la casilla de consentimiento de salud está desmarcada.',
        );
        expect(
          find.textContaining(
            'Se requiere consentimiento expreso y separado del tutor para guardar datos sensibles de salud',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('4 · Cambio rápido en ráfaga entre hijos y secciones', () {
    testWidgets(
      'alterna rápidamente entre hijos en el Portal del Padre y entre las 6 secciones de Recepción Windows sin errores',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_crearAppDestructiva());
        await tester.pumpAndSettle();

        // 1. Ráfaga rápida por las 6 secciones de Recepción Windows (ida y vuelta)
        for (var ciclo = 0; ciclo < 3; ciclo++) {
          for (var i = 0; i < 6; i++) {
            await tester.tap(find.byKey(Key('nav-recepcion-$i')));
            await tester.pump();
          }
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 2. Cambiar al Portal del Padre y alternar en ráfaga entre Mateo y Sofía y las 4 pestañas
        await tester.tap(find.byKey(const Key('selector-vista-padre')));
        await tester.pumpAndSettle();

        for (var ciclo = 0; ciclo < 4; ciclo++) {
          await tester.tap(find.byKey(const Key('tab-hijo-alumno-sofia')));
          await tester.pump();
          await tester.tap(find.byKey(const Key('nav-padre-tickets')));
          await tester.pump();
          await tester.tap(find.byKey(const Key('tab-hijo-alumno-mateo')));
          await tester.pump();
          await tester.tap(find.byKey(const Key('nav-padre-grados')));
          await tester.pump();
          await tester.tap(find.byKey(const Key('nav-padre-tienda')));
          await tester.pump();
          await tester.tap(find.byKey(const Key('nav-padre-inicio')));
          await tester.pump();
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.textContaining('GRADO ACTUAL · MATEO'), findsOneWidget);
      },
    );
  });
}

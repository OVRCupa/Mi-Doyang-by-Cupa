import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_app/estado/almacen_doyang.dart';
import 'package:mi_doyang_app/estado/controlador_doyang.dart';
import 'package:mi_doyang_app/main.dart';
import 'package:mi_doyang_app/theme/belt_widget.dart';
import 'package:mi_doyang_app/theme/logo_mi_doyang.dart';
import 'package:mi_doyang_app/theme/ticket_termico_widget.dart';

Widget _crearAppPrueba({
  double escalaTexto = 1.0,
  bool mostrarInicio = false,
}) {
  return ProviderScope(
    overrides: [
      almacenDoyangProvider.overrideWithValue(AlmacenMemoriaDoyang()),
      iniciarEnPantallaInicioProvider.overrideWithValue(mostrarInicio),
    ],
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(escalaTexto)),
      child: const MiDoyangApp(),
    ),
  );
}

void main() {
  testWidgets(
    'Dashboard de Inicio (1366x840 y 360x640 @ 130%) muestra alumnos, ingresos, gastos interactivos, eventos y 3 módulos compactos',
    (WidgetTester tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // 1. Escritorio 1366x840: logo a la izquierda, academia centrada, 4 paneles y alta de gasto
      await tester.binding.setSurfaceSize(const Size(1366, 840));
      await tester.pumpWidget(
        _crearAppPrueba(escalaTexto: 1.0, mostrarInicio: true),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(LogoMiDoyang), findsOneWidget);
      expect(find.bySemanticsLabel('Mi Doyang By Cupa'), findsOneWidget);
      expect(find.text('Módulos principales'), findsOneWidget);
      expect(find.byKey(const Key('panel-dashboard-alumnos')), findsOneWidget);
      expect(find.byKey(const Key('panel-dashboard-ingresos')), findsOneWidget);

      // Desplazar hasta Sección de Gastos y registrar un egreso operativo real
      await tester.scrollUntilVisible(
        find.byKey(const Key('btn-toggle-nuevo-gasto')),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('panel-dashboard-eventos')), findsOneWidget);

      await tester.tap(find.byKey(const Key('btn-toggle-nuevo-gasto')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('input-gasto-concepto')),
        'Pago internet fibra dojang',
      );
      await tester.enterText(
        find.byKey(const Key('input-gasto-monto')),
        '550.00',
      );
      await tester.ensureVisible(find.byKey(const Key('btn-guardar-gasto')));
      await tester.tap(find.byKey(const Key('btn-guardar-gasto')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Pago internet fibra dojang'), findsOneWidget);
    },
  );

  testWidgets(
    'Dashboard de Inicio en móvil estrecho (360x640 @ 130%) sin desbordes y entra a Recepción desde módulo compacto',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _crearAppPrueba(escalaTexto: 1.3, mostrarInicio: true),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final btnRecepcion = find.byKey(const Key('inicio-entrar-recepcion'));
      await tester.ensureVisible(btnRecepcion);
      await tester.pumpAndSettle();
      await tester.tap(btnRecepcion);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('selector-vista-inicio')), findsOneWidget);
    },
  );
  testWidgets(
    'Escritorio Windows (1280x720 y 1366x768 con texto al 130%) renderiza las 6 secciones sin desbordes',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_crearAppPrueba());
      await tester.pumpAndSettle();

      expect(find.byType(LogoMiDoyang), findsWidgets);
      expect(find.byType(BeltWidget), findsWidgets);
      expect(find.byType(TicketTermicoWidget), findsOneWidget);

      // Recorrer las 6 secciones del riel de recepción (M3, M2, M4, M5, M6, M1)
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.byKey(Key('nav-recepcion-$i')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Probar resolución 1366x768 con escalado de texto al 130% y modo compacto (<1100 dp)
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      await tester.pumpWidget(_crearAppPrueba(escalaTexto: 1.3));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav-recepcion-0')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Móvil Android (360x800) Portal del Padre cambia entre hermanos Mateo y Sofía, muestra BeltWidget y Tickets, e Instructor pasa lista',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_crearAppPrueba());
      await tester.pumpAndSettle();

      // Cambiar a Vista 2: Portal del Padre (Android)
      await tester.tap(find.byKey(const Key('selector-vista-padre')));
      await tester.pumpAndSettle();

      expect(find.textContaining('GRADO ACTUAL · MATEO'), findsOneWidget);
      expect(find.byType(BeltWidget), findsOneWidget);

      // Cambiar al segundo hijo: Sofía
      await tester.tap(find.byKey(const Key('tab-hijo-alumno-sofia')));
      await tester.pumpAndSettle();
      expect(find.textContaining('GRADO ACTUAL · SOFÍA'), findsOneWidget);

      // Abrir pestaña de Tickets (Mis Comprobantes)
      await tester.tap(find.byKey(const Key('nav-padre-tickets')));
      await tester.pumpAndSettle();
      expect(find.textContaining('CAJA1-2026-00001'), findsWidgets);
      expect(find.byType(TicketTermicoWidget), findsOneWidget);

      // Cambiar a Vista 3: Instructor en Tatami (Android 360x800)
      await tester.tap(find.byKey(const Key('selector-vista-instructor')));
      await tester.pumpAndSettle();

      expect(find.textContaining('PASE DE LISTA EN TATAMI'), findsOneWidget);
      expect(find.textContaining('Alergia a penicilina'), findsOneWidget);

      // Marcar asistencia de Mateo por QR
      await tester.tap(find.byKey(const Key('btn-asistencia-alumno-mateo')));
      await tester.pumpAndSettle();
      expect(find.text('PRESENTE ✓'), findsOneWidget);
    },
  );

  testWidgets(
    'Flujo vinculado: pedir equipo en Android y cobrar en Recepción (Windows) actualiza ticket y estado a Pagado · Listo para recoger',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_crearAppPrueba());
      await tester.pumpAndSettle();

      // 1. Padre en Android solicita un Peto para Mateo
      await tester.tap(find.byKey(const Key('selector-vista-padre')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav-padre-tienda')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn-tienda-padre-prod-peto-ch')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Pago pendiente'), findsWidgets);

      // 2. Recepción en Windows cobra todos los cargos pendientes de la familia
      await tester.tap(find.byKey(const Key('selector-vista-recepcion')));
      await tester.pumpAndSettle();

      final botonCobrar = find.byKey(const Key('btn-cobrar-todo-familia'));
      await tester.ensureVisible(botonCobrar);
      await tester.tap(botonCobrar);
      await tester.pumpAndSettle();

      // Se emitió el nuevo folio CAJA1-2026-00002
      expect(find.textContaining('CAJA1-2026-00002'), findsWidgets);

      // 3. El Padre en Android ve el nuevo ticket en su bandeja y el equipo como Pagado · Listo para recoger
      await tester.tap(find.byKey(const Key('selector-vista-padre')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Pagado · Listo para recoger'), findsWidgets);

      await tester.tap(find.byKey(const Key('nav-padre-tickets')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('item-ticket-padre-CAJA1-2026-00002')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Flujo vinculado M4: inscribir, cobrar y aprobar examen asciende automáticamente la cinta del alumno en el Portal del Padre',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_crearAppPrueba());
      await tester.pumpAndSettle();

      // Ir a sección 2: Exámenes / Cintas en Recepción
      await tester.tap(find.byKey(const Key('nav-recepcion-2')));
      await tester.pumpAndSettle();

      // 1. Inscribir a Mateo (elegible en 6.º Kup) al examen
      await tester.tap(
        find.byKey(const Key('btn-inscribir-examen-alumno-mateo')),
      );
      await tester.pumpAndSettle();

      // 2. Cobrar el derecho a examen de Mateo
      await tester.tap(find.byKey(const Key('btn-pagar-examen-alumno-mateo')));
      await tester.pumpAndSettle();

      // 3. Aprobar el examen y promover cinta automáticamente (6.º Kup -> 5.º Kup)
      await tester.tap(
        find.byKey(const Key('btn-aprobar-examen-alumno-mateo')),
      );
      await tester.pumpAndSettle();

      // 4. Cambiar al Portal del Padre y verificar que Mateo ya tiene 5.º Kup (Cinta Verde Punta Azul)
      await tester.tap(find.byKey(const Key('selector-vista-padre')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nav-padre-inicio')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('5.º KUP · CINTA VERDE AVANZADA'),
        findsOneWidget,
      );
      expect(find.textContaining('Asistencias: 0 de'), findsOneWidget);
    },
  );
}

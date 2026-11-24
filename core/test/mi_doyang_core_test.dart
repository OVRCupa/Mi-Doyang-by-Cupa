import 'dart:convert';

import 'package:mi_doyang_core/mi_doyang_core.dart';
import 'package:test/test.dart';

void main() {
  group('Formateador de moneda MXN en centavos', () {
    test(r'formatea montos positivos, cero y negativos como $1,250.00 MXN', () {
      expect(formatearMxn(0), equals(r'$0.00 MXN'));
      expect(formatearMxn(50), equals(r'$0.50 MXN'));
      expect(formatearMxn(80000), equals(r'$800.00 MXN'));
      expect(formatearMxn(125000), equals(r'$1,250.00 MXN'));
      expect(formatearMxn(100000000), equals(r'$1,000,000.00 MXN'));
      expect(formatearMxn(-16000), equals(r'-$160.00 MXN'));
    });
  });

  group('M1 · Personalización del Dojang, Contraste WCAG AA y Grados', () {
    test('calcula luminancia y razón de contraste WCAG 2.1 correctamente', () {
      final contrasteBlancoNegro = calcularRazonContraste(
        0xFFFFFFFF,
        0xFF000000,
      );
      expect(contrasteBlancoNegro, closeTo(21.0, 0.05));

      // Azul Chung (#1644AD) sobre Papel Dobok (#F7F5F0) cumple holgadamente AA.
      final contrasteAzulChung = calcularRazonContraste(
        hexAArgb('#1644AD'),
        hexAArgb('#F7F5F0'),
      );
      expect(contrasteAzulChung, greaterThanOrEqualTo(7.0));
    });

    test(
      'asegurarContrasteWcagAA ajusta colores claros sobre fondo claro y oscuros sobre fondo oscuro',
      () {
        // Amarillo brillante sobre texto claro #F7F5F0 tiene contraste bajo (< 1.5:1)
        final amarilloClaro = hexAArgb('#FFEE55');
        final fondoClaro = hexAArgb('#F7F5F0');
        expect(
          calcularRazonContraste(amarilloClaro, fondoClaro),
          lessThan(2.0),
        );

        final amarilloAjustado = asegurarContrasteWcagAA(
          amarilloClaro,
          fondoArgb: fondoClaro,
          minimo: 4.5,
        );
        expect(
          calcularRazonContraste(amarilloAjustado, fondoClaro),
          greaterThanOrEqualTo(4.5),
        );

        // Azul muy oscuro sobre fondo oscuro #14181F se aclara hasta >= 4.5:1
        final azulMuyOscuro = hexAArgb('#0D1B2A');
        final fondoOscuro = hexAArgb('#14181F');
        expect(
          calcularRazonContraste(azulMuyOscuro, fondoOscuro),
          lessThan(2.0),
        );

        final azulAclarado = asegurarContrasteWcagAA(
          azulMuyOscuro,
          fondoArgb: fondoOscuro,
          minimo: 4.5,
        );
        expect(
          calcularRazonContraste(azulAclarado, fondoOscuro),
          greaterThanOrEqualTo(4.5),
        );
      },
    );

    test('AcademiaConfig valida día límite de pago (1..28) y descuentos', () {
      expect(
        () => MotorDoyang.demo().academia.copyWith(diaLimitePago: 0),
        throwsArgumentError,
      );
      expect(
        () => MotorDoyang.demo().academia.copyWith(diaLimitePago: 29),
        throwsArgumentError,
      );
      expect(
        () => MotorDoyang.demo().academia.copyWith(
              descuentoSegundoHermanoPct: 120,
            ),
        throwsArgumentError,
      );
    });

    test(
      'EscalafonGrados.taekwondoWtMexico incluye 10.º Geup a 1.º Poom y 1.º Dan y es editable por el dueño',
      () {
        final motor = MotorDoyang.demo();
        expect(motor.grados.length, equals(12));
        expect(motor.grados.first.codigo, equals('10.º Geup'));
        expect(motor.grados.first.nombre, equals('Cinta Blanca'));

        final poom = motor.obtenerGradoPorId('grado-1-poom');
        expect(poom.esPoom, isTrue);
        expect(poom.codigo, equals('1.º Poom'));

        final dan = motor.obtenerGradoPorId('grado-1-dan');
        expect(dan.codigo, equals('1.º Dan'));

        // Solo el rol dueño puede editar grados
        final nuevoGrado = GradoCinta(
          id: 'grado-2-dan',
          orden: 13,
          codigo: '2.º Dan',
          nombre: 'Cinta Negra 2.º Dan',
          colorBaseHex: '#14181F',
          colorPuntaHex: '#E0A800',
          mesesMinimos: 12,
          asistenciasMinimas: 96,
          costoExamenCentavos: 320000,
        );

        expect(
          () => motor.guardarGradoCinta(
            nuevoGrado,
            rolActor: RolUsuario.instructor,
          ),
          throwsStateError,
        );

        motor.guardarGradoCinta(nuevoGrado, rolActor: RolUsuario.dueno);
        expect(motor.grados.length, equals(13));
        expect(
          motor.obtenerSiguienteGrado('grado-1-dan')?.id,
          equals('grado-2-dan'),
        );
      },
    );
  });

  group('M2 · Alumnos, Familias Multi-Hijo, Asistencia y Privacidad LFPDPPP 2025', () {
    test('rechaza alta de menor si declaracionPatriaPotestad o aceptoAvisoIntegral es false', () {
      final motor = MotorDoyang.demo();

      final tutorSinPatriaPotestad = TutorFamilia(
        id: 'tutor-invalido',
        academiaId: motor.academia.id,
        nombreCompleto: 'Tutor Sin Firma',
        telefonoWhatsapp: '5511223344',
        correo: 'sinfirma@test.mx',
        parentesco: 'Tío',
        consentimiento: const ConsentimientoTutor(
          tutorId: 'tutor-invalido',
          declaracionPatriaPotestad: false,
          aceptoAvisoIntegral: true,
          versionAviso: 'v2026.1',
          registradoEnIso: '2026-11-23T10:00:00Z',
        ),
      );
      motor.registrarTutor(tutorSinPatriaPotestad);

      final menor = Alumno(
        id: 'alumno-menor-1',
        academiaId: motor.academia.id,
        tutorId: tutorSinPatriaPotestad.id,
        nombre: 'Luis',
        apellidos: 'Pérez',
        fechaNacimientoIso: '2016-05-10',
        sexoRama: SexoRama.varonil,
        gradoActualId: 'grado-10-geup',
        fechaUltimoGradoIso: '2026-11-01',
        asistenciasEnGradoActual: 0,
        horarioGrupo: 'Infantil 17:00',
        codigoQr: 'QR-LUIS-1',
      );

      expect(
        () => motor.registrarAlumno(
          menor,
          fechaReferencia: DateTime.utc(2026, 11, 23),
        ),
        throwsA(isA<ViolacionPrivacidadException>()),
      );
    });

    test(
      'rechaza datos médicos sensibles si consentimientoSaludExpreso es false y los purga al revocar',
      () {
        final motor = MotorDoyang.demo();

        final tutorSinSalud = TutorFamilia(
          id: 'tutor-sin-salud',
          academiaId: motor.academia.id,
          nombreCompleto: 'Elena Gómez',
          telefonoWhatsapp: '5599887766',
          correo: 'elena@test.mx',
          parentesco: 'Madre',
          consentimiento: const ConsentimientoTutor(
            tutorId: 'tutor-sin-salud',
            declaracionPatriaPotestad: true,
            aceptoAvisoIntegral: true,
            consentimientoSaludExpreso: false,
            versionAviso: 'v2026.1',
            registradoEnIso: '2026-11-23T10:00:00Z',
          ),
        );
        motor.registrarTutor(tutorSinSalud);

        final alumnoConAlergia = Alumno(
          id: 'alumno-alergia',
          academiaId: motor.academia.id,
          tutorId: tutorSinSalud.id,
          nombre: 'Valeria',
          apellidos: 'Gómez',
          fechaNacimientoIso: '2015-03-15',
          sexoRama: SexoRama.femenil,
          gradoActualId: 'grado-10-geup',
          fechaUltimoGradoIso: '2026-11-01',
          asistenciasEnGradoActual: 0,
          horarioGrupo: 'Infantil 17:00',
          tipoSangreOpcional: 'O-',
          alergiasCuidadosOpcional: 'Asma leve',
          codigoQr: 'QR-VALERIA',
        );

        // Debe rechazar porque consentimientoSaludExpreso == false
        expect(
          () => motor.registrarAlumno(alumnoConAlergia),
          throwsA(isA<ViolacionPrivacidadException>()),
        );

        // También la función auxiliar limpia los campos si no hay consentimiento
        final limpio = limpiarDatosSaludSinConsentimiento(
          alumno: alumnoConAlergia,
          consentimiento: tutorSinSalud.consentimiento,
        );
        expect(limpio.tipoSangreOpcional, isNull);
        expect(limpio.alergiasCuidadosOpcional, isNull);
        expect(motor.registrarAlumno(limpio).id, equals('alumno-alergia'));

        // Si un tutor que sí tenía consentimiento (tutor-carlos) lo revoca, se purgan los datos médicos de su hijo Diego
        expect(
          motor.obtenerAlumnoPorId('alumno-diego').alergiasCuidadosOpcional,
          isNotNull,
        );
        motor.revocarConsentimientoSaludTutor('tutor-carlos');
        final diegoDespues = motor.obtenerAlumnoPorId('alumno-diego');
        expect(diegoDespues.tipoSangreOpcional, isNull);
        expect(diegoDespues.alergiasCuidadosOpcional, isNull);
      },
    );

    test('registra asistencia diaria e impide duplicar el mismo fechaDiaIso', () {
      final motor = MotorDoyang.demo();
      final antes = motor.obtenerAlumnoPorId('alumno-sofia').asistenciasEnGradoActual;

      final asistencia = motor.registrarAsistencia(
        alumnoId: 'alumno-sofia',
        fechaDiaIso: '2026-11-23',
        metodo: MetodoAsistencia.qr,
      );
      expect(asistencia.fechaDiaIso, equals('2026-11-23'));
      expect(
        motor.obtenerAlumnoPorId('alumno-sofia').asistenciasEnGradoActual,
        equals(antes + 1),
      );

      // Segundo intento el mismo día debe fallar
      expect(
        () => motor.registrarAsistencia(
          alumnoId: 'alumno-sofia',
          fechaDiaIso: '2026-11-23',
          metodo: MetodoAsistencia.manual,
        ),
        throwsStateError,
      );
    });
  });

  group('M3 · Caja Offline-First, Descuento de Hermanos, Mora y Tickets Térmicos', () {
    test(
      'calcula mensualidades familiares con descuento escalonado (1.º, 2.º y 3.er hermano) y aplica mora',
      () {
        final motor = MotorDoyang.demo();

        // Agregamos un 3.er hermano a la familia Hernández (tutor-laura)
        final tercerHermano = Alumno(
          id: 'alumno-leo',
          academiaId: motor.academia.id,
          tutorId: 'tutor-laura',
          nombre: 'Leonardo',
          apellidos: 'Hernández López',
          fechaNacimientoIso: '2020-01-20',
          sexoRama: SexoRama.varonil,
          gradoActualId: 'grado-10-geup',
          fechaUltimoGradoIso: '2026-10-01',
          asistenciasEnGradoActual: 8,
          horarioGrupo: 'Pre-TKD 16:00',
          codigoQr: 'DOYANG-QR-LEO-004',
        );
        motor.registrarAlumno(tercerHermano);

        final cargosDic = motor.generarMensualidadesFamilia(
          tutorId: 'tutor-laura',
          periodo: '2026-12',
          fechaVencimientoIso: '2026-12-05',
        );

        expect(cargosDic.length, equals(3));
        // 1.º hermano: $800.00 MXN (0% desc)
        expect(cargosDic[0].subtotalCentavos, equals(80000));
        expect(cargosDic[0].descuentoCentavos, equals(0));
        expect(cargosDic[0].totalCentavos, equals(80000));

        // 2.º hermano: $800.00 - 10% ($80.00) = $720.00 MXN
        expect(cargosDic[1].subtotalCentavos, equals(80000));
        expect(cargosDic[1].descuentoCentavos, equals(8000));
        expect(cargosDic[1].totalCentavos, equals(72000));

        // 3.er hermano: $800.00 - 20% ($160.00) = $640.00 MXN
        expect(cargosDic[2].subtotalCentavos, equals(80000));
        expect(cargosDic[2].descuentoCentavos, equals(16000));
        expect(cargosDic[2].totalCentavos, equals(64000));

        // Aplicamos recargos de mora después del día límite (2026-12-06)
        final recargados = motor.aplicarRecargosMora(
          fechaCorteIso: '2026-12-06',
        );
        expect(recargados, greaterThanOrEqualTo(3));

        final cargoLeoConMora =
            motor.cargos.firstWhere((c) => c.id == cargosDic[2].id);
        expect(cargoLeoConMora.recargoCentavos, equals(8000));
        expect(cargoLeoConMora.totalCentavos, equals(72000));
        expect(cargoLeoConMora.saldoCentavos, equals(72000));
      },
    );

    test('permite abonos parciales, liquidación total y renderiza ticket térmico 58mm y 80mm', () {
      final motor = MotorDoyang.demo();
      // cargo-mens-sofia-2026-11 tiene saldo de 72000 ($720.00 MXN)
      final ticketAbono = motor.registrarCobro(
        tutorId: 'tutor-laura',
        abonosPorCargoId: <String, int>{'cargo-mens-sofia-2026-11': 30000},
        metodoPago: MetodoPago.transferencia,
        referenciaPagoOpcional: 'SPEI-998877',
      );

      expect(ticketAbono.folio, equals('CAJA1-2026-00002'));
      expect(ticketAbono.totalPagadoCentavos, equals(30000));
      expect(
        ticketAbono.lineas.single.saldoRestanteCargoCentavos,
        equals(42000),
      );

      final cargoSofia = motor.cargos
          .firstWhere((c) => c.id == 'cargo-mens-sofia-2026-11');
      expect(cargoSofia.estado, equals(EstadoCargo.abonadoParcial));
      expect(cargoSofia.pagadoCentavos, equals(30000));
      expect(cargoSofia.saldoCentavos, equals(42000));

      // Renderizado térmico 58 mm (32 columnas) y 80 mm (48 columnas)
      final termico58 = ticketAbono.renderizarTicketTermico(
        anchoColumnas: 32,
        nombreAcademia: motor.academia.nombre,
        telefonoAcademia: motor.academia.telefono,
      );
      for (final linea in termico58.split('\n')) {
        expect(
          linea.length,
          lessThanOrEqualTo(32),
          reason: 'Línea excede 32 columnas en 58mm: "$linea"',
        );
      }
      expect(termico58, contains('DOYANG LEONES TKD'));
      expect(termico58, contains('CAJA1-2026-00002'));
      expect(termico58, contains('(IMPORTES EN MXN)'));
      expect(termico58, contains(r'$300.00 MXN'));
      expect(termico58, contains(r'$420.00 MXN'));
      expect(termico58, contains('[PAGADO]'));

      final termico80 = ticketAbono.renderizarTicketTermico(
        anchoColumnas: 48,
        nombreAcademia: motor.academia.nombre,
      );
      for (final linea in termico80.split('\n')) {
        expect(
          linea.length,
          lessThanOrEqualTo(48),
          reason: 'Línea excede 48 columnas en 80mm: "$linea"',
        );
      }
      expect(termico80, contains('TOTAL PAGADO'));

      // Generador binario ESC/POS (58 mm y 80 mm) con comando QR nativo y corte
      final bytes80 = generarBytesEscPosTicket(
        ticket: ticketAbono,
        academia: motor.academia,
        anchoColumnas: 48,
      );
      expect(bytes80.length, greaterThan(100));
      expect(bytes80.take(2).toList(), equals(<int>[0x1B, 0x40])); // ESC @
      expect(
        bytes80.sublist(bytes80.length - 4),
        equals(<int>[0x1D, 0x56, 0x42, 0x00]), // GS V 66 0 (corte papel)
      );

      // Comprobante digital HTML imprimible a PDF / WhatsApp
      final html = generarComprobanteHtmlImprimible(
        ticket: ticketAbono,
        academia: motor.academia,
      );
      expect(html, contains('<!DOCTYPE html>'));
      expect(html, contains(ticketAbono.folio));
      expect(html, contains('PAGADO'));
      expect(html, contains(ticketAbono.codigoVerificacionQr));
    });

    test('rechaza números de tarjeta PAN (13 a 19 dígitos) o CVV en referenciaPagoOpcional', () {
      final motor = MotorDoyang.demo();

      expect(
        () => motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: <String, int>{'cargo-mens-sofia-2026-11': 10000},
          metodoPago: MetodoPago.terminal,
          referenciaPagoOpcional: '4152313344445555',
        ),
        throwsA(isA<ViolacionPrivacidadException>()),
      );

      expect(
        () => motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: <String, int>{'cargo-mens-sofia-2026-11': 10000},
          metodoPago: MetodoPago.terminal,
          referenciaPagoOpcional: 'Tarjeta 4152 3133 4444 5555 aut 12',
        ),
        throwsA(isA<ViolacionPrivacidadException>()),
      );

      expect(
        () => motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: <String, int>{'cargo-mens-sofia-2026-11': 10000},
          metodoPago: MetodoPago.terminal,
          referenciaPagoOpcional: 'AUT 9812 CVV 412',
        ),
        throwsA(isA<ViolacionPrivacidadException>()),
      );

      // Referencia segura (últimos 4 dígitos + autorización) sí se acepta
      final ticketSeguro = motor.registrarCobro(
        tutorId: 'tutor-laura',
        abonosPorCargoId: <String, int>{'cargo-mens-sofia-2026-11': 72000},
        metodoPago: MetodoPago.terminal,
        referenciaPagoOpcional: 'TERM-AUT-8841 (Term. 5555)',
      );
      expect(ticketSeguro.totalPagadoCentavos, equals(72000));
    });

    test('inmutabilidad y cancelación con reverso de ticket solo por rol Dueño', () {
      final motor = MotorDoyang.demo();
      final ticket = motor.registrarCobro(
        tutorId: 'tutor-laura',
        abonosPorCargoId: <String, int>{'cargo-mens-sofia-2026-11': 72000},
        metodoPago: MetodoPago.efectivo,
      );

      // Recepción o instructor no pueden cancelar sin autorización de dueño
      expect(
        () => motor.cancelarTicket(
          ticketId: ticket.id,
          motivo: 'Error de captura',
          actorUsuarioId: 'inst-1',
          rolActor: RolUsuario.instructor,
        ),
        throwsStateError,
      );

      final cancelado = motor.cancelarTicket(
        ticketId: ticket.id,
        motivo: 'Capturado en efectivo en vez de transferencia SPEI',
        actorUsuarioId: 'dueno-1',
        rolActor: RolUsuario.dueno,
      );

      expect(cancelado.cancelado, isTrue);
      expect(cancelado.folioReversoOpcional, equals('REV-${ticket.folio}'));
      expect(
        cancelado.renderizarTicketTermico(anchoColumnas: 32),
        contains('[CANCELADO]'),
      );

      // El saldo del cargo vuelve a estar pendiente
      final cargoSofia = motor.cargos
          .firstWhere((c) => c.id == 'cargo-mens-sofia-2026-11');
      expect(cargoSofia.estado, equals(EstadoCargo.pendiente));
      expect(cargoSofia.saldoCentavos, equals(72000));
    });
  });

  group('M4 · Grados, Elegibilidad y Ascenso Automático en Examen', () {
    test('evalúa elegibilidad cruzando asistencias, meses y pagos al corriente', () {
      final motor = MotorDoyang.demo();

      // Mateo (6.º Geup -> 5.º Geup) cumple asistencias (25 >= 24), meses (>= 3) y pagos al corriente
      final dictamenMateo = motor.evaluarElegibilidadExamen(
        'alumno-mateo',
        fechaReferencia: DateTime.utc(2026, 11, 23),
      );
      expect(dictamenMateo.elegible, isTrue);
      expect(dictamenMateo.cumpleAsistencias, isTrue);
      expect(dictamenMateo.cumpleTiempoMeses, isTrue);
      expect(dictamenMateo.cumplePagosAlCorriente, isTrue);
      expect(dictamenMateo.siguienteGrado?.id, equals('grado-5-geup'));
      expect(dictamenMateo.motivos, isEmpty);

      // Sofía (8.º Geup -> 7.º Geup) tiene 18/22 asistencias, 2/3 meses y mensualidad pendiente
      final dictamenSofia = motor.evaluarElegibilidadExamen(
        'alumno-sofia',
        fechaReferencia: DateTime.utc(2026, 11, 23),
      );
      expect(dictamenSofia.elegible, isFalse);
      expect(dictamenSofia.cumpleAsistencias, isFalse);
      expect(dictamenSofia.cumpleTiempoMeses, isFalse);
      expect(dictamenSofia.cumplePagosAlCorriente, isFalse);
      expect(dictamenSofia.motivos.length, equals(3));
    });

    test(
      'inscribe a examen, cobra derecho a examen y al aprobar asciende automáticamente de cinta y reinicia asistencias',
      () {
        final motor = MotorDoyang.demo();

        final inscripcion = motor.inscribirAlumnoExamen(
          convocatoriaId: 'conv-invierno-2026',
          alumnoId: 'alumno-mateo',
          consentimientoTutorAceptado: true,
        );
        expect(inscripcion.gradoActualId, equals('grado-6-geup'));
        expect(inscripcion.gradoAspiradoId, equals('grado-5-geup'));

        // Si intenta evaluar antes de pagar el derecho a examen, lo bloquea
        final evaluacionAprobatoria = EvaluacionExamen(
          poomsae: 92,
          kyorugi: 88,
          rompimiento: 95,
          teoria: 90,
          aprobado: true,
          observaciones: 'Excelente ejecución de Taegeuk Oh Jang.',
          evaluadoEnIso: '2026-12-12T11:30:00Z',
        );
        expect(
          () => motor.registrarEvaluacionExamen(
            inscripcionExamenId: inscripcion.id,
            evaluacion: evaluacionAprobatoria,
          ),
          throwsStateError,
        );

        // Liquidamos el cargo del examen en caja
        final cargoExamen =
            motor.cargos.firstWhere((c) => c.id == inscripcion.cargoId);
        motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: <String, int>{
            cargoExamen.id: cargoExamen.saldoCentavos,
          },
          metodoPago: MetodoPago.efectivo,
        );

        // Ahora evaluamos y promovemos
        motor.registrarEvaluacionExamen(
          inscripcionExamenId: inscripcion.id,
          evaluacion: evaluacionAprobatoria,
        );

        final mateoPromovido = motor.obtenerAlumnoPorId('alumno-mateo');
        expect(mateoPromovido.gradoActualId, equals('grado-5-geup'));
        expect(mateoPromovido.asistenciasEnGradoActual, equals(0));
        expect(mateoPromovido.fechaUltimoGradoIso, equals('2026-12-12'));
        expect(
          motor.historialGrados.any(
            (h) =>
                h.alumnoId == 'alumno-mateo' && h.gradoId == 'grado-5-geup',
          ),
          isTrue,
        );
      },
    );
  });

  group('M5 · Equipo e Inventario del Dojang', () {
    test(
      'descuenta stock al pedir equipo, pasa a pagadoPendienteEntrega al liquidar y bloquea entrega si hay adeudo',
      () {
        final motor = MotorDoyang.demo();
        final stockInicial = motor.productosEquipo
            .firstWhere((p) => p.id == 'prod-peto-ch')
            .existencias;

        final pedido = motor.crearPedidoEquipo(
          alumnoId: 'alumno-mateo',
          productoId: 'prod-peto-ch',
          cantidad: 1,
        );

        expect(pedido.estadoEntrega, equals(EstadoEntregaEquipo.pendientePago));
        expect(
          motor.productosEquipo
              .firstWhere((p) => p.id == 'prod-peto-ch')
              .existencias,
          equals(stockInicial - 1),
        );

        // No se puede entregar sin pagar
        expect(
          () => motor.entregarPedidoEquipo(pedidoId: pedido.id),
          throwsStateError,
        );

        // Con un abono parcial de $400.00 MXN (de $850.00 MXN) sigue bloqueada la entrega
        motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: <String, int>{pedido.cargoId: 40000},
          metodoPago: MetodoPago.efectivo,
        );
        expect(
          motor.pedidosEquipo
              .firstWhere((p) => p.id == pedido.id)
              .estadoEntrega,
          equals(EstadoEntregaEquipo.pendientePago),
        );
        expect(
          () => motor.entregarPedidoEquipo(pedidoId: pedido.id),
          throwsStateError,
        );

        // Al liquidar los $450.00 MXN restantes, pasa automáticamente a pagadoPendienteEntrega
        motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: <String, int>{pedido.cargoId: 45000},
          metodoPago: MetodoPago.efectivo,
        );
        final pedidoPagado =
            motor.pedidosEquipo.firstWhere((p) => p.id == pedido.id);
        expect(
          pedidoPagado.estadoEntrega,
          equals(EstadoEntregaEquipo.pagadoPendienteEntrega),
        );

        // Ahora sí permite marcarlo como entregado
        final pedidoEntregado = motor.entregarPedidoEquipo(
          pedidoId: pedido.id,
          entregadoEnIso: '2026-11-23T19:00:00Z',
        );
        expect(
          pedidoEntregado.estadoEntrega,
          equals(EstadoEntregaEquipo.entregado),
        );
        expect(
          pedidoEntregado.entregadoEnIsoOpcional,
          equals('2026-11-23T19:00:00Z'),
        );
      },
    );
  });

  group('M6 · Torneos, Responsiva Digital e Interoperabilidad CUPA (D-12)', () {
    test(
      'exige responsiva del tutor y exporta en JSON/CSV CUPA únicamente a los inscritos con cuota pagada',
      () {
        final motor = MotorDoyang.demo();

        // Rechaza inscripción sin responsiva del tutor
        expect(
          () => motor.inscribirAlumnoTorneo(
            torneoId: 'torneo-copa-primavera',
            alumnoId: 'alumno-mateo',
            modalidad: ModalidadTorneo.kyorugi,
            pesoKgRegistrado: 37.2,
            categoriaDivision: 'Infantil Varonil -39 kg',
            responsivaTutorAceptada: false,
          ),
          throwsA(isA<ViolacionPrivacidadException>()),
        );

        // Inscribimos a Mateo y a Sofía con responsiva aceptada
        final inscMateo = motor.inscribirAlumnoTorneo(
          torneoId: 'torneo-copa-primavera',
          alumnoId: 'alumno-mateo',
          modalidad: ModalidadTorneo.ambas,
          pesoKgRegistrado: 37.2,
          categoriaDivision: 'Infantil Varonil -39 kg',
          responsivaTutorAceptada: true,
        );
        final inscSofia = motor.inscribirAlumnoTorneo(
          torneoId: 'torneo-copa-primavera',
          alumnoId: 'alumno-sofia',
          modalidad: ModalidadTorneo.poomsae,
          pesoKgRegistrado: 26.4,
          categoriaDivision: 'Infantil Femenil Formas',
          responsivaTutorAceptada: true,
        );
        expect(inscSofia.responsivaTutorAceptada, isTrue);

        // Solo pagamos la cuota del torneo de Mateo; Sofía queda pendiente de pago
        motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: <String, int>{inscMateo.cargoId: 75000},
          metodoPago: MetodoPago.transferencia,
          referenciaPagoOpcional: 'SPEI-TORNEO-1',
        );

        final jsonExport = motor.exportarInscritosTorneoCupaJson(
          'torneo-copa-primavera',
        );
        final mapaExport = jsonDecode(jsonExport) as Map<String, dynamic>;
        expect(mapaExport['formato'], equals('cupa-torneo-roster-v1'));
        expect(mapaExport['total_competidores'], equals(1));
        final competidores = mapaExport['competidores'] as List<dynamic>;
        expect(
          (competidores.single as Map<String, dynamic>)['nombre_display'],
          equals('Mateo Hernández López'),
        );

        final csvExport = motor.exportarInscritosTorneoCupaCsv(
          'torneo-copa-primavera',
        );
        final lineasCsv = csvExport.split('\n');
        expect(lineasCsv.length, equals(2)); // encabezado + Mateo
        expect(lineasCsv[1], contains('Mateo Hernández López'));
        expect(lineasCsv[1], isNot(contains('Sofía')));

        // Registro de medalla de Oro
        final conMedalla = motor.registrarMedallaTorneo(
          inscripcionTorneoId: inscMateo.id,
          medalla: MedallaTorneo.oro,
          notasResultado: '1.er lugar combate final 2-0',
        );
        expect(conMedalla.medalla, equals(MedallaTorneo.oro));
      },
    );
  });

  group('Derechos ARCO, Bitácora, Outbox y Serialización JSON', () {
    test(
      'exporta expediente ARCO y ejecuta baja ARCO purgando salud y disociando folios sin alterar el corte de caja',
      () {
        final motor = MotorDoyang.demo();
        final corteAntes = motor.calcularCorteCaja();
        expect(corteAntes.totalCobradoCentavos, equals(80000));

        // 1. Derecho de Acceso y Portabilidad ARCO
        final jsonArco = motor.exportarExpedienteArcoJson('tutor-laura');
        final mapaArco = jsonDecode(jsonArco) as Map<String, dynamic>;
        expect(
          mapaArco['marco_legal'],
          contains('LFPDPPP 2025'),
        );
        expect((mapaArco['alumnos'] as List<dynamic>).length, equals(2));
        expect(
          motor.bitacoraAuditoria.any(
            (b) => b.accion == 'EXPORTACION_EXPEDIENTE_ARCO',
          ),
          isTrue,
        );

        // 2. Derecho de Cancelación ARCO sobre la familia tutor-laura
        motor.ejecutarBajaArcoTutorOAlumno(
          tutorId: 'tutor-laura',
          ejecutadoPorId: 'dueno-1',
        );

        final mateoCancelado = motor.obtenerAlumnoPorId('alumno-mateo');
        expect(mateoCancelado.bloqueadoArco, isTrue);
        expect(mateoCancelado.activo, isFalse);
        expect(mateoCancelado.tipoSangreOpcional, isNull);
        expect(mateoCancelado.alergiasCuidadosOpcional, isNull);
        expect(mateoCancelado.telefonoEmergenciaOpcional, isNull);
        expect(mateoCancelado.nombreCompleto, equals('REGISTRO CANCELADO ARCO'));

        // El ticket histórico fue disociado de datos personales pero conserva intacto el monto del corte de caja
        final ticketDisociado = motor.tickets.first;
        expect(ticketDisociado.tutorId, equals('ANONIMIZADO-ARCO'));
        expect(
          ticketDisociado.lineas.first.alumnoNombre,
          contains('REGISTRO CANCELADO ARCO'),
        );

        final corteDespues = motor.calcularCorteCaja();
        expect(
          corteDespues.totalCobradoCentavos,
          equals(corteAntes.totalCobradoCentavos),
        );
      },
    );

    test('serializa y deserializa MotorDoyang completo con toJson / fromJson', () {
      final original = MotorDoyang.demo();
      original.crearPedidoEquipo(
        alumnoId: 'alumno-mateo',
        productoId: 'prod-bucal-jr',
      );
      original.inscribirAlumnoTorneo(
        torneoId: 'torneo-copa-primavera',
        alumnoId: 'alumno-diego',
        modalidad: ModalidadTorneo.kyorugi,
        pesoKgRegistrado: 44.5,
        categoriaDivision: 'Cadetes -45 kg',
        responsivaTutorAceptada: true,
      );
      original.marcarOutboxSincronizado();

      final mapa = original.toJson();
      final restaurado = MotorDoyang.fromJson(
        jsonDecode(jsonEncode(mapa)) as Map<String, dynamic>,
      );

      expect(restaurado.academia.nombre, equals(original.academia.nombre));
      expect(restaurado.grados.length, equals(original.grados.length));
      expect(restaurado.tutores.length, equals(original.tutores.length));
      expect(restaurado.alumnos.length, equals(original.alumnos.length));
      expect(restaurado.cargos.length, equals(original.cargos.length));
      expect(restaurado.tickets.length, equals(original.tickets.length));
      expect(
        restaurado.pedidosEquipo.length,
        equals(original.pedidosEquipo.length),
      );
      expect(
        restaurado.inscripcionesTorneo.length,
        equals(original.inscripcionesTorneo.length),
      );
      expect(
        restaurado.colaOutbox.every((e) => e.sincronizado),
        isTrue,
      );
    });
  });
}

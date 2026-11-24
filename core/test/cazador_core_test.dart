import 'dart:convert';

import 'package:mi_doyang_core/mi_doyang_core.dart';
import 'package:test/test.dart';

void main() {
  group('1 · Entradas extremas y monetarias', () {
    test(
      'rechaza montos negativos o cero en cargos, cobros, tickets, equipo, grados y torneos',
      () {
        final motor = MotorDoyang.demo();

        // AcademiaConfig: montos negativos
        expect(
          () => motor.academia.copyWith(mensualidadBaseCentavos: -1),
          throwsArgumentError,
        );
        expect(
          () => motor.academia.copyWith(inscripcionCentavos: -100),
          throwsArgumentError,
        );
        expect(
          () => motor.academia.copyWith(recargoMoraCentavos: -50),
          throwsArgumentError,
        );

        // GradoCinta: orden <= 0 o costos/requisitos negativos
        expect(
          () => GradoCinta(
            id: 'grado-invalido',
            orden: 0,
            codigo: 'X',
            nombre: 'Invalido',
            colorBaseHex: '#FFFFFF',
            mesesMinimos: 1,
            asistenciasMinimas: 1,
            costoExamenCentavos: 100,
          ),
          throwsArgumentError,
        );
        expect(
          () => GradoCinta(
            id: 'grado-negativo',
            orden: 1,
            codigo: 'X',
            nombre: 'Negativo',
            colorBaseHex: '#FFFFFF',
            mesesMinimos: -1,
            asistenciasMinimas: 10,
            costoExamenCentavos: 100,
          ),
          throwsArgumentError,
        );
        expect(
          () => GradoCinta(
            id: 'grado-costo-neg',
            orden: 1,
            codigo: 'X',
            nombre: 'Costo Negativo',
            colorBaseHex: '#FFFFFF',
            mesesMinimos: 1,
            asistenciasMinimas: 10,
            costoExamenCentavos: -500,
          ),
          throwsArgumentError,
        );

        // CargoCuenta: cualquier campo monetario negativo
        expect(
          () => CargoCuenta(
            id: 'cargo-neg',
            academiaId: motor.academia.id,
            tutorId: 'tutor-laura',
            tipo: TipoCargo.mensualidad,
            concepto: 'Cargo negativo',
            subtotalCentavos: -100,
            totalCentavos: 100,
            saldoCentavos: 100,
            fechaVencimientoIso: '2026-12-05',
            estado: EstadoCargo.pendiente,
          ),
          throwsArgumentError,
        );
        expect(
          () => CargoCuenta(
            id: 'cargo-saldo-neg',
            academiaId: motor.academia.id,
            tutorId: 'tutor-laura',
            tipo: TipoCargo.mensualidad,
            concepto: 'Saldo negativo',
            subtotalCentavos: 100,
            totalCentavos: 100,
            saldoCentavos: -1,
            fechaVencimientoIso: '2026-12-05',
            estado: EstadoCargo.pendiente,
          ),
          throwsArgumentError,
        );

        // TicketPago: totalPagadoCentavos <= 0
        expect(
          () => TicketPago(
            id: 'tkt-cero',
            folio: 'CAJA1-2026-99999',
            academiaId: motor.academia.id,
            tutorId: 'tutor-laura',
            emitidoEnIso: '2026-11-23T18:00:00Z',
            metodoPago: MetodoPago.efectivo,
            lineas: const <LineaTicket>[],
            totalPagadoCentavos: 0,
            cajeroUsuarioId: 'recepcion-1',
            codigoVerificacionQr: 'qr',
          ),
          throwsArgumentError,
        );
        expect(
          () => TicketPago(
            id: 'tkt-neg',
            folio: 'CAJA1-2026-99998',
            academiaId: motor.academia.id,
            tutorId: 'tutor-laura',
            emitidoEnIso: '2026-11-23T18:00:00Z',
            metodoPago: MetodoPago.efectivo,
            lineas: const <LineaTicket>[],
            totalPagadoCentavos: -500,
            cajeroUsuarioId: 'recepcion-1',
            codigoVerificacionQr: 'qr',
          ),
          throwsArgumentError,
        );

        // registrarCobro: mapa vacío, monto 0 o monto negativo
        expect(
          () => motor.registrarCobro(
            tutorId: 'tutor-laura',
            abonosPorCargoId: const <String, int>{},
            metodoPago: MetodoPago.efectivo,
          ),
          throwsArgumentError,
        );
        expect(
          () => motor.registrarCobro(
            tutorId: 'tutor-laura',
            abonosPorCargoId: const <String, int>{
              'cargo-mens-sofia-2026-11': 0,
            },
            metodoPago: MetodoPago.efectivo,
          ),
          throwsArgumentError,
        );
        expect(
          () => motor.registrarCobro(
            tutorId: 'tutor-laura',
            abonosPorCargoId: const <String, int>{
              'cargo-mens-sofia-2026-11': -100,
            },
            metodoPago: MetodoPago.efectivo,
          ),
          throwsArgumentError,
        );

        // ProductoEquipo y PedidoEquipo: precios, existencias o cantidades <= 0
        expect(
          () => ProductoEquipo(
            id: 'prod-neg',
            academiaId: motor.academia.id,
            nombre: 'Dobok Negativo',
            categoria: CategoriaEquipo.dobok,
            talla: 'M',
            precioCentavos: -1,
            existencias: 5,
          ),
          throwsArgumentError,
        );
        expect(
          () => ProductoEquipo(
            id: 'prod-stock-neg',
            academiaId: motor.academia.id,
            nombre: 'Dobok Sin Stock',
            categoria: CategoriaEquipo.dobok,
            talla: 'M',
            precioCentavos: 50000,
            existencias: -1,
          ),
          throwsArgumentError,
        );
        expect(
          () => motor.crearPedidoEquipo(
            alumnoId: 'alumno-mateo',
            productoId: 'prod-peto-ch',
            cantidad: 0,
          ),
          throwsArgumentError,
        );
        expect(
          () => motor.crearPedidoEquipo(
            alumnoId: 'alumno-mateo',
            productoId: 'prod-peto-ch',
            cantidad: -2,
          ),
          throwsArgumentError,
        );

        // Torneo e InscripcionTorneo: cuota negativa o peso <= 0
        expect(
          () => Torneo(
            id: 'tor-neg',
            academiaId: motor.academia.id,
            nombre: 'Torneo Negativo',
            sede: 'CDMX',
            fechaEventoIso: '2027-05-01',
            fechaLimiteInscripcionIso: '2027-04-20',
            cuotaCentavos: -1,
          ),
          throwsArgumentError,
        );
        expect(
          () => InscripcionTorneo(
            id: 'insc-peso-cero',
            torneoId: 'torneo-copa-primavera',
            alumnoId: 'alumno-mateo',
            tutorId: 'tutor-laura',
            modalidad: ModalidadTorneo.kyorugi,
            pesoKgRegistrado: 0,
            gradoIdAlInscribir: 'grado-6-kup',
            categoriaDivision: 'Infantil',
            responsivaTutorAceptada: true,
            responsivaAceptadaEnIso: '2026-11-23T18:00:00Z',
            cargoId: 'cargo-1',
          ),
          throwsArgumentError,
        );
        expect(
          () => InscripcionTorneo(
            id: 'insc-peso-neg',
            torneoId: 'torneo-copa-primavera',
            alumnoId: 'alumno-mateo',
            tutorId: 'tutor-laura',
            modalidad: ModalidadTorneo.kyorugi,
            pesoKgRegistrado: -35.0,
            gradoIdAlInscribir: 'grado-6-kup',
            categoriaDivision: 'Infantil',
            responsivaTutorAceptada: true,
            responsivaAceptadaEnIso: '2026-11-23T18:00:00Z',
            cargoId: 'cargo-1',
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'BUG-004 · inscribirAlumnoTorneo con pesoKgRegistrado <= 0 no debe corromper el peso del alumno ni dejar cargos huérfanos',
      () {
        final motor = MotorDoyang.demo();
        final pesoOriginal =
            motor.obtenerAlumnoPorId('alumno-mateo').pesoKgOpcional;
        final totalCargosAntes = motor.cargos.length;

        expect(
          () => motor.inscribirAlumnoTorneo(
            torneoId: 'torneo-copa-primavera',
            alumnoId: 'alumno-mateo',
            modalidad: ModalidadTorneo.kyorugi,
            pesoKgRegistrado: -15.0,
            categoriaDivision: 'Infantil -39 kg',
            responsivaTutorAceptada: true,
          ),
          throwsArgumentError,
        );

        // El fallo de validación no debe haber mutado el expediente ni agregado un cargo huérfano
        expect(
          motor.obtenerAlumnoPorId('alumno-mateo').pesoKgOpcional,
          equals(pesoOriginal),
          reason:
              'El peso del alumno fue corrompido con un valor negativo tras fallar inscribirAlumnoTorneo.',
        );
        expect(
          motor.cargos.length,
          equals(totalCargosAntes),
          reason:
              'Se generó un CargoCuenta huérfano en el estado de cuenta a pesar de que la inscripción al torneo falló.',
        );
      },
    );

    test(
      'rechaza descuentos mayores a 100% o negativos, calificaciones fuera de 0..100 y abonos mayores al saldo del cargo',
      () {
        final motor = MotorDoyang.demo();

        expect(
          () => motor.academia.copyWith(descuentoSegundoHermanoPct: 101),
          throwsArgumentError,
        );
        expect(
          () => motor.academia.copyWith(descuentoTercerHermanoPct: 150),
          throwsArgumentError,
        );
        expect(
          () => motor.academia.copyWith(descuentoSegundoHermanoPct: -1),
          throwsArgumentError,
        );
        expect(
          () => motor.academia.copyWith(descuentoTercerHermanoPct: -10),
          throwsArgumentError,
        );

        // Calificaciones fuera de 0..100
        expect(
          () => EvaluacionExamen(
            poomsae: 101,
            kyorugi: 90,
            rompimiento: 90,
            teoria: 90,
            aprobado: true,
            evaluadoEnIso: '2026-12-12T10:00:00Z',
          ),
          throwsArgumentError,
        );
        expect(
          () => EvaluacionExamen(
            poomsae: 90,
            kyorugi: -1,
            rompimiento: 90,
            teoria: 90,
            aprobado: true,
            evaluadoEnIso: '2026-12-12T10:00:00Z',
          ),
          throwsArgumentError,
        );

        // Abono por 1 centavo más que el saldo del cargo ($720.00 MXN = 72000 centavos)
        expect(
          () => motor.registrarCobro(
            tutorId: 'tutor-laura',
            abonosPorCargoId: const <String, int>{
              'cargo-mens-sofia-2026-11': 72001,
            },
            metodoPago: MetodoPago.efectivo,
          ),
          throwsArgumentError,
        );
        // Verifica que el saldo quedó intacto tras el intento fallido
        final cargoSofia = motor.cargos
            .firstWhere((c) => c.id == 'cargo-mens-sofia-2026-11');
        expect(cargoSofia.saldoCentavos, equals(72000));
        expect(cargoSofia.pagadoCentavos, equals(0));
      },
    );

    test(
      'soporta nombres con emojis, apóstrofos, acentos/ñ y 10,000 caracteres en tickets térmicos y exportación CSV/JSON',
      () {
        final motor = MotorDoyang.demo();
        final nombreGigante =
            "Sean O'Neil Ñáñez 🥋🔥 ${'K' * 10000}";
        final alumnoExtremo = Alumno(
          id: 'alumno-extremo',
          academiaId: motor.academia.id,
          tutorId: 'tutor-laura',
          nombre: nombreGigante,
          apellidos: 'D\'Artagnan, "El Rápido"',
          fechaNacimientoIso: '2016-02-29',
          sexoRama: SexoRama.varonil,
          gradoActualId: 'grado-10-kup',
          fechaUltimoGradoIso: '2026-01-15',
          asistenciasEnGradoActual: 30,
          horarioGrupo: 'Especial 18:00',
          codigoQr: 'QR-EXTREMO',
        );
        motor.registrarAlumno(alumnoExtremo);

        final inscTorneo = motor.inscribirAlumnoTorneo(
          torneoId: 'torneo-copa-primavera',
          alumnoId: alumnoExtremo.id,
          modalidad: ModalidadTorneo.kyorugi,
          pesoKgRegistrado: 33.5,
          categoriaDivision: 'Infantil, "A" -35kg',
          responsivaTutorAceptada: true,
        );

        final ticket = motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: <String, int>{inscTorneo.cargoId: 75000},
          metodoPago: MetodoPago.efectivo,
        );

        final termico58 = ticket.renderizarTicketTermico(anchoColumnas: 32);
        for (final linea in termico58.split('\n')) {
          expect(linea.length, lessThanOrEqualTo(32));
        }

        final csv = motor.exportarInscritosTorneoCupaCsv(
          'torneo-copa-primavera',
        );
        expect(csv, contains('""El Rápido""'));

        final jsonExport = jsonDecode(
          motor.exportarInscritosTorneoCupaJson('torneo-copa-primavera'),
        ) as Map<String, dynamic>;
        expect(jsonExport['total_competidores'], equals(1));
      },
    );

    test(
      'maneja correctamente fechas de año bisiesto (29 de febrero) y rechaza fechas mal formadas',
      () {
        final motor = MotorDoyang.demo();

        final alumnoBisiesto = Alumno(
          id: 'alumno-bisiesto',
          academiaId: motor.academia.id,
          tutorId: 'tutor-laura',
          nombre: 'Lucía',
          apellidos: 'Hernández López',
          fechaNacimientoIso: '2016-02-29',
          sexoRama: SexoRama.femenil,
          gradoActualId: 'grado-10-kup',
          fechaUltimoGradoIso: '2024-02-29',
          asistenciasEnGradoActual: 25,
          horarioGrupo: 'Infantil 17:00',
          codigoQr: 'QR-BISIESTO',
        );

        // El 28 de febrero de 2026 aún tiene 9 años; el 1 de marzo de 2026 cumple 10 años
        expect(
          alumnoBisiesto.calcularEdadAnios(
            fechaReferencia: DateTime.utc(2026, 2, 28),
          ),
          equals(9),
        );
        expect(
          alumnoBisiesto.calcularEdadAnios(
            fechaReferencia: DateTime.utc(2026, 3, 1),
          ),
          equals(10),
        );

        motor.registrarAlumno(alumnoBisiesto);
        final dictamen = motor.evaluarElegibilidadExamen(
          alumnoBisiesto.id,
          fechaReferencia: DateTime.utc(2026, 11, 23),
        );
        expect(dictamen.elegible, isTrue);

        // Fecha mal formada debe lanzar FormatException al validar edad en registrarAlumno
        final alumnoFechaMala = alumnoBisiesto.copyWith(
          id: 'alumno-fecha-mala',
          fechaNacimientoIso: '2016/99/99-invalida',
        );
        expect(
          () => motor.registrarAlumno(alumnoFechaMala),
          throwsFormatException,
        );
      },
    );
  });

  group('2 · Privacidad y seguridad (LFPDPPP 2025 y PCI/Tarjetas)', () {
    test(
      'impide colar tipoSangreOpcional o alergiasCuidadosOpcional cuando consentimientoSaludExpreso es false',
      () {
        final motor = MotorDoyang.demo();
        final tutorSinConsentimientoSalud = TutorFamilia(
          id: 'tutor-no-salud',
          academiaId: motor.academia.id,
          nombreCompleto: 'Patricia Morales',
          telefonoWhatsapp: '5512345678',
          correo: 'patricia@familia.mx',
          parentesco: 'Madre',
          consentimiento: const ConsentimientoTutor(
            tutorId: 'tutor-no-salud',
            declaracionPatriaPotestad: true,
            aceptoAvisoIntegral: true,
            consentimientoSaludExpreso: false,
            versionAviso: 'v2026.1',
            registradoEnIso: '2026-11-23T12:00:00Z',
          ),
        );
        motor.registrarTutor(tutorSinConsentimientoSalud);

        final baseMenor = Alumno(
          id: 'menor-salud-1',
          academiaId: motor.academia.id,
          tutorId: tutorSinConsentimientoSalud.id,
          nombre: 'Emiliano',
          apellidos: 'Morales',
          fechaNacimientoIso: '2014-08-20',
          sexoRama: SexoRama.varonil,
          gradoActualId: 'grado-10-kup',
          fechaUltimoGradoIso: '2026-11-01',
          asistenciasEnGradoActual: 0,
          horarioGrupo: 'Infantil 17:00',
          codigoQr: 'QR-EMI',
        );

        // Intento 1: solo tipoSangreOpcional
        expect(
          () => motor.registrarAlumno(
            baseMenor.copyWith(tipoSangreOpcional: 'AB+'),
          ),
          throwsA(isA<ViolacionPrivacidadException>()),
        );

        // Intento 2: solo alergiasCuidadosOpcional
        expect(
          () => motor.registrarAlumno(
            baseMenor.copyWith(
              alergiasCuidadosOpcional: 'Alergia a AINEs y asma',
            ),
          ),
          throwsA(isA<ViolacionPrivacidadException>()),
        );
      },
    );

    test(
      'impide registrar a un menor de 18 años con declaracionPatriaPotestad = false o sin aviso integral',
      () {
        final motor = MotorDoyang.demo();

        // Tutor que no aceptó aviso de privacidad integral
        final tutorSinAviso = TutorFamilia(
          id: 'tutor-sin-aviso',
          academiaId: motor.academia.id,
          nombreCompleto: 'Tutor Sin Aviso',
          telefonoWhatsapp: '5500001111',
          correo: 'sinaviso@familia.mx',
          parentesco: 'Padre',
          consentimiento: const ConsentimientoTutor(
            tutorId: 'tutor-sin-aviso',
            declaracionPatriaPotestad: true,
            aceptoAvisoIntegral: false,
            versionAviso: 'v2026.1',
            registradoEnIso: '2026-11-23T12:00:00Z',
          ),
        );
        expect(
          () => motor.registrarTutor(tutorSinAviso),
          throwsA(isA<ViolacionPrivacidadException>()),
        );

        // Tutor con aviso aceptado pero declaracionPatriaPotestad = false
        final tutorSinPatria = TutorFamilia(
          id: 'tutor-sin-patria',
          academiaId: motor.academia.id,
          nombreCompleto: 'Hermano Mayor',
          telefonoWhatsapp: '5500002222',
          correo: 'hermano@familia.mx',
          parentesco: 'Hermano',
          consentimiento: const ConsentimientoTutor(
            tutorId: 'tutor-sin-patria',
            declaracionPatriaPotestad: false,
            aceptoAvisoIntegral: true,
            versionAviso: 'v2026.1',
            registradoEnIso: '2026-11-23T12:00:00Z',
          ),
        );
        motor.registrarTutor(tutorSinPatria);

        // Menor a 1 día de cumplir 18 años (17 años) debe ser bloqueado
        final menorCasi18 = Alumno(
          id: 'alumno-17-anios',
          academiaId: motor.academia.id,
          tutorId: tutorSinPatria.id,
          nombre: 'Andrés',
          apellidos: 'Soto',
          fechaNacimientoIso: '2008-11-24',
          sexoRama: SexoRama.varonil,
          gradoActualId: 'grado-10-kup',
          fechaUltimoGradoIso: '2026-11-01',
          asistenciasEnGradoActual: 0,
          horarioGrupo: 'Adultos 20:00',
          codigoQr: 'QR-ANDRES-17',
        );

        expect(
          () => motor.registrarAlumno(
            menorCasi18,
            fechaReferencia: DateTime.utc(2026, 11, 23),
          ),
          throwsA(isA<ViolacionPrivacidadException>()),
        );
      },
    );

    test(
      'bloquea números de tarjeta de 16 dígitos (con guiones o espacios) y códigos CVV en referenciaPagoOpcional',
      () {
        final motor = MotorDoyang.demo();

        for (final referenciaProhibida in <String>[
          '4152-3133-4444-5555',
          '4152 3133 4444 5555',
          '4152313344445555',
          'Pago con tarjeta 5204-1699-8877-0011 aut 123',
          'CVV 123',
          'cvv: 987',
          'CVC-456',
          'codigo de seguridad 321',
        ]) {
          expect(
            () => motor.registrarCobro(
              tutorId: 'tutor-laura',
              abonosPorCargoId: const <String, int>{
                'cargo-mens-sofia-2026-11': 10000,
              },
              metodoPago: MetodoPago.terminal,
              referenciaPagoOpcional: referenciaProhibida,
            ),
            throwsA(isA<ViolacionPrivacidadException>()),
            reason:
                'Debió rechazar referenciaPagoOpcional prohibida: "$referenciaProhibida"',
          );
        }
      },
    );
  });

  group('3 · Inmutabilidad y estado del dominio', () {
    test(
      'impide cobrar un cargo ya pagado o cancelado y cancelar dos veces el mismo ticket',
      () {
        final motor = MotorDoyang.demo();

        // 1. Cargo ya pagado en demo (cargo-mens-mateo-2026-11)
        expect(
          () => motor.registrarCobro(
            tutorId: 'tutor-laura',
            abonosPorCargoId: const <String, int>{
              'cargo-mens-mateo-2026-11': 1000,
            },
            metodoPago: MetodoPago.efectivo,
          ),
          throwsStateError,
        );

        // 2. Cargo cancelado
        final cargoCancelado = CargoCuenta(
          id: 'cargo-cancelado-1',
          academiaId: motor.academia.id,
          tutorId: 'tutor-laura',
          alumnoId: 'alumno-sofia',
          tipo: TipoCargo.otro,
          concepto: 'Reposición credencial cancelada',
          subtotalCentavos: 15000,
          totalCentavos: 15000,
          saldoCentavos: 0,
          fechaVencimientoIso: '2026-11-30',
          estado: EstadoCargo.cancelado,
        );
        motor.registrarCargo(cargoCancelado);

        expect(
          () => motor.registrarCobro(
            tutorId: 'tutor-laura',
            abonosPorCargoId: const <String, int>{'cargo-cancelado-1': 5000},
            metodoPago: MetodoPago.efectivo,
          ),
          throwsStateError,
        );

        // 3. Cancelar ticket dos veces
        final ticket = motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: const <String, int>{
            'cargo-mens-sofia-2026-11': 72000,
          },
          metodoPago: MetodoPago.efectivo,
        );

        motor.cancelarTicket(
          ticketId: ticket.id,
          motivo: 'Error en método de pago',
          actorUsuarioId: 'dueno-1',
          rolActor: RolUsuario.dueno,
        );

        expect(
          () => motor.cancelarTicket(
            ticketId: ticket.id,
            motivo: 'Segundo intento de cancelación',
            actorUsuarioId: 'dueno-1',
            rolActor: RolUsuario.dueno,
          ),
          throwsStateError,
        );
      },
    );

    test(
      'BUG-005 · registrarCobro no debe permitir que un tutor cobre cargos pertenecientes a otra familia',
      () {
        final motor = MotorDoyang.demo();

        // cargo-mens-sofia-2026-11 pertenece a 'tutor-laura', NO a 'tutor-carlos'
        expect(
          () => motor.registrarCobro(
            tutorId: 'tutor-carlos',
            abonosPorCargoId: const <String, int>{
              'cargo-mens-sofia-2026-11': 72000,
            },
            metodoPago: MetodoPago.efectivo,
          ),
          throwsA(anyOf(isA<StateError>(), isA<ArgumentError>())),
          reason:
              'registrarCobro permitió emitir un ticket a nombre de tutor-carlos pagando un cargo de tutor-laura.',
        );
      },
    );

    test(
      'impide pedir equipo sin stock, entregar equipo no pagado o cuyo ticket fue cancelado, y duplicar asistencia el mismo día',
      () {
        final motor = MotorDoyang.demo();

        // 1. Pedir más unidades que las existencias disponibles (prod-casco-m tiene 4)
        expect(
          () => motor.crearPedidoEquipo(
            alumnoId: 'alumno-mateo',
            productoId: 'prod-casco-m',
            cantidad: 5,
          ),
          throwsStateError,
        );
        expect(
          motor.productosEquipo
              .firstWhere((p) => p.id == 'prod-casco-m')
              .existencias,
          equals(4),
        );

        // 2. Crear pedido válido, intentar entregar sin pagar
        final pedido = motor.crearPedidoEquipo(
          alumnoId: 'alumno-mateo',
          productoId: 'prod-casco-m',
          cantidad: 1,
        );
        expect(
          () => motor.entregarPedidoEquipo(pedidoId: pedido.id),
          throwsStateError,
        );

        // 3. Pagar pedido, luego cancelar el ticket y verificar que vuelve a bloquear la entrega
        final ticketEquipo = motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: <String, int>{pedido.cargoId: pedido.totalCentavos},
          metodoPago: MetodoPago.efectivo,
        );
        motor.cancelarTicket(
          ticketId: ticketEquipo.id,
          motivo: 'Pago revertido en mostrador',
          actorUsuarioId: 'dueno-1',
          rolActor: RolUsuario.dueno,
        );
        expect(
          () => motor.entregarPedidoEquipo(pedidoId: pedido.id),
          throwsStateError,
        );

        // 4. Duplicar asistencia el mismo día (mateo ya tiene asistencia el 2026-11-20 en demo)
        expect(
          () => motor.registrarAsistencia(
            alumnoId: 'alumno-mateo',
            fechaDiaIso: '2026-11-20',
          ),
          throwsStateError,
        );
      },
    );

    test(
      'BUG-001 · impide inscribir dos veces al mismo alumno en la misma convocatoria de examen o en el mismo torneo',
      () {
        final motor = MotorDoyang.demo();

        // Primera inscripción a examen: válida
        motor.inscribirAlumnoExamen(
          convocatoriaId: 'conv-invierno-2026',
          alumnoId: 'alumno-mateo',
          consentimientoTutorAceptado: true,
        );

        // Segunda inscripción del mismo alumno al mismo examen: debe fallar
        expect(
          () => motor.inscribirAlumnoExamen(
            convocatoriaId: 'conv-invierno-2026',
            alumnoId: 'alumno-mateo',
            consentimientoTutorAceptado: true,
          ),
          throwsStateError,
          reason:
              'Permitió inscribir dos veces a alumno-mateo en conv-invierno-2026 y duplicó el cargo de examen.',
        );

        // Primera inscripción a torneo: válida
        motor.inscribirAlumnoTorneo(
          torneoId: 'torneo-copa-primavera',
          alumnoId: 'alumno-mateo',
          modalidad: ModalidadTorneo.kyorugi,
          pesoKgRegistrado: 36.8,
          categoriaDivision: 'Infantil -39 kg',
          responsivaTutorAceptada: true,
        );

        // Segunda inscripción del mismo alumno al mismo torneo: debe fallar
        expect(
          () => motor.inscribirAlumnoTorneo(
            torneoId: 'torneo-copa-primavera',
            alumnoId: 'alumno-mateo',
            modalidad: ModalidadTorneo.kyorugi,
            pesoKgRegistrado: 36.8,
            categoriaDivision: 'Infantil -39 kg',
            responsivaTutorAceptada: true,
          ),
          throwsStateError,
          reason:
              'Permitió inscribir dos veces a alumno-mateo en torneo-copa-primavera y duplicó el cargo de torneo.',
        );
      },
    );

    test(
      'BUG-003 · impide evaluar examen o inscribir en examen/torneo/equipo a un alumno dado de baja por cancelación ARCO',
      () {
        final motor = MotorDoyang.demo();

        // Mateo se inscribe al examen y liquida el derecho a examen
        final inscripcion = motor.inscribirAlumnoExamen(
          convocatoriaId: 'conv-invierno-2026',
          alumnoId: 'alumno-mateo',
          consentimientoTutorAceptado: true,
        );
        motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: <String, int>{inscripcion.cargoId: 65000},
          metodoPago: MetodoPago.efectivo,
        );

        // Se ejecuta la baja y cancelación ARCO del alumno Mateo
        motor.ejecutarBajaArcoTutorOAlumno(
          alumnoId: 'alumno-mateo',
          ejecutadoPorId: 'dueno-1',
          rolEjecutor: RolUsuario.dueno,
        );
        expect(
          motor.obtenerAlumnoPorId('alumno-mateo').bloqueadoArco,
          isTrue,
        );

        // Evaluar examen de un alumno bloqueado por ARCO debe ser rechazado
        expect(
          () => motor.registrarEvaluacionExamen(
            inscripcionExamenId: inscripcion.id,
            evaluacion: EvaluacionExamen(
              poomsae: 95,
              kyorugi: 90,
              rompimiento: 92,
              teoria: 94,
              aprobado: true,
              evaluadoEnIso: '2026-12-12T12:00:00Z',
            ),
          ),
          throwsStateError,
          reason:
              'Permitió evaluar y promover de cinta a un alumno dado de baja por cancelación ARCO.',
        );
      },
    );

    test(
      'toJson() -> fromJson() preserva el estado exacto sin perder centavos, folios, eventos outbox ni bitácora',
      () {
        final motor = MotorDoyang.demo();

        motor.registrarAsistencia(
          alumnoId: 'alumno-sofia',
          fechaDiaIso: '2026-11-23',
        );
        final ticketAbono = motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: const <String, int>{
            'cargo-mens-sofia-2026-11': 35555,
          },
          metodoPago: MetodoPago.transferencia,
          referenciaPagoOpcional: 'SPEI-35555',
        );
        final pedido = motor.crearPedidoEquipo(
          alumnoId: 'alumno-diego',
          productoId: 'prod-bucal-jr',
          cantidad: 2,
        );
        motor.registrarCobro(
          tutorId: 'tutor-carlos',
          abonosPorCargoId: <String, int>{pedido.cargoId: pedido.totalCentavos},
          metodoPago: MetodoPago.terminal,
          referenciaPagoOpcional: 'AUT-9911',
        );
        motor.entregarPedidoEquipo(pedidoId: pedido.id);

        final jsonStr = jsonEncode(motor.toJson());
        final restaurado = MotorDoyang.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>,
        );

        final corteOriginal = motor.calcularCorteCaja();
        final corteRestaurado = restaurado.calcularCorteCaja();

        expect(
          corteRestaurado.totalCobradoCentavos,
          equals(corteOriginal.totalCobradoCentavos),
        );
        expect(
          corteRestaurado.totalEfectivoCentavos,
          equals(corteOriginal.totalEfectivoCentavos),
        );
        expect(
          corteRestaurado.totalTransferenciaCentavos,
          equals(corteOriginal.totalTransferenciaCentavos),
        );
        expect(
          corteRestaurado.totalTerminalCentavos,
          equals(corteOriginal.totalTerminalCentavos),
        );
        expect(restaurado.colaOutbox.length, equals(motor.colaOutbox.length));
        expect(
          restaurado.bitacoraAuditoria.length,
          equals(motor.bitacoraAuditoria.length),
        );
        expect(
          restaurado.tickets
              .firstWhere((t) => t.id == ticketAbono.id)
              .codigoVerificacionQr,
          equals(ticketAbono.codigoVerificacionQr),
        );
        expect(jsonEncode(restaurado.toJson()), equals(jsonStr));
      },
    );
  });

  group('4 · Control de Acceso Basado en Roles (RBAC · D-10)', () {
    test(
      'impide que tutor, instructor o recepcion modifiquen la configuración de la academia, el escalafón o cancelen tickets',
      () {
        final motor = MotorDoyang.demo();

        for (final rolNoDueno in <RolUsuario>[
          RolUsuario.tutor,
          RolUsuario.instructor,
          RolUsuario.recepcion,
        ]) {
          expect(
            () => motor.actualizarAcademia(
              motor.academia.copyWith(mensualidadBaseCentavos: 10000),
              actorUsuarioId: 'usr-${rolNoDueno.name}',
              rolActor: rolNoDueno,
            ),
            throwsStateError,
          );

          expect(
            () => motor.guardarGradoCinta(
              motor.grados.first.copyWith(costoExamenCentavos: 0),
              actorUsuarioId: 'usr-${rolNoDueno.name}',
              rolActor: rolNoDueno,
            ),
            throwsStateError,
          );

          expect(
            () => motor.cancelarTicket(
              ticketId: 'tkt-demo-1',
              motivo: 'Intento sin permiso',
              actorUsuarioId: 'usr-${rolNoDueno.name}',
              rolActor: rolNoDueno,
            ),
            throwsStateError,
          );
        }
      },
    );

    test(
      'BUG-002 · impide que un instructor, recepcion o tutor ejecute una baja ARCO o exporte expedientes sin permiso de Dueño',
      () {
        final motor = MotorDoyang.demo();

        // Un instructor no tiene permiso para exportar expedientes financieros/médicos ARCO
        expect(
          () => motor.exportarExpedienteArcoJson(
            'tutor-laura',
            ejecutadoPorId: 'inst-1',
            rolEjecutor: RolUsuario.instructor,
          ),
          throwsStateError,
          reason:
              'Un usuario con rol instructor pudo exportar el expediente ARCO completo con recibos financieros y datos médicos.',
        );

        // Un instructor o tutor no puede ejecutar la baja y anonimización ARCO de la academia
        expect(
          () => motor.ejecutarBajaArcoTutorOAlumno(
            tutorId: 'tutor-laura',
            ejecutadoPorId: 'inst-1',
            rolEjecutor: RolUsuario.instructor,
          ),
          throwsStateError,
          reason:
              'Un usuario con rol instructor pudo ejecutar la baja y cancelación ARCO de toda una familia.',
        );

        // Un tutor tampoco puede exportar el expediente ARCO de otra familia
        expect(
          () => motor.exportarExpedienteArcoJson(
            'tutor-laura',
            ejecutadoPorId: 'tutor-carlos',
            rolEjecutor: RolUsuario.tutor,
          ),
          throwsStateError,
        );

        // El propio tutor titular sí puede exportar su expediente ARCO y queda en colaOutbox
        final outboxAntes = motor.colaOutbox.length;
        final jsonPropio = motor.exportarExpedienteArcoJson(
          'tutor-laura',
          ejecutadoPorId: 'tutor-laura',
          rolEjecutor: RolUsuario.tutor,
        );
        expect(jsonPropio, contains('tutor-laura'));
        expect(motor.colaOutbox.length, equals(outboxAntes + 1));

        // Instructor no puede registrar tutores/alumnos, revocar consentimiento de salud ni autorizar excepciones de examen
        expect(
          () => motor.revocarConsentimientoSaludTutor(
            'tutor-carlos',
            actorUsuarioId: 'inst-1',
            rolActor: RolUsuario.instructor,
          ),
          throwsStateError,
        );
        expect(
          () => motor.inscribirAlumnoExamen(
            convocatoriaId: 'conv-invierno-2026',
            alumnoId: 'alumno-sofia',
            consentimientoTutorAceptado: true,
            excepcionAutorizada: true,
            motivoExcepcionOpcional: 'Autorización indebida',
            rolActor: RolUsuario.recepcion,
          ),
          throwsStateError,
        );
      },
    );

    test(
      'valida invariantes de LineaTicket/TicketPago, verificarQrTicket, saneamiento ARCO en colaOutbox y prevención de CSV Injection',
      () {
        final motor = MotorDoyang.demo();

        // 1. Invariantes de LineaTicket y TicketPago (I-01)
        expect(
          () => LineaTicket(
            cargoId: 'c1',
            alumnoNombre: 'Test',
            concepto: 'Test',
            montoAbonadoCentavos: 0,
            saldoRestanteCargoCentavos: 0,
          ),
          throwsArgumentError,
        );
        expect(
          () => TicketPago(
            id: 'tkt-descuadre',
            folio: 'CAJA1-2026-88888',
            academiaId: motor.academia.id,
            tutorId: 'tutor-laura',
            emitidoEnIso: '2026-11-23T18:00:00Z',
            metodoPago: MetodoPago.efectivo,
            lineas: <LineaTicket>[
              LineaTicket(
                cargoId: 'c1',
                alumnoNombre: 'Test',
                concepto: 'Test',
                montoAbonadoCentavos: 40000,
                saldoRestanteCargoCentavos: 0,
              ),
            ],
            totalPagadoCentavos: 50000,
            cajeroUsuarioId: 'recepcion-1',
            codigoVerificacionQr: 'qr',
          ),
          throwsArgumentError,
        );

        // 2. PAN con puntos/dobles espacios y CVV con tilde "código de seguridad" (B-03 / Legal #1)
        for (final refProhibida in <String>[
          '4152  3133  4444  5555',
          '4152.3133.4444.5555',
          '4152/3133/4444/5555',
          'código de seguridad: 456',
          'cód. seg. 789',
        ]) {
          expect(
            () => validarReferenciaPagoSegura(refProhibida),
            throwsA(isA<ViolacionPrivacidadException>()),
          );
        }

        // 3. Verificación QR de ticket demo y de ticket cancelado (I-02)
        final ticketDemo = motor.tickets.first;
        expect(
          motor.verificarQrTicket(ticketDemo.codigoVerificacionQr),
          isTrue,
        );
        expect(
          motor.verificarQrTicket(
            'dojang://verify/acad-leones-tkd/CAJA1-2026-00001/FALSIFICADO',
          ),
          isFalse,
        );

        // 4. Saneamiento de colaOutbox y abono parcial en baja ARCO (I-03 / Legal #2 / Revisor #3)
        motor.registrarAlumno(motor.obtenerAlumnoPorId('alumno-diego'));
        motor.registrarCobro(
          tutorId: 'tutor-carlos',
          abonosPorCargoId: const <String, int>{
            'cargo-mens-diego-2026-11': 30000,
          },
          metodoPago: MetodoPago.efectivo,
        );
        motor.ejecutarBajaArcoTutorOAlumno(
          tutorId: 'tutor-carlos',
          ejecutadoPorId: 'dueno-1',
          rolEjecutor: RolUsuario.dueno,
        );

        final cargoDiegoArco = motor.cargos
            .firstWhere((c) => c.id == 'cargo-mens-diego-2026-11');
        expect(cargoDiegoArco.saldoCentavos, equals(0));
        expect(cargoDiegoArco.totalCentavos, equals(30000));
        expect(cargoDiegoArco.estado, equals(EstadoCargo.pagado));

        final eventoAlumnoOutbox = motor.colaOutbox.firstWhere(
          (e) =>
              e.tipoOperacion == 'REGISTRAR_ALUMNO' &&
              e.entidadId == 'alumno-diego',
        );
        expect(eventoAlumnoOutbox.payload['tipoSangreOpcional'], isNull);
        expect(eventoAlumnoOutbox.payload['alergiasCuidadosOpcional'], isNull);
        expect(
          eventoAlumnoOutbox.payload['nombre'],
          equals('REGISTRO CANCELADO ARCO'),
        );

        // 5. Prevención de CSV Formula Injection (S-01)
        final inscMateo = motor.inscribirAlumnoTorneo(
          torneoId: 'torneo-copa-primavera',
          alumnoId: 'alumno-mateo',
          modalidad: ModalidadTorneo.kyorugi,
          pesoKgRegistrado: 36.5,
          categoriaDivision: '=CMD()|"/C calc"!A0',
          responsivaTutorAceptada: true,
        );
        // Prefijo de caja normalizado en IDs generados (B-04)
        expect(inscMateo.id, contains('-CAJA1-'));

        motor.registrarCobro(
          tutorId: 'tutor-laura',
          abonosPorCargoId: <String, int>{inscMateo.cargoId: 75000},
          metodoPago: MetodoPago.efectivo,
        );
        final csvTorneo = motor.exportarInscritosTorneoCupaCsv(
          'torneo-copa-primavera',
        );
        expect(csvTorneo, contains("'=CMD()"));
      },
    );
  });
}

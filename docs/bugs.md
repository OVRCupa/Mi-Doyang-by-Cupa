# Bugs · Mi Doyang by Cupa (`gestion-academias`)

Formato conforme a la skill `romper-la-app` (`.claude/skills/romper-la-app/SKILL.md`). Numera `BUG-001`, `BUG-002`…

## Resumen de hallazgos abiertos (`mi_doyang_core`)

| Severidad | Abiertos | Cerrados | IDs |
|---|---:|---:|---|
| **Crítica** | 0 | 1 | `BUG-002` [RESUELTO] |
| **Alta** | 0 | 4 | `BUG-001` [RESUELTO], `BUG-003` [RESUELTO], `BUG-004` [RESUELTO], `BUG-005` [RESUELTO] |
| **Media** | 0 | 0 | — |
| **Baja** | 0 | 0 | — |

---

### BUG-001 · [RESUELTO] · [Severidad: Alta] · `inscribirAlumnoExamen` e `inscribirAlumnoTorneo` permiten inscribir dos veces al mismo alumno en el mismo evento y duplican el cargo monetario
- Plataforma/versión: `core/` (`mi_doyang_core` v0.1.0 · Dart puro · Windows / Android)
- Archivo afectado: `core/lib/src/motor_doyang.dart` (`inscribirAlumnoExamen`, líneas 1085–1167; `inscribirAlumnoTorneo`, líneas 1412–1485)
- Pasos para reproducir:
  1. Instanciar `final motor = MotorDoyang.demo();`.
  2. Llamar a `motor.inscribirAlumnoExamen(convocatoriaId: 'conv-invierno-2026', alumnoId: 'alumno-mateo', consentimientoTutorAceptado: true);`.
  3. Volver a llamar a `motor.inscribirAlumnoExamen(convocatoriaId: 'conv-invierno-2026', alumnoId: 'alumno-mateo', consentimientoTutorAceptado: true);` para el mismo alumno y la misma convocatoria.
  4. De forma análoga, llamar dos veces seguidas a `motor.inscribirAlumnoTorneo(torneoId: 'torneo-copa-primavera', alumnoId: 'alumno-mateo', modalidad: ModalidadTorneo.kyorugi, pesoKgRegistrado: 36.8, categoriaDivision: 'Infantil -39 kg', responsivaTutorAceptada: true);`.
- Resultado esperado:
  - El segundo intento de inscripción del mismo `alumnoId` a la misma `convocatoriaId` o al mismo `torneoId` debe lanzar `StateError` indicando que el alumno ya se encuentra inscrito en dicho evento, sin generar un segundo `CargoCuenta`.
- Resultado obtenido:
  - Ambos métodos carecen de verificación de duplicados (`inscripcionesExamen.any(...)` / `inscripcionesTorneo.any(...)`). El motor crea una segunda inscripción y agrega un segundo `CargoCuenta` por derecho a examen (`$650.00 MXN`) o cuota de torneo (`$750.00 MXN`) al estado de cuenta familiar. Además, si ambos cargos de torneo se pagan, el alumno aparece duplicado dos veces en la exportación `exportarInscritosTorneoCupaJson` y `exportarInscritosTorneoCupaCsv`.
- Prueba que lo demuestra: `core/test/cazador_core_test.dart` (`3 · Inmutabilidad y estado del dominio -> BUG-001 · impide inscribir dos veces al mismo alumno en la misma convocatoria de examen o en el mismo torneo`)
- Evidencia:
  ```text
  00:00 +9 -3: 3 · Inmutabilidad y estado del dominio BUG-001 · impide inscribir dos veces al mismo alumno en la misma convocatoria de examen o en el mismo torneo [E]
    Expected: throws <Instance of 'StateError'>
      Actual: <Closure: () => InscripcionExamen>
       Which: returned <Instance of 'InscripcionExamen'>
    Permitió inscribir dos veces a alumno-mateo en conv-invierno-2026 y duplicó el cargo de examen.
  ```

---

### BUG-002 · [RESUELTO] · [Severidad: Crítica] · `ejecutarBajaArcoTutorOAlumno` y `exportarExpedienteArcoJson` no validan el rol RBAC (`rolEjecutor`), permitiendo bajas ARCO y fugas de expedientes por roles no autorizados
- Plataforma/versión: `core/` (`mi_doyang_core` v0.1.0 · Dart puro · Windows / Android)
- Archivo afectado: `core/lib/src/motor_doyang.dart` (`exportarExpedienteArcoJson`, líneas 1606–1658; `ejecutarBajaArcoTutorOAlumno`, líneas 1668–1799)
- Pasos para reproducir:
  1. Instanciar `final motor = MotorDoyang.demo();`.
  2. Invocar `motor.exportarExpedienteArcoJson('tutor-laura', ejecutadoPorId: 'inst-1', rolEjecutor: RolUsuario.instructor);`.
  3. Invocar `motor.ejecutarBajaArcoTutorOAlumno(tutorId: 'tutor-laura', ejecutadoPorId: 'inst-1', rolEjecutor: RolUsuario.instructor);` (o con `RolUsuario.recepcion` / `RolUsuario.tutor`).
- Resultado esperado:
  - Conforme a `D-10` (`docs/decisiones.md`) y la matriz RBAC de `docs/privacidad.md` (§7.1), el rol `instructor` tiene prohibido acceder a recibos financieros o exportar expedientes completos, y ni `instructor` ni `recepcion` pueden eliminar/anonimizar alumnos o ejecutar bajas ARCO en el panel de la academia. Ambos métodos deben validar `rolEjecutor == RolUsuario.dueno` y lanzar `StateError` cuando se invocan con un rol sin privilegios.
- Resultado obtenido:
  - Ninguno de los dos métodos valida `rolEjecutor`; únicamente lo registran en `_registrarBitacora`. Un usuario con `RolUsuario.instructor` obtiene el JSON completo del expediente ARCO (incluyendo todos los tickets de pago, cargos y datos médicos) y puede ejecutar la baja y anonimización irreversible ARCO de cualquier familia de la academia.
- Prueba que lo demuestra: `core/test/cazador_core_test.dart` (`4 · Control de Acceso Basado en Roles (RBAC · D-10) -> BUG-002 · impide que un instructor, recepcion o tutor ejecute una baja ARCO o exporte expedientes sin permiso de Dueño`)
- Evidencia:
  ```text
  00:00 +11 -5: 4 · Control de Acceso Basado en Roles (RBAC · D-10) BUG-002 · impide que un instructor, recepcion o tutor ejecute una baja ARCO o exporte expedientes sin permiso de Dueño [E]
    Expected: throws <Instance of 'StateError'>
      Actual: <Closure: () => String>
       Which: returned '{\n  "marco_legal": "LFPDPPP 2025 · Derecho de Acceso y Portabilidad ARCO", ...'
    Un usuario con rol instructor pudo exportar el expediente ARCO completo con recibos financieros y datos médicos.
  ```

---

### BUG-003 · [RESUELTO] · [Severidad: Alta] · `registrarEvaluacionExamen` permite evaluar y promover de cinta a un alumno dado de baja por cancelación ARCO (`bloqueadoArco = true`, `activo = false`)
- Plataforma/versión: `core/` (`mi_doyang_core` v0.1.0 · Dart puro · Windows / Android)
- Archivo afectado: `core/lib/src/motor_doyang.dart` (`registrarEvaluacionExamen`, líneas 1172–1246; también afecta `evaluarElegibilidadExamen` l. 977, `inscribirAlumnoExamen` l. 1085, `crearPedidoEquipo` l. 1269 e `inscribirAlumnoTorneo` l. 1412)
- Pasos para reproducir:
  1. Instanciar `final motor = MotorDoyang.demo();`.
  2. Inscribir a `'alumno-mateo'` en `'conv-invierno-2026'` con `inscribirAlumnoExamen` y liquidar su cargo de examen con `registrarCobro`.
  3. Ejecutar la baja y cancelación ARCO del alumno mediante `motor.ejecutarBajaArcoTutorOAlumno(alumnoId: 'alumno-mateo', ejecutadoPorId: 'dueno-1');` (lo que deja al alumno con `bloqueadoArco = true` y `activo = false`).
  4. Llamar a `motor.registrarEvaluacionExamen(inscripcionExamenId: inscripcion.id, evaluacion: EvaluacionExamen(poomsae: 95, kyorugi: 90, rompimiento: 92, teoria: 94, aprobado: true, evaluadoEnIso: '2026-12-12T12:00:00Z'));`.
- Resultado esperado:
  - Al igual que `registrarAsistencia` (línea 490), `registrarEvaluacionExamen` (y las operaciones de inscripción a examen, torneo y pedidos de equipo) debe verificar `if (!alumno.activo || alumno.bloqueadoArco)` y lanzar `StateError`, impidiendo evaluar, ascender de grado o generar nuevos cargos a un expediente cancelado por derechos ARCO.
- Resultado obtenido:
  - Como el cargo ya estaba pagado antes de la baja ARCO (`EstadoCargo.pagado`), `registrarEvaluacionExamen` no verifica `alumnoActual.bloqueadoArco` ni `alumnoActual.activo`, promueve al registro `'REGISTRO CANCELADO ARCO'` al grado `'grado-5-geup'`, inserta un nuevo `RegistroHistorialGrado` y encola un evento en `colaOutbox`.
- Prueba que lo demuestra: `core/test/cazador_core_test.dart` (`3 · Inmutabilidad y estado del dominio -> BUG-003 · impide evaluar examen o inscribir en examen/torneo/equipo a un alumno dado de baja por cancelación ARCO`)
- Evidencia:
  ```text
  00:00 +9 -4: 3 · Inmutabilidad y estado del dominio BUG-003 · impide evaluar examen o inscribir en examen/torneo/equipo a un alumno dado de baja por cancelación ARCO [E]
    Expected: throws <Instance of 'StateError'>
      Actual: <Closure: () => InscripcionExamen>
       Which: returned <Instance of 'InscripcionExamen'>
    Permitió evaluar y promover de cinta a un alumno dado de baja por cancelación ARCO.
  ```

---

### BUG-004 · [RESUELTO] · [Severidad: Alta] · `inscribirAlumnoTorneo` muta el peso del alumno y agrega un `CargoCuenta` huérfano antes de validar `pesoKgRegistrado > 0`
- Plataforma/versión: `core/` (`mi_doyang_core` v0.1.0 · Dart puro · Windows / Android)
- Archivo afectado: `core/lib/src/motor_doyang.dart` (`inscribirAlumnoTorneo`, líneas 1436–1476)
- Pasos para reproducir:
  1. Instanciar `final motor = MotorDoyang.demo();` (`alumno-mateo` tiene `pesoKgOpcional == 36.5` y `motor.cargos.length == 3`).
  2. Llamar a `motor.inscribirAlumnoTorneo(torneoId: 'torneo-copa-primavera', alumnoId: 'alumno-mateo', modalidad: ModalidadTorneo.kyorugi, pesoKgRegistrado: -15.0, categoriaDivision: 'Infantil -39 kg', responsivaTutorAceptada: true);`.
  3. Capturar el `ArgumentError` lanzado por el constructor de `InscripcionTorneo` y consultar `motor.obtenerAlumnoPorId('alumno-mateo').pesoKgOpcional` y `motor.cargos.length`.
- Resultado esperado:
  - Si `pesoKgRegistrado <= 0`, `inscribirAlumnoTorneo` debe lanzar `ArgumentError` **antes** de modificar `alumnos[idxAlumno]` y **antes** de insertar el `CargoCuenta` en `cargos`, manteniendo la atomicidad del estado del motor.
- Resultado obtenido:
  - En la línea 1441 el método sobrescribe `alumnos[idxAlumno] = alumno.copyWith(pesoKgOpcional: -15.0)` y en la línea 1459 ejecuta `cargos.add(cargo)` por `$750.00 MXN` antes de construir `InscripcionTorneo` en la línea 1461. Cuando `InscripcionTorneo` lanza `ArgumentError`, el alumno queda con peso `-15.0 kg` y la familia queda con un cargo huérfano de `$750.00 MXN` en su estado de cuenta por una inscripción inexistente.
- Prueba que lo demuestra: `core/test/cazador_core_test.dart` (`1 · Entradas extremas y monetarias -> BUG-004 · inscribirAlumnoTorneo con pesoKgRegistrado <= 0 no debe corromper el peso del alumno ni dejar cargos huérfanos`)
- Evidencia:
  ```text
  00:00 +1 -1: 1 · Entradas extremas y monetarias BUG-004 · inscribirAlumnoTorneo con pesoKgRegistrado <= 0 no debe corromper el peso del alumno ni dejar cargos huérfanos [E]
    Expected: <36.5>
      Actual: <-15.0>
    El peso del alumno fue corrompido con un valor negativo tras fallar inscribirAlumnoTorneo.
  ```

---

### BUG-005 · [RESUELTO] · [Severidad: Alta] · `registrarCobro` no valida que los cargos abonados pertenezcan al `tutorId` del ticket, permitiendo mezclar cobros entre familias distintas
- Plataforma/versión: `core/` (`mi_doyang_core` v0.1.0 · Dart puro · Windows / Android)
- Archivo afectado: `core/lib/src/motor_doyang.dart` (`registrarCobro`, líneas 676–720)
- Pasos para reproducir:
  1. Instanciar `final motor = MotorDoyang.demo();`.
  2. Observar que el cargo `'cargo-mens-sofia-2026-11'` pertenece a la familia `'tutor-laura'` (`cargo.tutorId == 'tutor-laura'`).
  3. Llamar a `motor.registrarCobro(tutorId: 'tutor-carlos', abonosPorCargoId: {'cargo-mens-sofia-2026-11': 72000}, metodoPago: MetodoPago.efectivo);`.
- Resultado esperado:
  - `registrarCobro` debe verificar que `tutorId` exista y que todos los cargos incluidos en `abonosPorCargoId` pertenezcan a ese `tutorId` (`cargo.tutorId == tutorId`), lanzando `StateError` o `ArgumentError` si se intenta cobrar un cargo de otra familia.
- Resultado obtenido:
  - `registrarCobro` no valida la titularidad del cargo ni la existencia de `tutorId`. Emite un `TicketPago` asignado a `'tutor-carlos'` que liquida el cargo de `'tutor-laura'`, contaminando la bandeja de comprobantes y la exportación ARCO entre familias distintas.
- Prueba que lo demuestra: `core/test/cazador_core_test.dart` (`3 · Inmutabilidad y estado del dominio -> BUG-005 · registrarCobro no debe permitir que un tutor cobre cargos pertenecientes a otra familia`)
- Evidencia:
  ```text
  00:00 +8 -2: 3 · Inmutabilidad y estado del dominio BUG-005 · registrarCobro no debe permitir que un tutor cobre cargos pertenecientes a otra familia [E]
    Expected: throws (<Instance of 'StateError'> or <Instance of 'ArgumentError'>)
      Actual: <Closure: () => TicketPago>
       Which: returned <Instance of 'TicketPago'>
    registrarCobro permitió emitir un ticket a nombre de tutor-carlos pagando un cargo de tutor-laura.
  ```

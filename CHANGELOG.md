# Cambios · Mi Doyang by Cupa (`gestion-academias`)

## [Sin publicar]
- **App Flutter Multiplataforma (`app/`, Windows + Android) y Puerta de Calidad aprobada:**
  - Tema propio (`app/lib/theme/tema_doyang.dart`) con paleta *Papel Dobok / Chung / Hong*, validación WCAG 2.1 AA en personalización y fuente **Oswald (OFL)** empaquetada offline.
  - Componentes propios de Taekwondo: `BeltWidget` (faja `5:1` con costura, punta reservada en 20% derecho y cinta Poom rojinegra) y `TicketTermicoWidget` (80 mm / 58 mm con cifras tabulares, leyenda `(IMPORTES EN MXN)`, sello `PAGADO`/`CANCELADO` y QR verificable).
  - Las 3 experiencias vinculadas al mismo estado reactivo (`ControladorDoyang` + persistencia local atómica offline-first): **Recepción y Administración (Windows)** con los 6 módulos (`M1`–`M6`) y atajos `F2`/`F3`/`F4`, **Portal del Padre de Familia (Android)** multi-hijo con bandeja de tickets, grados, torneos y tienda de equipo, e **Instructor en Tatami (Android)** con pase de lista QR y alertas médicas autorizadas.
  - Revisiones pasadas: `revisor-diseno`, `revisor-codigo`, `legal-privacidad-mx`, `seguridad` y `cazador-de-bugs` (`flutter analyze` sin errores y **10/10 pruebas** en verde, incluyendo pantallas extremas `360×640 @ 130%` y `1024×720 @ 130%`).
- **Motor de Dominio (`core/`, Dart puro `mi_doyang_core`) y Puerta de Calidad aprobada:**
  - Implementación completa de `M1`–`M6` en centavos enteros (`int`), RBAC de 4 roles, protección anti-PAN/CVV, derechos ARCO (`exportarExpedienteArcoJson` y `ejecutarBajaArcoTutorOAlumno` con disociación contable y saneamiento de `colaOutbox`), verificación QR de tickets y exportación JSON/CSV para sistemas CUPA.
  - Resueltos `BUG-001` a `BUG-005` reportados por `cazador-de-bugs` y hallazgos de `seguridad` y `revisor-codigo` (`dart analyze` sin errores y **35/35 pruebas** en verde).
- **Bases del proyecto creadas** con la skill `nuevo-proyecto`:
  - Investigación de mercado y precios en México (`investigador` → `docs/research/competencia-precios.md`).
  - PRD v0.1 con los 6 módulos del sistema y criterios de aceptación (`producto` → `docs/prd.md`).
  - Decisiones arquitectónicas D-01 a D-12, arquitectura de 20 tablas multi-tenant con caja offline-first y matriz de riesgos (`arquitecto` → `docs/decisiones.md`, `docs/arquitectura.md`, `docs/riesgos.md`).
  - Plan de diseño visual y tokens verificados bajo WCAG 2.1 AA (`diseno-con-criterio` + `revisor-diseno` → `docs/diseno.md`).
  - Inventario de datos personales, avisos de privacidad (integral y simplificado) y contrato de encargo conforme a la LFPDPPP 2025 y Profeco (`legal-privacidad-mx` → `docs/privacidad.md`, `legal/`).

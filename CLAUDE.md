# Reglas de este proyecto · Cupa Dojang (`gestion-academias`)

Hereda las reglas del `CLAUDE.md` de la raíz del espacio. Lo de aquí gana si hay conflicto.

- **Independencia:** Este proyecto es 100% independiente; no importes código, datos ni configuración de otras carpetas de proyecto (`marcador-tkd`, etc.). La comunicación futura con otros sistemas CUPA (como exportar competidores inscritos a un torneo) se hace mediante archivos estándar JSON/CSV.
- **Estructura de código (a partir de Compuerta C2):**
  - `core/`: lógica de dominio en Dart puro (sin Flutter): cálculo de mensualidades, descuentos familiares por hermanos, recargos por mora, folios y desglose de tickets, elegibilidad de ascenso de cinta/examen y control de inventario de equipo.
  - `app/`: aplicación multiplataforma Flutter para **Windows** (escritorio: recepción y administración) y **Android** (móvil: padres de familia e instructores), preparada para iOS.
- **Comandos (Flutter en `C:\src\flutter\bin`):**
  - Pruebas del motor: `cd core; dart test`
  - Análisis del motor: `cd core; dart analyze`
  - Pruebas de la app: `cd app; flutter test`
  - Análisis de la app: `cd app; flutter analyze`
  - Ejecutar en Windows: `cd app; flutter run -d windows`
  - Ejecutar en Android: `cd app; flutter run -d android`
  - Compilar Windows: `cd app; flutter build windows --release`
  - Compilar Android: `cd app; flutter build apk --debug` / `flutter build appbundle`
- **Reglas propias del producto:**
  1. **Aislamiento multi-academia (Multi-tenant):** Toda tabla en Supabase lleva `academia_id` con políticas **Row Level Security (RLS)** activas. Ningún usuario puede leer ni modificar registros de otra academia, y un usuario con rol `tutor` solo puede leer los registros de sus hijos vinculados en `tutor_alumnos`.
  2. **Caja Offline-First en Windows:** La recepción no puede detenerse si falla el internet del gimnasio. Todo cobro y emisión de ticket se guarda primero en SQLite local (**Drift**) con folio prefijado por caja y se sincroniza mediante cola idempotente (`outbox`) con Supabase.
  3. **Inmutabilidad de tickets y pagos:** Un ticket de comprobante emitido nunca se edita ni se borra; si hay un error en un cobro, se emite un evento de **cancelación / nota de ajuste** que deja rastro en la bitácora.
  4. **Privacidad de menores y datos sensibles (`privacidad-mx`):**
     - La academia es la **Responsable** y CUPA es **Encargada** del tratamiento de los datos de alumnos y tutores.
     - Todo menor de edad debe estar vinculado a un padre/tutor con registro de consentimiento.
     - Los campos médicos para seguridad en clase (tipo de sangre, alergias/lesiones) son opcionales y requieren casilla de consentimiento expreso y separado.
     - Nunca se guardan números de tarjeta ni CVV en la base de datos.
  5. **Diseño y personalización controlada (`diseno-con-criterio`):**
     - Todos los colores, tipografías y dimensiones provienen de `app/lib/theme/`.
     - Cuando una academia personaliza su color primario o sus cintas, el sistema valida y ajusta la luminancia para mantener contraste WCAG AA (≥ 4.5:1).
     - Todos los montos en pesos mexicanos usan formato `$1,250.00 MXN` y cifras tabulares (`FontFeature.tabularFigures()`).

# Decisiones · Cupa Dojang: Gestión de Academias TKD

Cada decisión arquitectónica y de producto queda registrada con fecha, contexto, opciones evaluadas, decisión recomendada y consecuencias. `"Pendiente"` indica que espera confirmación final de Carlos.

---

## 2026-11-23 · D-01 · Nombre comercial y marca — **Recomendado: "Cupa Dojang: Gestión TKD"**
- **Contexto:** El producto forma parte de la familia de software deportivo **CUPA** (junto con OSS CUPA y *Cupa Pocket: Marcador TKD*). Necesita un nombre que identifique inmediatamente al nicho de Taekwondo ("Dojang") y su función ("Gestión TKD"), respetando el límite estricto de **30 caracteres** en el título de Google Play Store y manteniendo coherencia en los identificadores de paquete (`com.ovrcupa.dojang.academias`).
- **Opciones:**
  1. **Cupa Dojang: Gestión TKD** (24 caracteres en tienda; nombre completo comercial: *Cupa Dojang: Gestión de Academias TKD*).
  2. **Cupa Academias Taekwondo** (24 caracteres, más genérico, pierde el término identitario *Dojang*).
  3. **Dojang Pro by Cupa** (18 caracteres, pero no incluye palabras clave de búsqueda como "Gestión" o "TKD" en el título).
- **Decisión:** **"Cupa Dojang: Gestión TKD"** como título en tiendas (24 caracteres) y **"Cupa Dojang: Gestión de Academias TKD"** en documentación comercial, web e instalador de Windows. Identificador de aplicación Android/iOS: `com.ovrcupa.dojang.academias`.
- **Consecuencias:**
  - Cumple la regla de marca CUPA y cabe holgadamente en los 30 caracteres de Google Play y Apple App Store.
  - Posiciona las palabras clave "Dojang", "Gestión" y "TKD" en el título, dejando "Taekwondo", "Academia", "Escuela", "Cobros" y "Cintas" para la descripción corta.
  - Se debe verificar y registrar la marca **"Cupa Dojang"** ante el IMPI (Clases 9 y 42) antes del lanzamiento comercial.

---

## 2026-11-23 · D-02 · Modelo comercial SaaS B2B en MXN para academias — **Decidido: Suscripción mensual/anual escalonada por alumnos activos, 0% comisión en caja**
- **Contexto:** Las academias de Taekwondo en México y LATAM cobran la gran mayoría de sus mensualidades, exámenes, equipo y torneos en **efectivo o transferencia SPEI directa** en la recepción del dojang. Los softwares extranjeros (Kicksite, Spark, Mindbody) cobran en USD ($99–$299 USD/mes) o imponen comisiones sobre los cobros, lo que provoca rechazo inmediato de los maestros dueños de academia. Además, si la app cobrara la colegiatura dentro de Google Play, se activaría la comisión del 15%–30% de la tienda o fricciones regulatorias de agregador de pagos.
- **Opciones:**
  1. **SaaS B2B por niveles de alumnos activos en MXN, sin comisión por cobros registrados en caja** (contratación B2B directa con la academia; la app móvil para padres es un visor y portal gratuito para las familias de una academia activa).
  2. **Comisión por transacción (2%–4%) integrando pasarela obligatoria** (Stripe/Conekta/MercadoPago).
  3. **Licencia perpetua de pago único por PC**.
- **Decisión:** **Opción 1 — Suscripción SaaS B2B en pesos mexicanos (MXN) por tramos de alumnos activos**, con **0% de comisión** sobre los pagos en efectivo, transferencia o terminal registrados en la recepción:
  - **Plan Dojang Inicial** (hasta 60 alumnos activos): **$499 MXN / mes** (o $4,990 MXN / año).
  - **Plan Dojang Pro** (hasta 150 alumnos activos): **$899 MXN / mes** (o $8,990 MXN / año).
  - **Plan Dojang Maestro / Multisede** (hasta 350 alumnos activos o 2 sedes): **$1,499 MXN / mes**.
- **Consecuencias:**
  - El dueño de la academia percibe un costo fijo, predecible y hasta 4 veces menor que las alternativas en dólares, sin sentir que CUPA "se queda con un porcentaje de sus clases".
  - Al no procesar pagos digitales de colegiaturas dentro de la app Android en el MVP v1.0 (solo registro en caja y subida opcional de comprobante de transferencia para validación humana en recepción), la app móvil cumple sin fricciones las políticas de Google Play y App Store para apps complementarias B2B.
  - Cubre con amplio margen los costos mensuales de infraestructura en la nube (Supabase) desde la primera academia pagada.

---

## 2026-11-23 · D-03 · Plataformas y código compartido — **Decidido: Flutter para Windows + Android (MVP v1.0) e iOS preparado (v1.2)**
- **Contexto:** La operación real de una academia ocurre en dos frentes distintos: (1) la **recepción/escritorio del dojang** (donde una PC o laptop con Windows cobra rápido, usa lector o teclado físico y está conectada por USB/Bluetooth a una impresora térmica de tickets) y (2) el **bolsillo de los padres de familia e instructores** (donde predominan teléfonos Android en México, aunque un segmento de padres de familia y maestros usa iPhone).
- **Opciones:**
  1. **Flutter (código único en Dart)** compilando de forma nativa a **Windows Desktop** y **Android** en v1.0, manteniendo la arquitectura y dependencias listas para compilar **iOS (iPhone)** en v1.2.
  2. **Web App (React/Next.js) + PWA para padres**.
  3. **Desarrollo nativo separado** (C#/.NET para Windows + Kotlin para Android + Swift para iOS).
- **Decisión:** **Opción 1 — Flutter para Windows y Android en v1.0, con compatibilidad iOS lista para v1.2.**
- **Consecuencias:**
  - Mismo lenguaje y stack que el resto del espacio de proyectos CUPA (`marcador-tkd`), aprovechando el conocimiento del equipo pequeño.
  - En **Windows**, acceso directo y sin fricciones del navegador a puertos USB/COM y cola de impresión para tickets térmicos, además de base de datos SQLite local en disco para operar sin internet.
  - En **Android**, experiencia nativa fluida con cámara para escanear QR de asistencias/tickets y compartir comprobantes por WhatsApp.
  - Se prohíbe usar paquetes que dependan exclusivamente de un solo sistema móvil; cualquier integración nativa (como impresión USB en Windows vs Bluetooth en Android/iOS) se abstrae detrás de una interfaz común (`TicketPrinterService`).

---

## 2026-11-23 · D-04 · Backend multi-tenant y sincronización — **Decidido: Supabase (PostgreSQL + Auth + Storage + Realtime) con RLS estricto por `academia_id`**
- **Contexto:** Los datos deben estar sincronizados entre la PC de recepción en Windows, el celular del dueño/instructor y la app Android de cada padre de familia. Al ser un SaaS multi-academia (multi-tenant), una academia jamás debe poder leer ni modificar registros de otra academia, ni siquiera si un cliente manipula una petición desde la app.
- **Opciones:**
  1. **Supabase** (PostgreSQL gestionado + GoTrue Auth + Storage con políticas + Realtime) utilizando una columna `academia_id` en todas las tablas operativas y políticas **Row Level Security (RLS)** en PostgreSQL basadas en el perfil del usuario autenticado.
  2. **Firebase (Firestore + Auth + Storage)**.
  3. **Backend propio desde cero (Node.js/Go + PostgreSQL en VPS)** mantenido por el equipo.
- **Decisión:** **Opción 1 — Supabase con PostgreSQL multi-tenant y aislamiento por RLS (`academia_id`).**
- **Consecuencias:**
  - El modelo financiero y académico (estados de cuenta, cargos, pagos parciales, inventario de tallas, inscripciones a exámenes y torneos) es intrínsecamente relacional; PostgreSQL garantiza integridad referencial y transacciones ACID que en NoSQL (Firestore) serían frágiles y costosas.
  - La seguridad vive en el motor de base de datos (RLS): aunque hubiera un bug en la interfaz de Flutter, PostgreSQL rechaza cualquier `SELECT/INSERT/UPDATE/DELETE` fuera del `academia_id` o de los hijos asignados al `tutor_id`.
  - Costo inicial $0 USD en etapa de desarrollo/piloto (Free Tier) y $25 USD/mes en producción (Pro Tier) para decenas de academias.

---

## 2026-11-23 · D-05 · Operación Offline-First en Caja (Windows) y Caché Local (Android) — **Decidido: Drift (SQLite) + Cola `outbox` idempotente**
- **Contexto:** En los dojangs el internet falla con frecuencia o el módem se satura exactamente a la hora pico (entre las 17:00 y las 20:00 h, cuando salen un grupo de niños, entran otros y se forma una fila de 15 padres queriendo pagar mensualidad, examen o equipo y recibir su ticket impreso). Si la caja en Windows se bloquea por falta de internet, la recepción colapsa y vuelven al cuaderno de papel. Asimismo, los padres deben poder abrir la app Android y consultar su último estado de cuenta, tickets descargados y el QR de asistencia de su hijo aunque no tengan datos móviles dentro del gimnasio.
- **Opciones:**
  1. **Offline-First con Drift (SQLite local) y cola de sincronización (`outbox`)**: lectura instantánea desde SQLite local; en Windows se permite registrar cobros, emitir tickets con folio local prefijado por caja (`CAJA1-2026-000142`) y pasar asistencia sin internet, encolando las mutaciones firmadas con `UUID` para sincronizarlas automáticamente al volver la red.
  2. **100% Online (solo peticiones directas a Supabase)**: si no hay red, mostrar pantalla de error.
  3. **Sincronización CRDT compleja de propósito general** (PowerSync / ElectricSQL de pago).
- **Decisión:** **Opción 1 — Drift (SQLite) como fuente de lectura local + tabla `sync_outbox` transaccional e idempotente.**
- **Consecuencias:**
  - **En Windows (Recepción) e Instructor (Asistencia):** nunca se detiene el cobro ni el pase de lista. El pago se guarda en SQLite en menos de 10 ms, el ticket térmico se imprime al instante con un folio único determinista (`{prefijo_caja}-{año}-{consecutivo_local}` + `client_mutation_id` UUID v4/v7) y un indicador visible muestra `"Modo sin conexión · 3 pagos pendientes de sincronizar"`.
  - **En el servidor (Supabase):** una función RPC transaccional (`procesar_pago_offline`) recibe el `client_mutation_id`; si el pago ya se había procesado en un reintento previo, devuelve éxito sin duplicar el cobro (idempotencia garantizada).
  - **En Android (Padres):** los estados de cuenta, tickets, progreso de cinta y código QR del alumno están cacheados en Drift para consulta inmediata sin red, mostrando la marca de tiempo de la última sincronización.

---

## 2026-11-23 · D-06 · Tickets de comprobante de pago (Impresión térmica + Digital PDF/QR) — **Decidido: Motor dual ESC/POS + PDF con QR verificable**
- **Contexto:** El dolor número uno en la relación entre padres de familia y academias es la falta de comprobantes claros: *"Maestro, yo sí pagué el mes pasado en efectivo a la señorita de recepción"*. Las academias necesitan entregar un ticket físico rápido en el mostrador si tienen miniprinter térmica, y al mismo tiempo los padres quieren el comprobante digital en su celular y por WhatsApp con el desglose exacto de qué se pagó.
- **Opciones:**
  1. **Diseño dual unificado desde el mismo modelo `PagoTicket`**:
     - **Impresión térmica física:** soporte para rollos de **58 mm y 80 mm** mediante comandos **ESC/POS** directos (USB/Bluetooth) o cola de impresión estándar de Windows (`printing`).
     - **Ticket digital PDF e Imagen:** generado localmente con `pdf`, con logo y nombre de la academia, folio único, fecha/hora, nombre del alumno y grado, desglose de conceptos (colegiatura, recargo, descuento familiar, equipo, examen, torneo), método de pago, nombre de quien cobró y **código QR de verificación** con firma corta.
  2. **Solo recibo en pantalla dentro de la app** (sin impresión térmica ni PDF).
  3. **Facturación CFDI 4.0 obligatoria en cada ticket**.
- **Decisión:** **Opción 1 — Motor dual (Impresión térmica 58/80 mm ESC/POS + Comprobante digital PDF/Imagen con código QR verificable y envío directo a WhatsApp / App del Padre).** *(Nota: el ticket es un comprobante interno de control escolar/caja; no sustituye un CFDI fiscal, lo cual se aclara en el pie del ticket configurable por la academia).*
- **Consecuencias:**
  - Cualquier academia puede usar una impresora térmica económica de $600–$1,200 MXN (58 mm u 80 mm) conectada a su PC Windows o celular Android, o bien operar 100% sin papel enviando el ticket digital por WhatsApp y notificándolo en la app del padre.
  - El **código QR del ticket** codifica el identificador del pago y un hash corto (`dojang://verify/{academia_id}/{folio}/{hash8}`): cualquier instructor o recepcionista puede escanear el ticket impreso o el PDF desde la app para verificar en 1 segundo que es auténtico y no fue editado, incluso para permitir la entrada a un examen de grado o entregar un uniforme.

---

## 2026-11-23 · D-07 · Personalización por academia (White-label ligero) — **Decidido: Identidad visual, cintas y reglas financieras configurables por tenant**
- **Contexto:** En Taekwondo no todas las escuelas usan exactamente los mismos grados intermedios ni las mismas reglas de cobro: algunas manejan cintas con punta (blanca avanzada, amarilla avanzada, verde avanzada, azul avanzada, roja avanzada / Poom / Dan), otras solo 10 Geups puros; unas cobran recargo el día 6 del mes y otras el día 11; unas dan 10% de descuento al segundo hermano y 20% al tercero. Además, cada maestro siente orgullo por el escudo y colores de su escuela.
- **Opciones:**
  1. **Personalización configurable en base de datos por academia (White-label ligero)** dentro de la misma app publicada por CUPA: logo/escudo de la academia, color primario con validación automática de contraste WCAG AA, catálogo propio de cintas/grados (colores hexadecimales primario y de punta/franja, orden, clases mínimas y meses requeridos), reglas de recargo por mora, descuentos por hermanos y pie de ticket personalizado.
  2. **Rigidez total** (cintas y reglas fijas en código para todas las academias).
  3. **White-label pesado** (compilar y publicar una app distinta en Google Play por cada academia).
- **Decisión:** **Opción 1 — Personalización por academia en base de datos dentro de una sola app oficial en tiendas (`Cupa Dojang: Gestión TKD`).**
- **Consecuencias:**
  - Un solo binario en Play Store y Windows que mantener y actualizar, pero cuando el padre de familia o el recepcionista inicia sesión, ve el escudo de su academia, sus colores en encabezados y tickets, y el sistema de cintas exacto de su escuela.
  - Al crear una academia nueva, un asistente de configuración inicial (*Onboarding*) ofrece la **plantilla estándar WT México** (10.º Geup Blanca a 1.er Dan Negra, con o sin puntas) para que el dueño quede operando en menos de 5 minutos y solo ajuste lo que desee.
  - La función de tema valida que el color elegido por la academia mantenga contraste legible (mínimo 4.5:1); si el dueño elige un amarillo muy claro, el sistema ajusta el tono de acento para texto y botones automáticamente.

---

## 2026-11-23 · D-08 · Modelo familiar (1 Padre/Tutor → N Hijos) — **Decidido: Cuenta centrada en el Tutor con selector rápido de hijos y estado de cuenta familiar**
- **Contexto:** Más del 75% de los alumnos de una academia de Taekwondo son menores de edad (niños y adolescentes de 4 a 17 años), y es muy común que asistan **2 o 3 hermanos** (o incluso el padre y sus hijos) a la misma escuela. Obligar a una mamá a crear 3 correos distintos y cerrar/abrir sesión para ver a cada hijo es una pésima experiencia y rompe el cálculo automático de descuentos por hermanos.
- **Opciones:**
  1. **Modelo Familiar (`perfiles_usuario` Tutor ↔ `tutor_alumnos` N:M ↔ `alumnos`)**: el padre o tutor inicia sesión con una sola cuenta, tiene una barra superior con las fichas de sus hijos ("Sofía · Cinta Amarilla", "Mateo · Cinta Verde", o vista "Todos / Estado de cuenta familiar") y en recepción se puede cobrar a toda la familia en un solo ticket consolidado. Los alumnos mayores de 18 años pueden ser sus propios titulares.
  2. **1 cuenta de usuario = 1 alumno** (modelo tradicional escolar simple).
- **Decisión:** **Opción 1 — Modelo familiar N:M con cuenta titular del Padre/Tutor (o alumno adulto) y cobro familiar unificado.**
- **Consecuencias:**
  - En recepción (Windows), al buscar el apellido de la familia o el teléfono del tutor, aparecen todos los hermanos pendientes de pago, aplicando el **descuento familiar automático** parametrizado por la academia y emitiendo **un solo ticket** que desglosa los cargos de cada hijo.
  - En la app Android, el padre cambia de hijo con un toque o revisa el resumen total a pagar del mes sin cambiar de sesión.
  - Alineación nativa con la **LFPDPPP (México)**: el consentimiento de privacidad y tratamiento de datos de menores queda vinculado directamente al `tutor_id` verificable.

---

## 2026-11-23 · D-09 · Arquitectura en paquetes (`core/` Dart puro + `app/` Flutter) — **Decidido: Separación estricta de reglas de negocio en `core/`**
- **Contexto:** El cálculo de estados de cuenta (prorrateos, descuentos por 2.º y 3.er hermano, recargos por fecha de corte, pagos parciales/abonos, aplicación de saldo a favor), la elegibilidad para examen de cinta (asistencias mínimas desde el último grado + tiempo mínimo + sin adeudos vencidos), el control de stock de variantes de equipo (tallas de dobok, petos, espinilleras) y la generación de folios de tickets son reglas críticas donde un error matemático cuesta dinero y confianza. En `marcador-tkd` (`D-23`), separar el motor en un paquete Dart puro (`core/`) permitió ejecutar ~100 pruebas unitarias en menos de 2 segundos sin depender del SDK de Flutter.
- **Opciones:**
  1. **Dos paquetes en el proyecto: `core/` (Dart puro, cero dependencias de Flutter ni de Supabase) y `app/` (Flutter UI + Drift + Supabase + Impresión).**
  2. **Monolito dentro de `app/lib/`** mezclando widgets, llamadas a Supabase y cálculos financieros.
- **Decisión:** **Opción 1 — Paquete `core/` en Dart puro para el motor financiero, académico y de inventario, consumido por `app/`.**
- **Consecuencias:**
  - 100% de las reglas financieras (descuentos, recargos, abonos, folios), de elegibilidad de exámenes y de inventario se prueban con `dart test` en milisegundos.
  - Cero lógica de cobro duplicada entre la vista de recepción en Windows y la vista de estado de cuenta en Android.
  - Cualquier cambio en reglas de negocio pasa por pruebas deterministas con reloj inyectado (`Clock`) antes de tocar la base de datos o la interfaz.

---

## 2026-11-23 · D-10 · Roles y permisos (RBAC en RLS y UI) — **Decidido: 4 roles (`dueno`, `recepcion`, `instructor`, `tutor`) con principio de mínimo privilegio**
- **Contexto:** En una academia trabajan distintas personas: el Maestro/Dueño (que necesita control total y reportes de ingresos), la persona de Recepción (que cobra en caja e inscribe alumnos, pero no debe poder borrar pagos pasados para ocultar un faltante de efectivo ni exportar la base completa de clientes), el Instructor o Sabonim auxiliar (que pasa asistencia con QR y captura calificaciones de examen en el tatami, pero no tiene por qué ver cuánto factura la academia) y el Padre/Tutor (que solo debe ver a sus hijos).
- **Opciones:**
  1. **RBAC estricto de 4 roles (`dueno`, `recepcion`, `instructor`, `tutor`) aplicado tanto en políticas RLS de PostgreSQL como en la navegación de la UI.**
  2. **Solo 2 roles (`admin` y `padre`)**, dando acceso total al personal de la academia.
- **Decisión:** **Opción 1 — 4 roles con permisos granulares y bitácora de auditoría inmutable (`bitacora_auditoria`):**
  - **`dueno`:** acceso total a configuración de la academia, finanzas, corte de caja, cancelación de tickets (con motivo obligatorio registrado en auditoría), gestión de personal y derechos ARCO.
  - **`recepcion`:** alta/edición de alumnos y tutores, cobro en caja, emisión e impresión de tickets, corte de caja del turno, entrega de pedidos de equipo e inscripción a exámenes/torneos. **No puede** borrar pagos ni eliminar alumnos; toda cancelación requiere autorización o queda marcada con usuario, fecha y motivo en la bitácora.
  - **`instructor`:** pase de asistencia (manual o por escaneo QR), consulta de progreso técnico y elegibilidad de alumnos de sus grupos, evaluación de exámenes de grado y pesaje/lista de torneos. **Sin acceso** a ingresos totales, cortes de caja ni configuración financiera.
  - **`tutor`:** lectura de estados de cuenta, descarga/compartición de tickets PDF, carnet QR de asistencia, historial de cintas, inscripción/solicitud de equipo, exámenes y torneos exclusivamente de sus hijos vinculados en `tutor_alumnos`.
- **Consecuencias:**
  - Evita fugas de efectivo en recepción (ningún ticket pagado puede "desaparecer"; solo se puede emitir una cancelación auditable que afecta el corte del día).
  - Protege la privacidad financiera del dueño frente a instructores por hora y cumple la minimización de acceso a datos personales de menores exigida por la LFPDPPP.

---

## 2026-11-23 · D-11 · Almacenamiento seguro y privacidad por diseño (LFPDPPP 2025) — **Decidido: Minimización de datos, buckets privados y herramientas ARCO integradas**
- **Contexto:** La aplicación maneja datos personales de **menores de edad** (nombre, fecha de nacimiento para categoría de edad, grado de cinta, historial de asistencia y, opcionalmente, fotografía para credencial y nota de alergias o lesión deportiva relevante para el entrenamiento). Conforme a la **LFPDPPP vigente en México** y la skill `privacidad-mx`, la academia es el **Responsable** del tratamiento y CUPA actúa como **Encargado** (proveedor tecnológico SaaS), debiendo garantizar medidas técnicas de seguridad, consentimiento expreso del tutor y mecanismos sencillos para ejercer derechos ARCO.
- **Opciones:**
  1. **Privacidad por diseño**:
     - Tokens de sesión guardados en `flutter_secure_storage` (DPAPI/Credential Manager en Windows, EncryptedSharedPreferences/Keystore en Android, Keychain en iOS).
     - Fotos de perfil y comprobantes de pago en **buckets privados de Supabase Storage** con acceso únicamente mediante **URLs firmadas temporales** (expiración corta) validadas por RLS.
     - Datos médicos/alergias marcados como **opcionales**, acotados a "Observaciones deportivas/alergias para emergencia en clase" y con casilla de consentimiento expreso separada firmada por el tutor en `consentimientos_legales`.
     - Funciones integradas en el panel del dueño para **Exportar expediente (Portabilidad/Acceso ARCO en JSON/PDF)** y **Eliminar/Anonimizar expediente (Cancelación ARCO)** conservando únicamente los folios contables anonimizados que la ley fiscal/mercantil exija a la academia.
  2. **Buckets públicos para fotos y borrado solo manual por soporte técnico**.
- **Decisión:** **Opción 1 — Almacenamiento cifrado, buckets privados con URLs firmadas, consentimiento granular de tutores y módulo ARCO integrado.**
- **Consecuencias:**
  - Ninguna foto de un menor ni comprobante de pago queda expuesto en una URL pública adivinable o indexable.
  - Si un padre solicita a la academia ejercer sus derechos ARCO (Acceso, Rectificación, Cancelación u Oposición), el dueño de la academia puede resolverlo en 2 clics desde la app sin intervención manual de ingeniería de CUPA.
  - Facilita la aprobación en la revisión de "Seguridad de los datos" y políticas de familias/datos personales de Google Play Store.

---

## 2026-11-23 · D-12 · Integración futura con el ecosistema CUPA sin acoplar código — **Decidido: Intercambio por archivo estándar JSON/CSV de inscripciones a torneos**
- **Contexto:** `CLAUDE.md` establece una regla inquebrantable: *"Los proyectos son independientes: ninguno importa código, datos ni configuración de otro"*. Sin embargo, comercialmente es una ventaja enorme que una academia que usa **Cupa Dojang** para inscribir y cobrar a sus 30 competidores de un torneo interclub pueda exportar esa lista lista para importarse en el software de torneos de CUPA o en **Cupa Pocket: Marcador TKD**, sin volver a capturar nombres, pesos, edades y cintas a mano.
- **Opciones:**
  1. **Desacoplamiento total mediante formato de exportación estándar (`cupa-torneo-roster-v1.json` y `.csv`)**: el módulo de Torneos de *Cupa Dojang* exporta un archivo limpio con los alumnos inscritos y pagados al torneo (`nombre_display`, `club`, `rama`, `fecha_nacimiento`/`edad`, `peso_kg`, `grado_cinta`, `modalidad`: Kyorugi / Poomsae).
  2. **Compartir la misma base de datos de Supabase o importar paquetes Dart entre carpetas de proyecto** (prohibido por `CLAUDE.md`).
- **Decisión:** **Opción 1 — Exportación de lista de competidores en CSV y JSON estándar auto-contenido, manteniendo repositorios, bases de datos y despliegues 100% independientes.**
- **Consecuencias:**
  - Cumple al 100% la regla de independencia de proyectos de `CLAUDE.md`.
  - El archivo CSV sirve de inmediato para **cualquier** torneo externo (incluso si el organizador usa Excel), mientras que el JSON/CSV permite carga instantánea en las herramientas del ecosistema CUPA.
  - Crea un puente comercial natural (venta cruzada entre *Cupa Dojang* y *Cupa Pocket*) sin deuda técnica ni acoplamiento.

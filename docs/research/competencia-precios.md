# Estudio de mercado, competencia y precios: Software de gestión para academias de Taekwondo (Mi Doyang by Cupa)

- **Fecha del estudio:** 23 de noviembre de 2026 (`2026-11-23`)
- **Proyecto:** `gestion-academias` (**Mi Doyang by Cupa**)
- **Autor:** Agente `investigador`
- **Alcance:** Software de administración escolar, cobros, control de grados (Geup/Poom/Dan), asistencia, venta de equipo, exámenes y torneos para academias (*dojangs*) de Taekwondo en México, frente a alternativas en EE. UU. y Latinoamérica.

> **Convención metodológica:** Conforme a las reglas de investigación del espacio CUPA, cada afirmación se clasifica explícitamente como **[Hecho]** (dato verificable en fuente pública), **[Estimación]** (cálculo o conversión cambiaria aproximada; tipo de cambio de referencia ~MXN 20.00 por USD al 23 de noviembre de 2026) u **[Opinión / Análisis]** (interpretación estratégica o recomendación comercial). Se señala de forma explícita cuando la fuente citada es un **proveedor con interés comercial** (sitio oficial del competidor o comparador afiliado).

---

## 1. Resumen ejecutivo

1. **[Conclusión principal — Opinión / Análisis]** El mercado mexicano de academias de Taekwondo (*dojangs*) se encuentra desatendido por el software actual: las plataformas especializadas en artes marciales de Estados Unidos (**Kicksite**, **Spark Membership**, **Gymdesk**, **Zen Planner**) están en inglés, cobran en dólares entre **US$49 y US$348+/mes** (**[Estimación]** ~MXN 1,000 a 7,000/mes) y están diseñadas para procesadores de pago estadounidenses (ACH/tarjetas domiciliadas en USD).
2. **[Hecho / Análisis]** Por otro lado, los sistemas mexicanos y latinoamericanos para gimnasios (**BoxMagic**, **Membrix**, **Gym&i**, **Thanos/Sopvi**), aunque ofrecen precios accesibles en moneda local (**[Hecho]** entre MXN 399 y MXN 1,499/mes), están orientados a centros de *fitness*, CrossFit o gimnasios de pesas. No modelan el ciclo operativo y pedagógico real de un dojang de Taekwondo: progresión de grados **10.º Geup a 1.º Geup y Poom/Dan**, organización de **exámenes de grado con sinodal**, control de pagos mixtos (efectivo en recepción con ticket térmico + transferencia SPEI), venta de equipo reglamentario (*dobok*, petos, espinilleras, empeineras) y registro de competidores a **torneos** con peso, rama, categoría y grado.
3. **[Diagnóstico de adopción — Opinión / Análisis]** El verdadero competidor en más del 85 % de los dojangs en México no es otro SaaS, sino la combinación de **libreta de asistencia + hojas de Excel + grupos de WhatsApp + talonarios de recibos de papelería**. Cualquier solución que no sea más rápida que anotar un pago en libreta en hora pico (16:00 a 21:00 h) o que falle cuando se cae el internet del local será abandonada por la recepción.
4. **[Oportunidad para Mi Doyang by Cupa — Opinión / Análisis]** Existe una brecha clara para **Mi Doyang by Cupa** con una arquitectura híbrida **Windows (recepción *offline-first* con impresora térmica de tickets) + Android/iOS (app para padres/alumnos y profesor en tatami)** y precios en pesos mexicanos con IVA incluido entre **MXN 499 y MXN 1,299/mes**, posicionándose por debajo de cualquier software extranjero de artes marciales y entregando valor específico de Taekwondo que los sistemas de gimnasio generalistas no cubren.

---

## 2. Hallazgos

### 2.1. Panorama de software de gestión para artes marciales y gimnasios (EE. UU., LatAm y México)

#### A. Plataformas especializadas en artes marciales (EE. UU. e internacional)

1. **Kicksite** (EE. UU. — especializado en artes marciales)
   - **Precios publicados:** Estructura escalonada por alumnos activos:
     - 0 a 25 alumnos activos: **US$49/mes** (**[Hecho]** — Fuente: [kicksite.com/pricing](https://kicksite.com/pricing) y [studiosoftwareadvice.com](https://www.studiosoftwareadvice.com/), consultado el 2026-11-23; *nota: Kicksite es proveedor con interés comercial y Studio Software Advice es un portal comparador con enlaces de afiliado*).
     - 26 a 50 alumnos activos: **US$99/mes** (**[Hecho]**, misma fuente).
     - 51 a 100 alumnos activos: **US$149/mes** (**[Hecho]**, misma fuente).
     - 101+ alumnos activos: **US$199/mes** (**[Hecho]**, misma fuente).
     - Equivalencia cambiaria: **[Estimación]** ~**MXN 1,000 a MXN 4,000/mes** según el escalón.
   - **Fortalezas:** **[Hecho]** Incluye seguimiento de cintas y requisitos de promoción, control de asistencia por kiosco, agrupación familiar de cuentas y facturación recurrente (Fuente: [kicksite.com](https://kicksite.com/), consultado el 2026-11-23; *proveedor con interés comercial*).
   - **Limitaciones para México:** **[Hecho / Opinión / Análisis]** Interfaz y soporte en inglés; pasarelas de cobro centradas en EE. UU. (ACH y tarjetas con procesador propio en USD); no maneja emisión de comprobantes en español para padres ni flujo de caja en efectivo con impresora térmica local y SPEI.

2. **Spark Membership** (EE. UU. — artes marciales y CRM de ventas)
   - **Precios publicados:** **[Hecho]** Tarifa plana entre **US$199 y US$249/mes** según el plan y complementos de automatización (**[Estimación]** ~**MXN 4,000 a MXN 5,000/mes**) (Fuente: [sparkmembership.com](https://sparkmembership.com/) y comparativa en [pushpress.com](https://www.pushpress.com/), consultado el 2026-11-23; *nota: ambos son proveedores de software con interés comercial directo*).
   - **Fortalezas:** **[Hecho]** Muy robusto en embudos de captación de prospectos (*leads*), automatización de marketing por SMS/correo y aplicación móvil para miembros (Fuente: [sparkmembership.com](https://sparkmembership.com/), consultado el 2026-11-23; *proveedor con interés comercial*).
   - **Limitaciones para México:** **[Opinión / Análisis]** Su costo mensual equivale a la colegiatura completa de 5 a 8 alumnos de un dojang promedio en México; además está íntegramente en inglés y pensado para academias estadounidenses con tickets promedio de US$150–250/mes por alumno.

3. **Zen Planner / Mindbody** (EE. UU. — *fitness* general y estudios)
   - **Precios publicados:** **[Hecho]** Rango de **US$99 a US$348+/mes** según módulos y tamaño (**[Estimación]** ~**MXN 2,000 a MXN 7,000+/mes**) (Fuentes: [mindbodyonline.com/business/pricing](https://www.mindbodyonline.com/business/pricing) y comparativa en [gymdesk.com](https://gymdesk.com/), consultado el 2026-11-23; *nota: ambos son proveedores con interés comercial*).
   - **Limitaciones para Taekwondo:** **[Hecho]** **Mindbody** está diseñado para estudios de yoga, pilates y *fitness*; no cuenta con seguimiento nativo de cintas/grados (sistema Geup/Dan) ni gestión de exámenes de Taekwondo con sinodal (Fuente: [mindbodyonline.com](https://www.mindbodyonline.com/) y análisis comparativo en [gymdesk.com/blog](https://gymdesk.com/blog/), consultado el 2026-11-23; *Gymdesk es competidor con interés comercial*). **Zen Planner** tiene funciones para artes marciales, pero su costo en dólares y complejidad lo alejan del dojang mexicano independiente (**[Opinión / Análisis]**).

4. **Gymdesk** (EE. UU. — artes marciales y gimnasios de combate)
   - **Precios publicados:** **[Hecho]** Planes desde **US$75/mes** (hasta 50 miembros; sube a US$100–200/mes conforme crece la matrícula), equivalente a **[Estimación]** ~**MXN 1,500/mes** en su escalón de entrada (Fuente: [gymdesk.com/pricing](https://gymdesk.com/pricing), consultado el 2026-11-23; *proveedor con interés comercial*).
   - **Fortalezas y limitaciones:** **[Hecho]** Buen soporte de cintas, promociones y asistencia moderna, pero **[Hecho]** opera en inglés y cobra en dólares estadounidenses, sin adaptación al flujo de efectivo/SPEI ni terminología de dojangs mexicanos (Fuente: [gymdesk.com](https://gymdesk.com/), consultado el 2026-11-23).

5. **MatGoat** (Hispanohablante — artes marciales y deportes de contacto)
   - **Precios publicados:** **[Hecho]** Planes desde **US$40/mes** (**[Estimación]** ~**MXN 800/mes** para academias de hasta 50 alumnos) (Fuente: [matgoat.com](https://matgoat.com/), consultado el 2026-11-23; *proveedor con interés comercial*).
   - **Fortalezas y limitaciones:** **[Hecho]** Está en español, incluye control de grados (adaptable a Geup/Dan) y modo kiosco de asistencia (Fuente: [matgoat.com](https://matgoat.com/), consultado el 2026-11-23). **[Opinión / Análisis]** Sin embargo, su diseño nace muy enfocado en academias de Brazilian Jiu-Jitsu (BJJ) y operación 100 % web dependiente de conexión continua a internet, sin aplicación nativa de escritorio Windows con impresión térmica *offline* para recepción ni integración con logística de torneos de Taekwondo en México.

#### B. Alternativas en México y Latinoamérica (software para gimnasios y centros deportivos)

1. **BoxMagic** (Chile / México — CrossFit y centros *fitness*)
   - **Precios publicados en México:** **[Hecho]** Plan Starter alrededor de **~MXN 999/mes** y Plan Growth alrededor de **~MXN 1,499/mes** (Fuente: [boxmagicapp.com](https://boxmagicapp.com/), consultado el 2026-11-23; *proveedor con interés comercial*).
   - **Evaluación para Taekwondo:** **[Hecho / Análisis]** Es fuerte en reserva de clases por horario (*WODs*/cupos) y cobros recurrentes en Latinoamérica (Fuente: [boxmagicapp.com](https://boxmagicapp.com/), consultado el 2026-11-23). **[Opinión / Análisis]** Es débil para Taekwondo porque no gestiona el expediente marcial del alumno (historial de exámenes de grado 10.º Geup a Dan, actas de sinodal, venta de *dobok*/equipo de combate por talla, ni inscripción por peso/división a torneos).

2. **Membrix y Gym&i** (México — control de gimnasios)
   - **Precios publicados en México:** **[Hecho]** Planes alrededor de **~MXN 799/mes** en México (Fuentes: [membrix.mx](https://membrix.mx/) y [gymni.mx](https://gymni.mx/), consultados el 2026-11-23; *ambos son proveedores con interés comercial*).
   - **Evaluación para Taekwondo:** **[Hecho]** Resuelven bien el control de acceso por código QR, recordatorios de vencimiento de mensualidad y registro básico de ingresos (Fuentes: [membrix.mx](https://membrix.mx/), [gymni.mx](https://gymni.mx/), consultados el 2026-11-23). **[Opinión / Análisis]** No obstante, tratan al alumno como un "socio de gimnasio" individual (sin estructura de padre/tutor con varios hijos menores de edad ni seguimiento de grados marciales, exámenes o torneos).

3. **Thanos / Sopvi** (México — software básico para gimnasios y dojos)
   - **Precios publicados en México:** **[Hecho]** Alrededor de **~MXN 399/mes** en México (Fuente: [sopvi-thanos.com](https://sopvi-thanos.com/), consultado el 2026-11-23; *proveedor con interés comercial*).
   - **Evaluación para Taekwondo:** **[Hecho / Opinión / Análisis]** Es la alternativa local de menor precio para control básico de membresías y entradas, pero carece de experiencia móvil moderna para padres de familia (iOS/Android), gestión integral de exámenes de cinta, tienda de equipo por tallas y conexión con torneos de Taekwondo.

#### C. El verdadero competidor en México: Libreta + Excel + WhatsApp + Talonario

- **[Opinión / Análisis basado en observación de campo]** En la práctica, el competidor dominante en los dojangs mexicanos es el flujo manual:
  1. **Talonario de recibos de papelería o libreta** para anotar quién pagó en efectivo en recepción.
  2. **Archivo de Excel** (casi siempre desactualizado) con la lista de alumnos y sus cintas.
  3. **Grupos y chats individuales de WhatsApp** donde los padres envían capturas de pantalla de transferencias SPEI, preguntan cuánto cuesta el examen o el peto, y reciben avisos de torneos que se pierden entre decenas de mensajes.
- **[Implicación competitiva — Opinión / Análisis]** El costo monetario de este flujo manual es cercano a MXN 0/mes, pero su **costo oculto** para el maestro/dueño del dojang es altísimo: fuga de entre 10 % y 20 % de colegiaturas atrasadas por vergüenza o desorden al cobrar, pérdida de horas conciliando capturas de SPEI por WhatsApp, y errores en las listas de grados y pesos antes de cada examen o torneo.

---

### 2.2. Tabla comparativa del mercado

| Plataforma | Origen / Idioma | Especialización en TKD (Geup/Dan, exámenes, torneos) | App para padres / alumnos | Recepción Windows *Offline* + Ticket térmico | Precio mensual (USD / MXN est.) | Fuente y fecha de consulta |
|---|---|---|---|---|---|---|
| **Kicksite** | EE. UU. / Inglés | Media-Alta (cintas y promociones, sin torneos MX) | Sí (en inglés) | No (Web en la nube) | **[Hecho]** US$49–199/mes (**[Est.]** ~MXN 1,000–4,000) | [kicksite.com](https://kicksite.com/) / [studiosoftwareadvice.com](https://www.studiosoftwareadvice.com/) (2026-11-23) *Proveedor/Afiliado* |
| **Spark Membership** | EE. UU. / Inglés | Media (cintas + CRM fuerte, sin torneos MX) | Sí (en inglés) | No (Web en la nube) | **[Hecho]** US$199–249/mes (**[Est.]** ~MXN 4,000–5,000) | [sparkmembership.com](https://sparkmembership.com/) / [pushpress.com](https://www.pushpress.com/) (2026-11-23) *Proveedores* |
| **Zen Planner / Mindbody** | EE. UU. / Inglés | Baja (Mindbody no soporta Geup/Dan ni exámenes) | Sí | No | **[Hecho]** US$99–348+/mes (**[Est.]** ~MXN 2,000–7,000+) | [mindbodyonline.com](https://www.mindbodyonline.com/) / [gymdesk.com](https://gymdesk.com/) (2026-11-23) *Proveedores* |
| **Gymdesk** | EE. UU. / Inglés | Media-Alta (soporte de cintas y asistencia) | Sí (en inglés) | No (Web) | **[Hecho]** Desde US$75/mes (**[Est.]** ~MXN 1,500+) | [gymdesk.com](https://gymdesk.com/) (2026-11-23) *Proveedor* |
| **MatGoat** | LatAm-Esp / Español | Media (grados Geup/Dan y kiosco; foco BJJ/web) | Web / PWA | No (100 % web) | **[Hecho]** Desde US$40/mes (**[Est.]** ~MXN 800 hasta 50 alumnos) | [matgoat.com](https://matgoat.com/) (2026-11-23) *Proveedor* |
| **BoxMagic** | Chile-MX / Español | Baja (enfocado en CrossFit/multideporte) | Sí | No | **[Hecho]** ~MXN 999–1,499/mes | [boxmagicapp.com](https://boxmagicapp.com/) (2026-11-23) *Proveedor* |
| **Membrix / Gym&i** | México / Español | Baja (asistencia QR y cobro de gimnasio) | Sí (básica) | Parcial / Web | **[Hecho]** ~MXN 799/mes | [membrix.mx](https://membrix.mx/) / [gymni.mx](https://gymni.mx/) (2026-11-23) *Proveedores* |
| **Thanos / Sopvi** | México / Español | Baja (control básico de gimnasio/dojo) | Limitada | Escritorio básico | **[Hecho]** ~MXN 399/mes | [sopvi-thanos.com](https://sopvi-thanos.com/) (2026-11-23) *Proveedor* |
| **Libreta + Excel + WhatsApp** | Manual / Español | Nula (todo se reconstruye a mano en cada examen) | No (mensajes sueltos en WhatsApp) | Talonario en papel | **[Hecho]** MXN 0/mes (alto costo en fugas de cobro) | Observación de mercado (2026-11-23) |
| **Mi Doyang by Cupa (Propuesta)** | **México / Español MX** | **Alta (10.º Geup a Dan, exámenes con sinodal, equipo, torneos CUPA)** | **Sí (Android / iOS para padres)** | **Sí (Windows *offline-first* + ticket 58/80 mm y WhatsApp)** | **[Propuesta]** **MXN 499 a MXN 1,299/mes (IVA incl.)** | Diseño de producto CUPA (2026-11-23) |

---

### 2.3. Análisis de las brechas del mercado mexicano para dojangs de Taekwondo

#### Brecha 1: Operación real en la recepción del dojang (Windows + impresora térmica + internet inestable)
- **[Opinión / Análisis de operación en campo]** En la mayoría de los dojangs mexicanos, la recepción opera con una **PC o laptop con Windows** conectada a una **impresora térmica USB o Bluetooth de 58 mm u 80 mm** (o bien envía comprobantes en PDF/imagen por WhatsApp).
- **[Opinión / Análisis]** La hora crítica del dojang es de **16:00 a 21:00 h**, cuando coinciden los cambios de clase de niños y juveniles, la toma de asistencia en el tatami y la fila de padres pagando colegiaturas, uniformes o inscripciones a examen. En ese horario, la conexión Wi-Fi del local suele saturarse o caer.
- **[Consecuencia]** Los sistemas 100 % web (como Kicksite, MatGoat o BoxMagic) se bloquean cuando falla el internet en plena fila de cobro. Un software ganador en México necesita **modo *offline-first* en Windows**: cobrar en efectivo o registrar transferencia, imprimir el ticket térmico al instante y sincronizar con la nube en cuanto vuelva la red.

#### Brecha 2: La experiencia de los padres de familia en el celular (Android / iOS)
- **[Opinión / Análisis]** En un dojang de Taekwondo en México, entre el **70 % y el 85 % del alumnado son menores de edad (niños y adolescentes)**. Quien paga, compra el equipo y autoriza exámenes o torneos no es el alumno, sino la madre, el padre o el tutor.
- **[Necesidad detectada — Opinión / Análisis]** Los padres de familia quieren una **app móvil sencilla en Android e iOS** (con una sola cuenta familiar para ver a 1, 2 o 3 hijos) donde puedan:
  1. Ver de inmediato si la **mensualidad del mes ya quedó pagada** o si tienen adeudo/recargo, y **descargar su ticket o comprobante** sin tener que pedirlo por WhatsApp.
  2. Consultar **qué cinta/grado tiene su hijo** (ej. *Cinta Amarilla Avanzada — 7.º Geup*), cuántas asistencias lleva y **qué requisitos le faltan para su próximo examen de grado**.
  3. Ver el catálogo y precios del **equipo reglamentario** (*dobok*, peto, careta, espinilleras, empeineras, bucal, concha) por talla, apartarlo o pagarlo.
  4. Enterarse de la convocatoria al próximo **examen de grado o torneo**, confirmar asistencia, registrar el peso actual y pagar la cuota de inscripción sin que la información se pierda en el historial de un grupo de WhatsApp de 120 padres.

#### Brecha 3: Desajuste funcional y de precio de los sistemas actuales
- **[Hecho / Análisis]** Los sistemas extranjeros cuestan entre **MXN 1,500 y MXN 5,000/mes**, están en inglés y asumen que el 100 % de las familias domicilian una tarjeta de crédito en dólares. En México, gran parte de los pagos en academias deportivas se realizan en **efectivo en recepción** o por **transferencia SPEI**, y las familias exigen confirmación inmediata de su pago.
- **[Opinión / Análisis]** Los sistemas mexicanos para gimnasios (MXN 399 a 1,499/mes) resuelven la moneda local, pero ignoran por completo la lógica del Taekwondo:
  - **Escalafón de grados:** Progresión desde **10.º Geup (Cinta Blanca)** hasta **1.º Geup (Cinta Roja/Negra)**, y distinción entre **Poom** (cinta negra infantil/juvenil menor de 15 años) y **Dan** (cinta negra adulto), junto con tiempos mínimos de permanencia y clases requeridas entre grados.
  - **Exámenes de grado con sinodal:** Creación de un evento de examen, lista de candidatos elegibles por asistencia y antigüedad, cobro de derecho de examen (que incluye cuota de sinodal/asociación + certificado + cinta nueva), captura de calificaciones del sinodal (formas/*poomsae*, combate/*kyorugi*, rompimiento, teoría) y promoción masiva automática de grado al aprobar.
  - **Registro a torneos e integración con el ecosistema CUPA:** Preparación de la delegación del dojang con datos exactos para el *bracket* de torneo (nombre, fecha de nacimiento, rama, peso verificado, grado Geup/Dan, modalidad *Kyorugi* o *Poomsae*), lista para exportarse o conectarse directamente con los sistemas de marcador y torneos de **CUPA** (respetando la independencia de código entre proyectos, mediante formatos o APIs estándar).

---

### 2.4. Propuesta de precios sugeridos para Mi Doyang by Cupa (en MXN, IVA incluido)

**[Opinión / Recomendación comercial]** Para maximizar la adopción frente a Excel/libreta y competir con ventaja clara frente a Membrix/Gym&i (~MXN 799/mes), MatGoat (~MXN 800/mes) y BoxMagic (~MXN 999–1,499/mes), se propone un esquema de **precios transparentes en pesos mexicanos con IVA (16 %) ya incluido**, escalonado por el tamaño real de los dojangs en México y con descuento por pago anual (2 meses gratis).

#### Tabla de planes mensuales y anuales — Mi Doyang by Cupa

| Plan | Tamaño de academia (alumnos activos) | Precio mensual (MXN, IVA incluido) | Plan anual (10 meses = 12, IVA incluido) | Perfil de dojang e inclusiones clave |
|---|---|---|---|---|
| **Dojang Inicial** | Hasta **60 alumnos activos** | **MXN $499 / mes** | **MXN $4,990 / año** *(equiv. a $416/mes)* | Ideal para escuelas nuevas o de un solo profesor. Incluye: App Windows de recepción (*offline-first* + impresión de tickets térmicos y envío por WhatsApp), App Android/iOS para padres y alumnos, control de asistencias por QR/lista, control de grados (10.º Geup a Dan), recordatorios de cobro y 1 examen de grado activo a la vez. |
| **Dojang Pro** *(Recomendado)* | Hasta **150 alumnos activos** | **MXN $899 / mes** | **MXN $8,990 / año** *(equiv. a $749/mes)* | El estándar para un dojang consolidado en México. Todo lo de Inicial + **módulo completo de exámenes con sinodal** (actas, calificaciones y promoción automática), **punto de venta e inventario de equipo/dobok por tallas**, **módulo de convocatorias y delegación a torneos** (con exportación compatible con ecosistema CUPA), cuentas familiares multi-hijo ilimitadas y hasta 4 usuarios de staff/profesores. |
| **Dojang Maestro / Multisede** | **151 a 400 alumnos activos** *(o hasta 3 sedes de la misma escuela)* | **MXN $1,299 / mes** | **MXN $12,990 / año** *(equiv. a $1,082/mes)* | Para organizaciones, asociaciones estatales o maestros con sucursales. Todo lo de Pro + **panel consolidado multisede**, gestión de sinodales invitados entre sedes, reportes financieros por sucursal/instructor, roles y permisos avanzados de caja y soporte prioritario por WhatsApp. *(Sedes adicionales >3: +MXN $350/mes por sede).* |

#### Servicios opcionales de arranque y hardware (pago único, IVA incluido)

Para eliminar la principal barrera de entrada tecnológica (el maestro que tiene su lista en Excel o libreta y no tiene tiempo de capturar a 90 alumnos ni configurar la impresora):

| Concepto opcional (Pago único) | Precio sugerido (MXN, IVA incluido) | Qué incluye |
|---|---|---|
| **1. Puesta en marcha y migración ("Llave en mano")** | **MXN $990** *(Gratis al contratar cualquier plan anual)* | Limpieza e importación de la base de datos actual desde Excel/listas en papel (alumnos, tutores, cintas actuales y adeudos), configuración de cuotas/recargos del dojang, personalización con el logotipo de la escuela y capacitación remota de 60 min para el maestro y recepción. |
| **2. Paquete Hardware Recepción CUPA (Impresora térmica + puesta en marcha)** | **MXN $2,490** *(Con envío incluido en México)* | Impresora térmica de tickets de 58 mm o 80 mm (USB + Bluetooth) probada con Mi Doyang by Cupa en Windows y Android + 5 rollos de papel térmico + servicio completo de **"Puesta en marcha y migración"** + configuración remota lista para imprimir el primer recibo con el logo del dojang. |

#### Justificación económica para el dueño del dojang (argumento de venta)
- **[Estimación financiera]** La colegiatura mensual promedio en un dojang mexicano oscila entre **MXN $600 y MXN $1,200 por alumno**.
- **[Análisis de retorno de inversión]** Con recuperar **un solo alumno moroso al mes** que antes se pasaba por alto en la libreta, o con evitar la fuga de cobro en la venta de dos uniformes/exámenes, el plan **Dojang Inicial ($499/mes)** o **Dojang Pro ($899/mes)** se paga solo desde el primer mes.

---

## 3. Implicaciones para el producto (Mi Doyang by Cupa)

De los hallazgos anteriores se desprenden siete decisiones obligatorias de producto y arquitectura para `gestion-academias`:

1. **Arquitectura *Offline-First* en Recepción (Windows) como diferenciador crítico:**
   - La aplicación de escritorio Windows debe almacenar localmente (SQLite/Drift o equivalente sincronizado con Supabase) el padrón de alumnos, tarifas, pagos en efectivo/transferencia y asistencias del día, permitiendo **cobrar e imprimir tickets térmicos de 58/80 mm sin internet** durante la hora pico (16:00–21:00 h) y sincronizar automáticamente al recuperar la conexión.
2. **Modelo de datos centrado en "Familia / Tutor" además de "Alumno":**
   - A diferencia de los sistemas de gimnasio donde cada socio es un adulto independiente, Mi Doyang by Cupa debe permitir que **un padre/madre/tutor sea titular de 1 o varios alumnos (hermanos)**, con estado de cuenta familiar unificado, descuentos por hermanos automatizados y una sola sesión en la app móvil (Android/iOS).
3. **Motor nativo de grados y exámenes de Taekwondo (10.º Geup → 1.º Geup → Poom/Dan):**
   - El sistema debe incluir de fábrica el catálogo configurable de cintas de Taekwondo (Blanca, Blanca Avanzada, Amarilla, Amarilla Avanzada, Verde, Verde Avanzada, Azul, Azul Avanzada, Roja, Roja/Negra, Poom 1.º–3.º y Dan 1.º–9.º), requisitos de asistencias mínimas por grado, generación de lista de convocados a examen, cobro de derecho de examen, hoja de evaluación para el **sinodal** y ascenso automático de cinta con historial perpetuo.
4. **Flujo híbrido de cobros adaptado a México (Efectivo + SPEI + Comprobante en App y WhatsApp):**
   - Antes que forzar pasarelas con comisiones del 3.6 % + IVA que muchos dojangs rechazan absorber, el flujo principal debe hacer ultra rápido:
     - El **cobro en efectivo o tarjeta en terminal física** en recepción con impresión de ticket térmico y envío de recibo digital.
     - La **subida o validación rápida de comprobantes SPEI** desde la app del padre de familia, con aprobación en un clic por parte de recepción y actualización inmediata del estatus a *"Pagado"* en el celular del tutor.
5. **Tienda de equipo marcial y gestión de tallas (*Dobok* y protecciones):**
   - Incluir un punto de venta simple con control de inventario y pedidos a proveedor por tallas (ej. *Dobok* talla 000 a 6, petos electrónicos o convencionales #1 a #5, caretas, espinilleras, empeineras) y posibilidad de manejar **pagos en abonos/apartados**, práctica muy común en dojangs mexicanos antes de un torneo.
6. **Módulo de Torneos preparado para conectar con el ecosistema CUPA:**
   - Permitir crear una convocatoria de torneo, que los padres inscriban y paguen desde la app, que el profesor valide el **peso real en báscula, altura, rama, fecha de nacimiento, modalidad (*Kyorugi* / *Poomsae*) y grado Geup/Dan**, y que el dojang exporte la cédula oficial de inscripción en formato estándar (CSV/JSON/Excel) compatible con el software de torneos y marcador de **CUPA**.
7. **Cumplimiento de privacidad (LFPDPPP 2025) para datos de menores de edad:**
   - Dado que la mayoría de los alumnos son menores de edad y se registran datos sensibles o físicos (fecha de nacimiento, peso, fotografía, lesiones/alergias básicas para entrenamiento y contacto de emergencia), el flujo de alta del alumno debe recabar el **consentimiento expreso del padre o tutor** con el Aviso de Privacidad del dojang (activando la skill `privacidad-mx`).

---

## 4. Lista de fuentes

Todas las fuentes fueron verificadas o tomadas como referencia de mercado con fecha **23 de noviembre de 2026 (`2026-11-23`)**. Se indica el carácter de cada fuente conforme a `.claude/agents/investigador.md`:

1. **Kicksite** — Sitio oficial y página de precios: [https://kicksite.com/pricing](https://kicksite.com/pricing) (Consultado: 2026-11-23). *Naturaleza de la fuente: Proveedor con interés comercial directo.*
2. **Studio Software Advice** — Directorio y comparativa de precios de software para escuelas de artes marciales (referencia de escalones de Kicksite): [https://www.studiosoftwareadvice.com/](https://www.studiosoftwareadvice.com/) (Consultado: 2026-11-23). *Naturaleza de la fuente: Portal comparador con interés comercial / enlaces de afiliado.*
3. **Spark Membership** — Sitio oficial del software CRM y gestión para artes marciales: [https://sparkmembership.com/](https://sparkmembership.com/) (Consultado: 2026-11-23). *Naturaleza de la fuente: Proveedor con interés comercial directo.*
4. **PushPress** — Comparativas de precios y análisis frente a Spark Membership y software de gimnasios: [https://www.pushpress.com/](https://www.pushpress.com/) (Consultado: 2026-11-23). *Naturaleza de la fuente: Proveedor competidor con interés comercial.*
5. **Mindbody** — Sitio oficial y planes de precios para estudios deportivos: [https://www.mindbodyonline.com/business/pricing](https://www.mindbodyonline.com/business/pricing) (Consultado: 2026-11-23). *Naturaleza de la fuente: Proveedor con interés comercial directo.*
6. **Gymdesk** — Sitio oficial, página de precios para artes marciales y comparativas frente a Mindbody/Zen Planner: [https://gymdesk.com/pricing](https://gymdesk.com/pricing) (Consultado: 2026-11-23). *Naturaleza de la fuente: Proveedor con interés comercial directo.*
7. **MatGoat** — Sitio oficial del software en español para academias de artes marciales y BJJ: [https://matgoat.com/](https://matgoat.com/) (Consultado: 2026-11-23). *Naturaleza de la fuente: Proveedor con interés comercial directo.*
8. **BoxMagic** — Sitio oficial y planes de precios en México (Starter y Growth): [https://boxmagicapp.com/](https://boxmagicapp.com/) (Consultado: 2026-11-23). *Naturaleza de la fuente: Proveedor con interés comercial directo.*
9. **Membrix** — Sitio oficial de software de administración de gimnasios y control de acceso QR en México: [https://membrix.mx/](https://membrix.mx/) (Consultado: 2026-11-23). *Naturaleza de la fuente: Proveedor con interés comercial directo.*
10. **Gym&i (Gymni)** — Sitio oficial de gestión para gimnasios y centros deportivos en México: [https://gymni.mx/](https://gymni.mx/) (Consultado: 2026-11-23). *Naturaleza de la fuente: Proveedor con interés comercial directo.*
11. **Thanos / Sopvi** — Sitio oficial de software mexicano para control de gimnasios y dojos: [https://sopvi-thanos.com/](https://sopvi-thanos.com/) (Consultado: 2026-11-23). *Naturaleza de la fuente: Proveedor con interés comercial directo.*

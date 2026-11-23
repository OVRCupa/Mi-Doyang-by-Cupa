# PRD · Cupa Dojang: Gestión de Academias TKD

**Versión:** 0.1 · **Fecha:** 23 nov 2026 · **Estado:** Borrador para aprobar en compuerta C2  
**Proyecto:** `gestion-academias` · **Plataformas objetivo (v1.0):** Windows (escritorio) + Android (móvil/tablet)

---

## 1. Problema

En México existen miles de academias de Taekwondo (*dojangs* independientes, escuelas afiliadas a asociaciones estatales/FMTKD y agrupaciones con varias sucursales) que operan su administración diaria con herramientas fragmentadas: libretas de asistencia, hojas de Excel sin respaldo, talonarios de recibos en papel llenados a mano y grupos de WhatsApp saturados.

Esta operación manual provoca cuatro dolores críticos y costosos para el dueño del dojang:

1. **Morosidad alta y pérdida de ingresos (15 % a 30 % de retraso en mensualidades):** al no existir recordatorios claros, cálculo automático de recargos ni visibilidad inmediata en el celular del padre, las colegiaturas se atrasan semanas o se vuelven incobrables por fricción personal entre el profesor (*Sabonim*) y las familias.
2. **Descontrol en cobros extraordinarios y abonos (exámenes, uniformes y torneos):** los padres suelen pagar en abonos el *dobok*, el equipo de protección (peto, casco, espinilleras), el derecho a examen de grado o la inscripción a un torneo. En libreta o chats de WhatsApp se pierde el rastro de quién ya liquidó, cuánto resta por pagar y a quién ya se le entregó el equipo.
3. **Fricción por comprobantes extraviados y falta de transparencia con los padres:** los recibos de papel se pierden y los padres piden aclaraciones constantes en recepción o por WhatsApp ("¿cuánto debo?", "¿ya quedó pagado el torneo de mis dos hijos?", "¿cuándo es el próximo examen de cinta?").
4. **Cero trazabilidad del expediente deportivo del alumno:** el historial de ascensos de grado (*Geup* / *Poom* / *Dan*), las asistencias mínimas requeridas para presentar examen, las calificaciones de evaluación y las medallas obtenidas en torneos quedan dispersos o en la memoria del profesor, restando valor percibido y retención a la academia.

---

## 2. Usuarios y contexto de uso

| Usuario | Plataforma principal | Contexto real de uso | Responsabilidades y necesidades clave |
|---|---|---|---|
| **U1. Dueño / Administrador y Recepción** | **App de escritorio Windows** (mostrador) + acceso completo desde **App Android** | Mostrador del dojang en hora pico (16:00 a 21:00 h), con fila de padres pagando al inicio o salida de clase y conexión a internet que puede fallar o ponerse lenta. | • Controlar la caja diaria y hacer corte de caja sin errores.<br>• Cobrar mensualidades, abonos de equipo, exámenes y torneos (efectivo, transferencia SPEI o tarjeta en terminal externa).<br>• Emitir e imprimir al instante **tickets de comprobante de pago** en impresora térmica (58/80 mm) o enviarlos en PDF/imagen por WhatsApp.<br>• Personalizar logo, colores, estructura de cintas, horarios, tarifas, descuentos familiares y recargos.<br>• Administrar inventario de equipo, convocatorias de examen y registros a torneos. |
| **U2. Instructor / Sabonim** | **App Android** (celular o tablet; futuro iOS en v1.2) | En el tatami con 15 a 40 alumnos por clase, de pie, con poco tiempo entre bloques de entrenamiento y sin computadora frente a él. | • Pasar lista en menos de 60 segundos (escaneando el QR del alumno o con toque rápido por grupo/horario).<br>• Ver alertas médicas críticas del alumno en clase (alergias, asma, lesiones).<br>• Consultar qué alumnos cumplen asistencias y tiempo para el próximo examen de grado.<br>• Capturar calificaciones durante el examen (*Poomsae*, *Kyorugi*, rompimiento, teoría) y verificar quién tiene equipo o torneo pagado. |
| **U3. Padre de familia / Tutor (o Alumno mayor de edad)** | **App Android** (celular personal; futuro iOS en v1.2) | En casa, en el trabajo o sentado afuera del tatami; es común que un mismo padre tenga **2 o 3 hijos inscritos** en distintos horarios o grados. | • Entrar con **un solo usuario familiar** y visualizar el perfil de todos sus hijos vinculados.<br>• Consultar estatus de mensualidades, costos, fechas de vencimiento y saldos pendientes.<br>• Ver y descargar en cualquier momento todos sus **tickets de comprobantes de pago** numerados.<br>• Seguir el avance de cintas/grados, asistencias acumuladas e historial de exámenes y torneos.<br>• Explorar el catálogo de equipo del dojang, solicitar uniformes/protecciones por talla e inscribir a sus hijos a exámenes internos y torneos firmando digitalmente la responsiva. |

---

## 3. Propuesta de valor

**Cupa Dojang: Gestión de Academias TKD** convierte la operación artesanal de una escuela de Taekwondo en una academia profesional, ordenada y con identidad propia, conectando el mostrador del dojang (Windows) con el tatami y el bolsillo de los padres de familia (Android).

- **Para el Dueño del Dojang:** elimina fugas de dinero en mensualidades, venta de equipo, exámenes y torneos; entrega tickets de comprobante formales con el logo de su escuela (impresos en térmica o digitales) incluso si se corta el internet (*offline-first*); y profesionaliza la imagen de su academia frente a los padres.
- **Para el Padre de Familia:** brinda tranquilidad y claridad desde una sola cuenta móvil para todos sus hijos, con acceso permanente a sus comprobantes de pago, calendario de exámenes/torneos, pedidos de equipo y progreso deportivo de cada hijo.
- **Diferenciador frente a software genérico de gimnasios:** diseñado desde cero para la realidad del Taekwondo en México (sistema personalizable de grados *10.º Geup* a *Poom/Dan* con cintas intermedias/puntas, cálculo de elegibilidad por asistencias y meses en cinta, evaluación de examen de grado, registro a torneos por peso/modalidad, abonos parciales de equipo y cuentas familiares multi-hijo).

---

## 4. Alcance funcional por módulos y plan de entregas

Para garantizar que el producto cubra **todos los módulos solicitados por el dueño** desde la primera versión comercializable sin retrasar la salida al mercado con integraciones bancarias o fiscales complejas, el alcance se organiza en 6 módulos nucleares en **v1.0 (MVP Comercial)** y evoluciona en **v1.1** y **v1.2**.

### 4.1 Detalle de los 6 módulos del MVP (v1.0 — Windows + Android)

#### M1. Personalización de la Academia
- **Identidad visual y comercial:** nombre del dojang, logotipo, paleta de colores de acento/encabezado de la academia, dirección, teléfono, redes sociales y leyenda configurable al pie del ticket de pago (p. ej. políticas de reembolso o mensaje del *Sabonim*).
- **Catálogo propio de grados y cintas:** configuración flexible de la escalera de grados desde *10.º Geup* (blanca) hasta *Poom* / *Dan* (negra), permitiendo a cada escuela agregar o quitar **cintas intermedias / puntas** (blanca-amarilla, amarilla-verde, azul-roja, rojinegra, etc.) y definir por cada grado: color visual, orden jerárquico, meses mínimos de permanencia, asistencias mínimas requeridas y costo sugerido de examen.
- **Grupos, horarios y tarifas:** creación de clases/horarios (p. ej. "Infantil Principiantes L-M-V 17:00"), asignación de instructor y configuración de reglas financieras: costo de inscripción/anualidad, monto de mensualidad por plan, día de corte/vencimiento, **recargo automático por mora** (monto fijo o porcentaje tras el día límite) y **descuento automático por hermanos/familia** (porcentaje o monto escalonado para 2.º, 3.º o más integrantes).

#### M2. Alumnos, Familias y Usuarios para Padres
- **Cuenta Familiar Unificada (Multi-hijo):** alta de la cuenta del Padre/Tutor (con correo o teléfono verificado) a la que se vinculan uno, dos, tres o más hijos. Desde una sola sesión en la app Android, el padre cambia entre el perfil de cada hijo o ve el estado de cuenta consolidado de la familia. Soporta también alumnos mayores de edad con cuenta propia.
- **Expediente integral del alumno:** datos básicos, fotografía opcional, fecha de nacimiento, peso actual (para torneos), grupo/horario asignado, cinta actual, fecha de último ascenso, conteo de asistencias desde el último examen y **alerta médica opcional** (tipo de sangre, alergias, condiciones relevantes y contacto de emergencia) protegida bajo consentimiento expreso del tutor.
- **Asistencia con QR y pase rápido:** generación de credencial digital con código QR único por alumno (visible en la app del padre e imprimible desde Windows). Pase de lista en el tatami desde Android mediante escaneo de QR o lista táctil rápida por clase.

#### M3. Caja, Cobros, Mensualidades y Tickets de Comprobante
- **Caja en recepción (*Offline-first* en Windows y Android):** registro de cobros por concepto de mensualidad, inscripción, examen de grado, equipo/uniforme o torneo. Soporta métodos de pago: efectivo, transferencia SPEI (con captura de referencia/clave de rastreo) y tarjeta en terminal física externa (con número de autorización).
- **Motor de mensualidades y abonos parciales:** cálculo automático del total a pagar aplicando descuento familiar por hermanos y recargos por pago tardío (con opción de condonación autorizada solo por el rol Dueño). Soporte de **abonos parciales** para conceptos de mayor valor (uniformes, equipo, exámenes o torneos), manteniendo el saldo pendiente visible para recepción y para el padre.
- **Ticket de comprobante de pago numerado:** cada cobro o abono genera un **Ticket de Comprobante de Pago** inmutable con:
  - Folio consecutivo único por academia (p. ej. `DOJ-2026-000142`), fecha/hora, nombre del dojang y logotipo.
  - Datos del alumno y familia, desglose de conceptos, descuentos/recargos, monto pagado, saldo restante (si fue abono), método de pago y cajero que recibió.
  - **Código QR de verificación** para validar autenticidad del recibo desde la app.
  - **Salidas inmediatas:** impresión directa en impresora térmica de 58 mm u 80 mm en Windows, generación de PDF/imagen lista para compartir por WhatsApp y aparición instantánea en la sección "Mis Comprobantes" de la app Android del padre (sincronizando en cuanto haya red si se cobró sin internet).
- **Corte de caja diario:** resumen de ingresos por método de pago y por categoría (mensualidades, equipo, exámenes, torneos), con registro de apertura, cierre y arqueo de efectivo.

#### M4. Grados y Exámenes Internos
- **Convocatoria de examen:** alta de fecha, hora, sede, sinodal/examinador invitado y costos de derecho a examen según el grado al que aspira el alumno.
- **Filtro automático de elegibilidad:** semáforo que clasifica a los alumnos en *Elegibles* o *Con pendientes* cruzando tres criterios configurables por la academia: asistencias acumuladas en el grado actual, tiempo mínimo desde el último examen y mensualidad al corriente (con posibilidad de autorización manual del *Sabonim*).
- **Inscripción y evaluación:** publicación de la convocatoria en la app del padre para confirmar participación (con responsiva digital), cobro del derecho a examen en M3 y tablero de evaluación para el *Sabonim* (calificación o aprobación en *Poomsae*, *Kyorugi*, rompimiento y teoría).
- **Ascenso automático:** al cerrar el acta del examen, los alumnos aprobados ascienden automáticamente a su nueva cinta, se reinicia el contador de asistencias del nuevo grado, se registra el certificado/historial en su expediente y el padre visualiza el nuevo grado en su app Android.

#### M5. Equipo e Inventario del Dojang
- **Catálogo personalizable:** alta de artículos del dojang (*doboks* por modelo, petos, cascos, espinilleras, antebrazos, guantes, protectores bucales, coquillas, cintas bordadas) con variantes de talla, precio de venta, stock disponible y alerta de inventario bajo.
- **Solicitudes desde la app del padre y venta en mostrador:** el padre puede consultar el catálogo y precios desde su celular y solicitar/apartar una prenda o equipo para su hijo; recepción recibe el pedido, registra el pago total o abono en M3 y controla el estado operativo de cada artículo: **`Pagado` / `Con adeudo`** y **`Pendiente de entregar` / `Entregado`** (evitando entregar equipo que no ha sido liquidado o olvidar entregas de pedidos sobre encargo).

#### M6. Registros Internos a Torneos
- **Alta de torneo en la academia:** creación de evento (torneo interno, dual meet, copa por invitación o selectivo oficial) con fecha del evento, sede, fecha límite de inscripción, cuota de registro y modalidades disponibles (*Kyorugi* / Combate, *Poomsae* / Formas, Rompimiento, TK-5).
- **Inscripción con datos técnicos y responsiva:** registro del alumno indicando modalidad, categoría de edad, cinta actual y división de peso (kg). El padre de familia puede revisar la convocatoria en su app Android, inscribir a su hijo y aceptar digitalmente la **carta responsiva / permiso de participación** con marca de tiempo.
- **Control de pago y medallero:** vinculación con caja (M3) para saber qué competidores ya pagaron su cuota de torneo antes del cierre de listas, exportación de la lista de inscritos de la academia (CSV/Excel para entregar al organizador del torneo) y captura posterior del resultado obtenido (Oro, Plata, Bronce, Participación) que queda guardado en el historial deportivo del alumno visible para el padre.

---

### 4.2 Mapa de versiones (v1.0 vs v1.1 vs v1.2)

| Fase | Alcance incluido | Objetivo comercial |
|---|---|---|
| **v1.0 (MVP Comercial)**<br>*Windows + Android* | • **M1:** Personalización de academia, catálogo propio de cintas/puntas, horarios, descuentos familiares y recargos.<br>• **M2:** Alumnos, cuenta familiar multi-hijo para padres en Android, expediente con alerta médica y pase de lista con QR.<br>• **M3:** Caja *offline-first* en Windows/Android, mensualidades, abonos y **Tickets de comprobante** (impresión térmica 58/80 mm + PDF/WhatsApp + bandeja en app del padre).<br>• **M4:** Convocatoria de exámenes internos, filtro de elegibilidad, evaluación y ascenso automático de cinta.<br>• **M5:** Catálogo e inventario de equipo, pedidos desde la app del padre y control de pagos/entregas.<br>• **M6:** Registro interno a torneos con peso/modalidad, responsiva digital del tutor y registro de medallas. | Lanzar piloto sólido y vendible que digitalice el 100 % de la operación del dojang sin depender de comisiones de pasarelas bancarias en el día uno. |
| **v1.1 (Pagos en línea y Push)**<br>*Windows + Android* | • **Pasarela de pago opcional en la app del padre:** integración con Mercado Pago / Stripe para que el padre pague mensualidad, examen, equipo o torneo desde su celular con tarjeta o SPEI referenciado (conciliación automática de ticket).<br>• **Notificaciones Push automatizadas (FCM):** avisos de próximo vencimiento de mensualidad, confirmación de ticket emitido, convocatoria de examen de grado, fecha límite de torneo y aviso de equipo listo para recoger. | Reducir aún más la morosidad permitiendo pago autoservicio 24/7 desde el celular del padre. |
| **v1.2 (iOS, CFDI e Integración CUPA)**<br>*Windows + Android + iOS* | • **App móvil para iOS (iPhone / iPad):** compilada y publicada en App Store desde la misma base de código Flutter para padres e instructores con iPhone.<br>• **Facturación electrónica CFDI 4.0 opcional:** emisión de factura fiscal ante el SAT conectando con un PAC para academias que requieran facturar colegiaturas o equipo.<br>• **Interoperabilidad por archivo con productos CUPA:** exportación estandarizada (JSON/CSV firmado) del listado de competidores inscritos en M6 (nombre, rama, edad, cinta, peso, modalidad) para importarlo directamente en el sistema independiente de llaves y marcador (`marcador-tkd`) sin acoplar bases de datos ni código. | Capturar academias grandes/premium con padres usuarios de iPhone y cerrar el ciclo completo academia → torneo. |

---

## 5. Fuera de alcance (para v1.0)

Para mantener el MVP v1.0 enfocado, estable y rápido de implementar, quedan explícitamente **fuera de la versión 1.0**:

1. **Procesamiento de pagos con tarjeta dentro de la app (pasarela en línea):** en v1.0 los pagos se realizan en recepción o por transferencia bancaria directa a la cuenta del dojang y la recepción los registra para emitir el ticket digital/impreso (la pasarela integrada entra en v1.1).
2. **Timbrado fiscal CFDI 4.0 ante el SAT:** en v1.0 los tickets emitidos son **comprobantes internos de pago del dojang** (con leyenda explícita *"Comprobante interno de control escolar — Este documento no es un comprobante fiscal CFDI"*). La facturación CFDI entra en v1.2.
3. **Publicación en Apple App Store (iOS):** en v1.0 las plataformas oficiales son **Windows** (escritorio) y **Android** (Google Play / APK). Para padres que usen iPhone durante la fase v1.0, el comprobante se les entrega impreso y en formato PDF/imagen por WhatsApp hasta la salida de v1.2.
4. **Armado de gráficas de combate (*brackets*) y puntuación de combates en tiempo real:** esa funcionalidad corresponde a un producto independiente del portafolio CUPA (`marcador-tkd`). En `gestion-academias` el módulo M6 cubre el registro interno de los alumnos de la escuela al torneo, su cobro, su responsiva y su resultado/medalla.
5. **Contabilidad fiscal corporativa, nómina bancaria o tienda pública de comercio electrónico abierta a externos:** el catálogo de equipo (M5) es exclusivo para alumnos y padres registrados en la academia.

---

## 6. Historias de usuario y criterios de aceptación

Todos los criterios están redactados en formato verificable **Dado / Cuando / Entonces** para servir como base directa de pruebas automatizadas y de la `puerta-de-calidad`.

### H1 (M1) · Personalización de la academia, catálogo de cintas y tarifas familiares
- **Como** Dueño de la academia, **quiero** configurar la identidad visual de mi dojang, mi propio orden de cintas (incluyendo puntas/intermedias) y mis reglas de mensualidad, descuentos familiares y recargos **para** que el sistema y los tickets operen exactamente con las reglas y marca de mi escuela.
  - **CA-H1.1 (Identidad y recibo):** **Dado** que el Dueño está en la configuración de la academia en Windows o Android, **cuando** sube el logotipo del dojang (PNG/JPG <= 2 MB), elige el color primario de su escuela, captura el nombre comercial y guarda una leyenda de pie de ticket, **entonces** la interfaz y la vista previa del ticket térmico/PDF muestran inmediatamente el logotipo, colores y datos configurados.
  - **CA-H1.2 (Catálogo personalizable de cintas):** **Dado** el catálogo base de grados (*10.º Geup* a *1.er Dan*), **cuando** el Dueño inserta un grado intermedio personalizado (p. ej. "8.º Geup Avanzado · Amarilla punta verde") asignándole orden jerárquico, meses mínimos de permanencia (p. ej. 3 meses), asistencias mínimas (p. ej. 24 clases) y costo de examen ($650 MXN), **entonces** el grado queda disponible para asignarse a alumnos y el motor de exámenes (M4) utiliza esos parámetros para calcular elegibilidad.
  - **CA-H1.3 (Regla de descuento por hermanos y recargo por mora):** **Dado** que el Dueño configura una mensualidad base de $800 MXN con vencimiento el día 5 de cada mes, un recargo por mora de $80 MXN a partir del día 6 y un descuento familiar del 15 % para el segundo hermano y 25 % para el tercero, **cuando** se generan los cargos mensuales de una familia con 3 hijos activos, **entonces** el sistema calcula automáticamente $800 + $680 + $600 = $2,080 MXN antes del día 5, y suma el recargo configurado únicamente a las mensualidades no pagadas a partir del día 6.

### H2 (M2) · Cuenta familiar multi-hijo y expediente con alerta médica
- **Como** Padre de familia con varios hijos en el dojang, **quiero** tener una sola cuenta de usuario vinculada a todos mis hijos y registrar sus datos de emergencia bajo mi consentimiento **para** consultar su información sin manejar múltiples cuentas ni contraseñas.
  - **CA-H2.1 (Vinculación multi-hijo a un solo tutor):** **Dado** que un Padre de familia ya está registrado en la academia con su hijo menor "Mateo López", **cuando** recepción o el propio padre da de alta a su segunda hija "Sofía López" vinculándola al mismo tutor, **entonces** al iniciar sesión en la app Android con su único usuario, el padre visualiza el selector familiar con ambos hijos ("Mateo" y "Sofía") y un resumen unificado de pagos y avisos de los dos.
  - **CA-H2.2 (Consentimiento expreso para menores y alerta médica):** **Dado** el formulario de alta o actualización de un alumno menor de edad que incluye el campo opcional de alerta médica (p. ej. "Asma leve — usa inhalador"), **cuando** se intenta guardar el expediente sin haber marcado y firmado digitalmente el consentimiento expreso del Padre/Tutor para el tratamiento de datos de menores y datos sensibles de salud (vinculado al Aviso de Privacidad), **entonces** el sistema bloquea el guardado del dato sensible; **y cuando** el tutor otorga el consentimiento, **entonces** el sistema guarda el expediente registrando fecha, hora, versión del aviso e identificador del tutor que consintió.

### H3 (M2) · Pase de lista rápido en tatami (QR y táctil)
- **Como** Instructor (*Sabonim*), **quiero** registrar la asistencia de mi grupo desde mi celular Android escaneando el QR del alumno o con un toque en la lista **para** no perder tiempo de clase y mantener actualizado el conteo de asistencias para examen.
  - **CA-H3.1 (Pase de lista por QR y toque rápido sin internet):** **Dado** que el Instructor abre la clase "Infantil 17:00" en la app Android (incluso sin conexión Wi-Fi en el área del tatami), **cuando** escanea el código QR de un alumno o toca su tarjeta en pantalla, **entonces** se registra la asistencia con fecha y hora en menos de 1 segundo, se incrementa el contador de asistencias del grado actual del alumno, se muestra un indicador visual si el alumno tiene alerta médica o adeudo vencido, y el registro se sincroniza automáticamente con el servidor al recuperar conexión.
  - **CA-H3.2 (Prevención de duplicados en la misma clase):** **Dado** que un alumno ya tiene asistencia registrada en la clase "Infantil 17:00" del día de hoy, **cuando** se vuelve a escanear su QR por error en la misma sesión, **entonces** la app avisa *"Asistencia ya registrada hoy en esta clase"* y no duplica el conteo de asistencias para examen.

### H4 (M3) · Cobro en caja, Ticket de comprobante numerado y sincronización *Offline-first*
- **Como** encargado de Recepción / Dueño en Windows, **quiero** cobrar mensualidades o abonos aunque se caiga el internet y emitir un ticket de comprobante con folio único y QR (impreso y digital) **para** entregar un recibo formal al instante y que aparezca en la app del padre sin perder ningún registro de caja.
  - **CA-H4.1 (Emisión de ticket con folio único, impresión térmica y PDF):** **Dado** un cobro en recepción en Windows por $1,480 MXN (mensualidad de 2 hermanos con descuento familiar aplicado), **cuando** el cajero selecciona el método de pago (p. ej. Efectivo), confirma el cobro y elige "Imprimir y Enviar", **entonces** el sistema registra el pago en la caja diaria, genera un Ticket de Comprobante con folio único inmutable, logo del dojang, desglose de conceptos y código QR de verificación, envía la impresión en formato térmico de 58 mm u 80 mm y genera el archivo PDF/imagen listo para compartir.
  - **CA-H4.2 (Operación *offline-first* y sincronización sin colisión de folios):** **Dado** que la PC con Windows en recepción pierde la conexión a internet en hora pico, **cuando** recepción registra 10 cobros consecutivos, **entonces** la app Windows guarda los cobros en su base de datos local cifrada, imprime los 10 tickets térmicos sin bloqueo con prefijo de terminal/folio único y los marca como `Pendiente de sincronizar`; **y cuando** regresa la conexión a internet, **entonces** sincroniza automáticamente los 10 cobros con la nube en segundo plano sin duplicar cargos ni perder folios, haciéndolos visibles en la app Android de cada padre.
  - **CA-H4.3 (Abonos parciales):** **Dado** un cargo por $1,200 MXN de un *dobok* o examen de grado, **cuando** el padre entrega un anticipo de $500 MXN en caja, **entonces** el sistema emite un ticket de comprobante especificando *"Abono parcial: $500.00 MXN · Saldo pendiente: $700.00 MXN"* y mantiene la cuenta por cobrar abierta por $700 MXN hasta su liquidación.

### H5 (M2/M3) · Vista del Padre en Android: estado de cuenta multi-hijo y descarga de tickets
- **Como** Padre de familia en la app Android, **quiero** ver los pagos pendientes y descargar los tickets de comprobante de todos mis hijos **para** llevar control de mis gastos en la academia sin tener que guardar recibos de papel ni pedir aclaraciones en recepción.
  - **CA-H5.1 (Bandeja de tickets y verificación):** **Dado** que recepción acaba de registrar un pago o abono para cualquiera de los hijos vinculados al Padre, **cuando** el Padre abre la sección "Pagos y Comprobantes" en su app Android, **entonces** visualiza el historial de pagos filtrado por hijo o consolidado por familia, ve el estatus de la mensualidad actual (`Al corriente`, `Por vencer` o `Vencida`) y puede abrir o descargar el **Ticket de Comprobante en PDF/imagen** con el mismo folio, desglose y código QR que el ticket impreso en recepción.

### H6 (M4) · Convocatoria a examen de grado, evaluación y ascenso automático de cinta
- **Como** Dueño / *Sabonim*, **quiero** convocar a examen de grado filtrando quién cumple asistencias y pagos, capturar los resultados de la evaluación y promover automáticamente de cinta a los aprobados **para** que el avance de grados sea justo, ordenado y visible para los padres.
  - **CA-H6.1 (Filtro automático de elegibilidad):** **Dado** que el *Sabonim* crea el "Examen de Grados Diciembre 2026" y el grado *8.º Geup (Amarilla)* exige 24 asistencias y 3 meses de permanencia, **cuando** abre la lista de candidatos, **entonces** el sistema marca automáticamente como `Elegible` al alumno que tiene >= 24 asistencias, >= 3 meses en cinta blanca y mensualidad al corriente, y marca como `No elegible (motivo detallado)` a quien le falten asistencias, tiempo o tenga adeudo vencido.
  - **CA-H6.2 (Evaluación y ascenso automático reflejado en la app del padre):** **Dado** un alumno inscrito al examen con su derecho de examen pagado en M3, **cuando** el *Sabonim* captura sus calificaciones aprobatorias (*Poomsae*, *Kyorugi*, rompimiento, teoría) y cierra el acta del examen, **entonces** el expediente del alumno actualiza automáticamente su cinta actual al nuevo grado (p. ej. de *9.º Geup* a *8.º Geup*), guarda la fecha y calificación en su historial de grados, reinicia a cero el contador de asistencias del nuevo grado y actualiza la cinta visual en la app Android del padre de familia.

### H7 (M5) · Pedido de equipo desde la app del padre y control de entrega en caja
- **Como** Padre de familia y Encargado de recepción, **queremos** solicitar equipo desde el catálogo de la app, registrar sus abonos y controlar si ya fue pagado y entregado **para** evitar confusiones de tallas o entregas de equipo sin liquidar.
  - **CA-H7.1 (Solicitud desde app del padre y apartado):** **Dado** el catálogo de equipo del dojang con el artículo "Peto reversible Talla 2 — $950 MXN (Stock: 4)", **cuando** el Padre selecciona ese artículo desde su app Android para su hijo "Mateo" y confirma la solicitud, **entonces** el pedido aparece en la bandeja de recepción con estado `Pago pendiente · Pendiente de entregar` y descuenta o reserva temporalmente la unidad del stock disponible.
  - **CA-H7.2 (Control de liquidación antes de entrega):** **Dado** un pedido de equipo que tiene un abono parcial de $400 MXN y un saldo pendiente de $550 MXN, **cuando** recepción intenta marcar el artículo como `Entregado`, **entonces** el sistema muestra una advertencia bloqueante indicando que existe un saldo pendiente de $550 MXN (requiriendo liquidar el saldo en caja con emisión de ticket o autorización explícita con PIN de Dueño para entrega a crédito); **y cuando** se liquida y se marca como `Entregado`, **entonces** la app del padre muestra el pedido como `Pagado y Entregado` con fecha y hora de recepción.

### H8 (M6) · Registro interno a torneos, responsiva digital y medallero
- **Como** Dueño y Padre de familia, **queremos** inscribir alumnos a un torneo registrando su peso, cinta, modalidad y carta responsiva digital del tutor, controlar quién ya pagó su cuota y guardar su medalla **para** organizar la participación del dojang sin hojas sueltas y conservar el palmarés del alumno.
  - **CA-H8.1 (Inscripción con responsiva digital del tutor y cargo en caja):** **Dado** que el Dueño publica el torneo "Copa Estatal TKD 2026" con cuota de $750 MXN y fecha límite 30 de noviembre, **cuando** el Padre inscribe desde la app Android a su hijo menor seleccionando modalidad (*Kyorugi* y/o *Poomsae*), confirma su peso actual y acepta digitalmente la carta responsiva del tutor, **entonces** el alumno queda preinscrito en la lista del torneo con su responsiva firmada (con fecha, hora e ID de tutor) y se genera el cargo por $750 MXN pendiente de pago en caja.
  - **CA-H8.2 (Exportación de lista oficial y registro de medalla en historial):** **Dado** el listado de alumnos inscritos al torneo con cuota `Pagada`, **cuando** el Dueño exporta el padrón del torneo, **entonces** obtiene un archivo CSV/Excel limpio con nombre, fecha de nacimiento, edad, rama, grado/cinta, peso exacto y modalidad listo para entregar al comité organizador; **y cuando** al finalizar el torneo el *Sabonim* registra que el alumno obtuvo medalla de `Oro` en *Kyorugi*, **entonces** el logro aparece en el medallero e historial deportivo del alumno dentro de la app Android del padre.

---

## 7. Métricas de éxito (a 90 días del piloto comercial)

1. **Reducción de morosidad en academias piloto:** disminución de al menos **40 % en la tasa de mensualidades vencidas** después de 2 ciclos mensuales usando el sistema (bajando de un rango típico de 20–25 % a menos del 12 %).
2. **Tasa de emisión de comprobantes digitales/impresos:** **>= 95 % de los cobros** de la academia (mensualidades, exámenes, equipo y torneos) registrados en M3 con Ticket de Comprobante foliado.
3. **Adopción por padres de familia:** **>= 70 % de las familias activas** de cada dojang piloto instalan la app Android, inician sesión y consultan al menos un ticket de pago o avance de grado de sus hijos en el primer mes.
4. **Velocidad operativa en mostrador y tatami:**
   - Tiempo para cobrar y emitir ticket (térmico o PDF): **<= 20 segundos** por transacción.
   - Tiempo de pase de lista por grupo de 25 alumnos con QR/lista táctil: **<= 60 segundos**.
   - Tiempo de corte de caja al cierre del día: **<= 3 minutos**.
5. **Retención y conversión comercial B2B:** al menos **3 de cada 5 academias del piloto** se convierten a suscripción de pago al terminar el periodo de prueba de 30 días.

---

## 8. Fuentes de ingreso y precio tentativo (MXN)

El modelo de negocio es **SaaS B2B por suscripción para academias de Taekwondo** (el dueño del dojang paga la suscripción; la app Android para sus instructores y para todos los padres de familia está incluida sin costo adicional por descarga, eliminando barreras de adopción con las familias).

### 8.1 Planes de suscripción (precios en MXN, IVA incluido)

| Plan | Tamaño de academia | Precio mensual (MXN) | Precio anual (MXN · 2 meses gratis) | Qué incluye |
|---|---|---|---|---|
| **Dojang Inicial** | Hasta **60 alumnos activos** | **$499 MXN / mes** | **$4,990 MXN / año** | Todos los módulos M1 a M6 · 1 PC Windows en recepción + 2 dispositivos Android para instructores + cuentas ilimitadas para padres de familia · Tickets térmicos y PDF ilimitados. |
| **Dojang Pro** *(Plan ancla recomendado)* | Hasta **150 alumnos activos** | **$899 MXN / mes** | **$8,990 MXN / año** | Todo lo de Inicial + hasta 3 PCs Windows + instructores ilimitados + reportes financieros avanzados, control de inventario multi-categoría y soporte prioritario por WhatsApp. |
| **Dojang Maestro / Multisede** | **151–400 alumnos** (o hasta 3 sedes) | **$1,499 MXN / mes** *(+$690 MXN por sede adicional)* | **$14,990 MXN / año** | Todo lo de Pro + panel consolidado para dueños con 2 o más sucursales/dojangs, catálogo de grados compartido entre sedes y gestión centralizada de exámenes y torneos inter-escuelas. |

### 8.2 Ingresos complementarios
1. **Paquete de Puesta en Marcha y Migración ("Llave en mano" opcional):** **$1,500 MXN** (pago único) — incluye importación del padrón actual de alumnos desde el Excel/libreta del profesor, configuración de su logotipo y catálogo personalizado de cintas/puntas, y capacitación de 45 minutos para recepción e instructores.
2. **Kit de Hardware de Recepción (opcional):** venta o recomendación con margen de miniprinter térmica USB/Bluetooth de 58 mm u 80 mm + lector QR de escritorio (**~$1,200 – $1,800 MXN** pago único).
3. *(Futuro v1.1)* **Comisión por conveniencia en pagos en línea:** cargo por servicio transparente al pagar con tarjeta/SPEI automatizado desde la app del padre (absorbido por el padre o por el dojang según configure la academia).

> *Justificación de precio para el dueño:* recuperar una sola mensualidad atrasada al mes ($700 a $1,000 MXN promedio en México) o evitar la fuga de un solo uniforme/examen no cobrado paga por completo la suscripción mensual del sistema.

---

## 9. Datos personales necesarios (insumo para `privacidad-mx` y `docs/privacidad.md`)

Dado que la plataforma trata datos de **menores de edad** (la mayoría de los practicantes de Taekwondo en escuelas tienen entre 4 y 17 años), datos de sus padres o tutores y **datos sensibles de salud opcionales** (alertas médicas para entrenamiento), el diseño debe cumplir estrictamente con la **LFPDPPP vigente en México**, los requisitos de Profeco (precios transparentes en MXN) y las políticas de familias/datos de usuario de Google Play y Microsoft Store.

### 9.1 Inventario preliminar de datos personales por titular

| Titular | Categoría de datos | Campos específicos requeridos | Finalidad (Primaria / Secundaria) | Base de legitimación y controles |
|---|---|---|---|---|
| **Padre / Madre o Tutor legal** | Identificación y contacto | Nombre completo, teléfono celular (WhatsApp), correo electrónico, parentesco con el alumno menor, contraseña (hash seguro). | **Primaria:** Crear la cuenta familiar, autenticar el acceso, vincular a sus hijos menores, enviarle tickets de comprobante de pago, estados de cuenta y convocatorias, y recabar su consentimiento y responsivas como representante legal del menor. | Consentimiento al aceptar el Aviso de Privacidad Integral y relación jurídica/contractual con la academia. |
| **Alumno menor de edad (o Alumno mayor de edad)** | Identificación y perfil deportivo | Nombre completo, fecha de nacimiento (para categoría de edad en torneos), sexo/rama, fotografía de perfil/credencial *(opcional)*, código QR interno de alumno, grado/cinta actual, historial de asistencias, exámenes y resultados de torneos. | **Primaria:** Gestión escolar y deportiva dentro del dojang, pase de lista, cálculo de elegibilidad para exámenes de grado e inscripción a torneos solicitados por el tutor. | **Para menores de 18 años:** Consentimiento verificable del Padre o Tutor legal (vinculación obligatoria a una cuenta de tutor antes de activar el expediente). |
| **Alumno (Menor o Mayor)** | Físicos y de salud *(Datos personales sensibles — opcionales)* | Peso en kg (solo cuando se inscribe a torneo de combate *Kyorugi*), tipo de sangre, alergias o condición médica relevante para actividad física (p. ej. asma, lesión previa) y teléfono de emergencia. | **Primaria:** Seguridad física del alumno durante el entrenamiento en el tatami, atención de emergencias y ubicación en la división de peso reglamentaria en torneos. | **Consentimiento expreso y por escrito (firma/aceptación digital verificable con bitácora inmutable)** del Padre/Tutor o del alumno mayor de edad (Art. 9 LFPDPPP). El campo médico es **opcional** y solo visible para el Dueño, el Instructor asignado y el propio Padre/Tutor. |
| **Padre / Tutor o Alumno mayor** | Patrimoniales / Transaccionales internos | Historial de cargos, descuentos, abonos, montos pagados, método de pago utilizado (efectivo, referencia SPEI o últimos 4 dígitos/autorización de terminal externa) y folios de tickets emitidos. *(En v1.0 NO se almacenan números completos de tarjetas bancarias ni CVV)*. | **Primaria:** Emisión de tickets de comprobante de pago, estado de cuenta familiar y corte de caja de la academia. | Relación contractual por la prestación de servicios de enseñanza deportiva y venta de equipo. |
| **Dueño, Recepción e Instructores** | Identificación y control de acceso | Nombre completo, rol (`Dueño`, `Recepción`, `Instructor`), correo/teléfono, contraseña (hash) y bitácora de operaciones en caja/evaluaciones. | **Primaria:** Control de acceso basado en roles (RBAC), auditoría de cortes de caja y firma de evaluaciones de examen. | Relación laboral o de prestación de servicios con la academia. |

### 9.2 Reglas de privacidad y seguridad desde el diseño (*Privacy by Design*)
1. **Principio de minimización:** queda prohibido pedir CURP, domicilio particular completo del menor, escuela primaria a la que asiste o documentos oficiales escaneados en el MVP v1.0, ya que no son necesarios para la gestión del dojang.
2. **Aislamiento multi-academia y multi-familia (RLS):** mediante políticas de seguridad a nivel de fila (*Row-Level Security*), un Padre de familia únicamente puede leer los registros, tickets, asistencias y grados de los hijos explícitamente vinculados a su `tutor_user_id`. Ningún padre puede ver el directorio de otros alumnos del dojang.
3. **Almacenamiento local seguro en modo *offline*:** la base de datos local en Windows y Android debe proteger la sesión, no exponer datos sensibles de salud en notificaciones de pantalla bloqueada y limpiar cachés locales al cerrar sesión.
4. **Derechos ARCO y revocación:** la app y el aviso de privacidad (`docs/privacidad.md`) incluirán el mecanismo claro para que el padre o tutor solicite el acceso, rectificación, cancelación (eliminación de cuenta y datos de sus hijos cuando causen baja definitiva de la academia) u oposición al tratamiento de sus datos.

---

## 10. Supuestos por validar con clientes (Piloto Compuertas C2 y C3)

Los siguientes supuestos de negocio, operación y producto están marcados para validarse con al menos **3 a 5 dueños de academias reales** y **15 padres de familia** antes y durante el piloto:

1. **[S1 · Disposición de pago y precio]:** Validar que el rango de **$499 a $899 MXN/mes** es percibido como altamente rentable por dueños de dojangs de entre 40 y 150 alumnos, y si prefieren pago mensual recurrente o anualidad con descuento.
2. **[S2 · Plataforma móvil de los padres]:** Validar qué porcentaje de los padres de familia en las academias objetivo utiliza **Android** frente a **iOS (iPhone)**. *(Hipótesis: >75 % en academias promedio usa Android, y para el porcentaje restante en v1.0 el envío del ticket en PDF/imagen por WhatsApp desde Windows cubre su necesidad de comprobante hasta el lanzamiento de iOS en v1.2).*
3. **[S3 · Impresión térmica vs comprobante digital]:** Validar en recepción cuántas academias ya cuentan con miniprinter térmica (58 mm u 80 mm) o desean adquirirla, frente a cuántas prefieren operar 100 % sin papel enviando el ticket en PDF/imagen por WhatsApp y directo a la app Android del padre.
4. **[S4 · Complejidad de cintas intermedias (puntas) y reglas de examen]:** Confirmar con profesores de distintas asociaciones/escuelas que el modelo de catálogo configurable (grado, color, meses mínimos, asistencias mínimas y costo) cubre el 100 % de sus variantes de cintas intermedias (*puntas*) y criterios de elegibilidad sin requerir fórmulas personalizadas por escuela.
5. **[S5 · Flujo de abonos en equipo, exámenes y torneos]:** Validar si en la práctica diaria las academias manejan una "cuenta corriente única por familia" o prefieren que cada abono se aplique directamente a un concepto específico (p. ej. "Abono $300 al Peto de Mateo" vs "Abono $300 al Examen de Sofía"). *En este PRD se asume la aplicación por concepto específico para que el ticket y el estado de entrega de equipo (M5) sean inequívocos.*
6. **[S6 · Rol de responsable legal en aviso de privacidad]:** Confirmar con `legal-privacidad-mx` el esquema exacto del Aviso de Privacidad: la Academia (*Dojang*) actúa como **Responsable** del tratamiento de los datos personales de sus alumnos y padres, mientras que CUPA (*Cupa Dojang*) actúa como **Encargado** tecnológico que provee la plataforma y genera automáticamente el aviso personalizado de cada academia.

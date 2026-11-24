# Diseño · Mi Doyang by Cupa

Sigue la skill `diseno-con-criterio`. Versión 0.1 · 23 nov 2026.

## 1. Quién lo usa y dónde

- **Recepción / Dueño en Escritorio (Windows):** el sabonim, administrador o recepcionista en el mostrador de entrada del dojang, usando una laptop o PC todo-en-uno con pantalla `1366×768` o `1920×1080` (y escalado de Windows al 100%, 125% o 150%). La hora crítica es de **17:00 a 20:30 h**, en el cambio de clase: hay ruido de niños saliendo del tatami, papás formados para pagar la mensualidad, preguntar cuánto cuesta el peto o inscribir a su hijo al examen del sábado. El operador necesita buscar al alumno con teclado, cobrar en efectivo o transferencia y entregar el ticket impreso o por WhatsApp en **menos de 15 segundos**.
- **Padre de familia / Tutor en Móvil (Android, futuro iOS):** mamá o papá en su celular (ancho mínimo `360 dp`), revisando desde casa o en la banca del dojang si la mensualidad de sus hijos está al corriente, descargando su **ticket de comprobante de pago**, viendo cuántas clases le faltan a cada hijo para su siguiente examen de cinta, consultando el precio de un dobok o autorizando su inscripción a un torneo.
- **Instructor en el Tatami (Android):** de pie junto al área de entrenamiento con el celular en una mano; pasa lista por código QR o toque rápido en lista y, en día de examen, registra las calificaciones de Poomsae, Kyorugi y rompimiento.

## 2. Qué debe lograr cada pantalla en 3 segundos

- **Escritorio Windows (Recepción y Caja):** encontrar a cualquier alumno o familia tecleando 3 letras, ver de inmediato su cinta, su saldo (`Al corriente` o `Adeudo $850.00 MXN`) y cobrar con un atajo (`F2`) mostrando la vista previa real del ticket.
- **Móvil Android (Portal del Padre):** ver la tarjeta de cada hijo con su **faja de cinta actual**, su progreso de asistencias hacia el próximo examen, el estado de su mensualidad y el botón directo para ver/descargar sus tickets de pago.
- **Móvil Android (Instructor):** marcar asistencia de un grupo de 25 alumnos en menos de 30 segundos sin errores de dedo (objetivos táctiles ≥ `48 dp`).

## 3. Vocabulario visual del mundo del producto

Un dojang de Taekwondo combina disciplina tradicional y claridad administrativa:
- **Papel de diploma / Dobok limpio (`#F7F5F0`):** fondo principal de trabajo en administración y tarjetas de recibo; cálido, descansa la vista en turnos largos y evita el blanco clínico genérico (`#FFFFFF`) de plantilla SaaS.
- **Madera oscura de dojang / Cinturón negro (`#14181F`):** barra lateral de navegación en Windows y encabezados de credencial/cinta.
- **Sello bermellón coreano — Dojang Injang (`#B82924`):** color de marca y de sellos oficiales (exámenes aprobados, alertas de corte, sello en comprobantes).
- **Azul Tatami / Chung (`#1644AD`):** acción primaria de cobro, enlaces activos y confirmación de operaciones.
- **Logo corporativo CUPA (`LogoMiDoyang` y carpeta `marca/`):** sigue estrictamente el formato institucional de **LOGOS CUPA** (`OVR CUPA`, `OSS CUPA`, `CUPA Taekwondo`, `OSS CUPA Pocket`): tipografía geométrica **Inter Bold** en mayúsculas, la letra **"O"** formada por un círculo sólido partido verticalmente con separación limpia al centro (mitad izquierda azul CUPA, mitad derecha roja CUPA, sin anillo exterior), doble línea horizontal de ancho completo debajo del nombre principal (superior azul, inferior roja) y subtítulo centrado **`B Y   C U P A`**.
- **Fajas reales de cinta (Kup / Poom / Dan):** el grado de un alumno se dibuja como un bloque horizontal de cinta `5:1` con costura longitudinal; las **cintas avanzadas** llevan una **franja horizontal al centro a lo largo de toda la cinta** del color de la siguiente cinta (`Blanca Avanzada` franja Naranja, `Amarilla Avanzada` franja Verde, `Verde Avanzada` franja Azul, `Azul Avanzada` franja Marrón, `Marrón Avanzada` franja Roja), y la cinta **Negra 1er Poom** (<15 años) se divide mitad roja arriba y mitad negra abajo.
- **Ticket de comprobante físico:** tipografía monoespaciada tabular, borde superior/inferior tipo papel térmico, folio único, código QR de verificación y sello tipográfico `PAGADO`.

## 4. Paleta y contraste (WCAG 2.1 AA verificado)

### 4.1 Paleta base del sistema (`ThemeData` y `DojangTokens`)

| Nombre | Hex | Rol | Contraste verificado |
|---|---|---|---|
| Papel Dobok | `#F7F5F0` | Fondo principal (modo claro en Windows y Android) | `15.4:1` con Tinta Negra (`#14181F`) |
| Superficie Tatami | `#FFFFFF` | Paneles elevados, hoja de ticket, celdas de tabla activa | `17.2:1` con Tinta Negra (`#14181F`) |
| Borde Piedra | `#D6D1C7` | Divisores de tabla, contorno de ticket y campos de captura | `1.35:1` decorativo; bordes de input activos suben a `#5A6270` (`5.6:1`) |
| Tinta Cinturón Negro | `#14181F` | Texto primario, montos, titulares y barra lateral en Windows | `15.4:1` sobre Papel Dobok |
| Tinta Grafito | `#4A5260` | Texto secundario, etiquetas de tabla, metadatos de recibo | `7.1:1` sobre Papel Dobok / `7.9:1` sobre `#FFFFFF` (pasa AA y AAA) |
| Azul Chung (Primario) | `#1644AD` | Botón primario ("Cobrar y emitir ticket"), foco de teclado, enlaces | `7.8:1` con texto blanco `#F7F5F0`; `7.8:1` sobre Papel Dobok |
| Sello Hong (Secundario) | `#B82924` | Sello de examen/convocatoria, acciones destructivas, adeudo vencido | `5.9:1` con texto `#F7F5F0`; `5.9:1` sobre Papel Dobok |
| Jade Aprobado | `#146C43` | Estado "Al corriente", "Ticket pagado", "Examen aprobado" | `6.1:1` con texto `#F7F5F0` y `6.1:1` sobre Papel Dobok |
| Ámbar Tatami | `#8A5300` | Texto/borde de "Por vencer", "Equipo pendiente de entrega" (sobre fondo `#FFF4DB`) | `5.8:1` sobre fondo `#FFF4DB` (nunca amarillo claro sobre blanco) |

### 4.2 Tokens oficiales de Cintas de Taekwondo (`BeltTokens`)

Cada academia puede personalizar el orden y las puntas de su programa de grados, usando estos tokens verificados:

| Grado / Cinta | Color Base (Hex) | Color de Punta / Franja | Texto sobre la cinta | Contraste texto/cinta |
|---|---|---|---|---|
| 10.º Geup · Blanca | `#F4F2ED` (borde `#7A766E`) | Sin punta o Amarilla `#D99B00` | `#14181F` | `14.8:1` |
| 8.º Geup · Amarilla | `#E0A800` | Verde `#186A3B` (en 7.º Geup) | `#14181F` | `9.4:1` |
| 6.º Geup · Verde | `#186A3B` | Azul `#1644AD` (en 5.º Geup) | `#F7F5F0` | `6.2:1` |
| 4.º Geup · Azul | `#1644AD` | Roja `#B82924` (en 3.º Geup) | `#F7F5F0` | `7.8:1` |
| 2.º Geup · Roja | `#B82924` | Negra `#14181F` (en 1.º Geup) | `#F7F5F0` | `5.9:1` |
| Poom (Infantil <15 años) | Mitad `#B82924` / Mitad `#14181F` | Bordado dorado `#E0A800` | `#F7F5F0` | `>5.7:1` |
| 1.º a 9.º Dan · Negra | `#14181F` | Líneas de Dan en `#E0A800` | `#F7F5F0` | `16.3:1` |

**Reglas geométricas de `BeltWidget`:**
- El `20%` derecho del bloque `5:1` se reserva exclusivamente para la franja vertical de la **punta** (cuando aplica); el texto del grado se alinea en el `80%` izquierdo y nunca invade la punta.
- En la cinta **Poom** (dividida horizontalmente en rojo `#B82924` arriba y negro `#14181F` abajo), cualquier etiqueta o indicador en dorado (`#E0A800`) se dibuja únicamente sobre la mitad negra (`#14181F`, contraste `8.3:1`), nunca sobre la mitad roja (`2.85:1`).

### 4.3 Regla de personalización visual por academia (White-label seguro)
Cada academia puede subir su escudo/logo y elegir su color institucional en `Ajustes > Identidad del Dojang`. Para evitar que una academia elija un color ilegible (por ejemplo, amarillo brillante con letras blancas), el motor de tema convierte el color elegido al espacio **HSL/HCT** y fuerza que el relleno del botón primario mantenga una razón de contraste **≥ 4.5:1** frente al texto (`#F7F5F0` o `#14181F`).

## 5. Tipografía, iconografía y escala

1. **Titulares, grados, marcadores de progreso y montos grandes:** **Oswald** (licencia OFL, empaquetada en `assets/fonts/`), peso 600, con `FontFeature.tabularFigures()` o casillas de ancho fijo en los totales (`32 dp` y `44 dp`) para que no bailen al marcar/desmarcar cargos.
2. **Interfaz, formularios y tablas densas:** **Plus Jakarta Sans** (licencia OFL, pesos 400, 500, 600, 700), con `FontFeature.tabularFigures()` obligatorio en todas las columnas numéricas, fechas, edades, asistencias y precios.
3. **Exclusivo para el widget de Ticket térmico y folios:** **JetBrains Mono** (licencia OFL, pesos 500 y 700) con cifras tabulares para representar con fidelidad el papel térmico de 58/80 mm. Prohibido usarla fuera del ticket y folios.
4. **Iconografía única:** set **Lucide Icons** (`lucide_icons`), trazo uniforme de `1.75 px`. Prohibido usar emojis como íconos o mezclar sets.
5. **Escala tipográfica (dp):**
   - `12 dp`: metadatos de ticket, sellos de tiempo, atajos de teclado (`[F2]`).
   - `14 dp`: celdas de tabla en Windows, etiquetas de formulario, subtítulos en Android.
   - `16 dp`: cuerpo principal, nombres de alumnos en lista, botones estándar.
   - `20 dp`: títulos de sección, nombre del alumno en expediente.
   - `24 dp`: encabezados de pantalla, total de concepto.
   - `32 dp`: gran total por cobrar en caja y saldo en el portal del padre.
   - `44 dp`: monto principal en el corte de caja o marcador de examen.

## 6. Wireframes y densidad por plataforma

### 6.1 Escritorio Windows — Recepción, Caja y Emisión de Ticket (`1280×720` / `1366×768`)

Densidad alta para escritorio, navegación lateral fija, barra de búsqueda global con foco automático (`F3`) y vista de 3 columnas sin modales innecesarios.
- **Adaptación a escalado DPI (125% / 150%) y texto al 130%:** cuando el ancho lógico efectivo es `< 1100 dp` (ej. `1366×768` al 125%/150% o `1280×720` con texto al 130%), la barra lateral izquierda colapsa automáticamente a un `NavigationRail` compacto de `72 dp` (ícono Lucide + etiqueta corta) para que la columna central de cargos nunca baje de `480 dp`.

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│ MI DOYANG BY CUPA · Academia Tigres TKD         [● En línea · Caja 1]   [F3 Buscar alumno...]  │
├──────────────┬───────────────────────────────────────────┬───────────────────────────────┤
│ DOJANG       │ FAMILIA: HERNÁNDEZ LÓPEZ (2 hermanos)     │ TICKET DE PAGO · VISTA PREVIA │
│              │ Tutor: Laura López · Tel: 55 4123 8910    │ ┌───────────────────────────┐ │
│ ▶ [F2] Caja  ├───────────────────────────────────────────┤ │   ACADEMIA TIGRES TKD     │ │
│   Alumnos    │ [✓] Mateo Hernández (11 años)             │ │ Folio: CAJA1-2026-00418   │ │
│   Asistencia │     [═══ CINTA VERDE · 6.º Geup ═══│██]   │ │ Fecha: 23 nov 2026 18:14  │ │
│   Exámenes   │     Asistencias: 22/24 · Elegible examen  │ │ Alumno: Mateo y Sofía H.  │ │
│   Equipo     │ [✓] Sofía Hernández (8 años)              │ │     (IMPORTES EN MXN)     │ │
│   Torneos    │     [═══ CINTA AMARILLA · 8.º Geup ════]  │ │ ───────────────────────── │ │
│   Corte/Caja │     Asistencias: 19/20                    │ │ Mensualidad Dic (2) $1,600│ │
│   Ajustes    ├───────────────────────────────────────────┤ │ Desc. hermanos 10%  -$160 │ │
│              │ CARGOS POR COBRAR          [+ Agregar F4] │ │ Examen 5.º Geup      $450 │ │
│              │ [x] Mensualidad Dic · Mateo      $800.00  │ │ Peto Talla Chica     $650 │ │
│              │ [x] Mensualidad Dic · Sofía      $640.00  │ │ ───────────────────────── │ │
│              │     (Descuento hermano 10% aplicado)      │ │ TOTAL:      $2,540.00 MXN │ │
│              │ [x] Derecho a Examen 5.º Geup    $450.00  │ │ Método: Efectivo          │ │
│              │ [x] Peto reversible Talla CH     $650.00  │ │    [QR VERIFICACIÓN]      │ │
│              │ ───────────────────────────────────────── │ └───────────────────────────┘ │
│ ──────────── │ Subtotal: $2,540.00 MXN  │ Recargo: $0.00 │ Método: (•)Efectivo ( )Transf │
│ Sin conexión:│ [Abono parcial]   TOTAL: $2,540.00 MXN    │ [F2 Cobrar e Imprimir 80mm]   │
│ 0 en cola    │                                           │ [   Cobrar y enviar PDF   ]   │
└──────────────┴───────────────────────────────────────────┴───────────────────────────────┘
```

### 6.2 Escritorio Windows — Gestión de Exámenes de Grado y Cintas

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│ EXÁMENES DE GRADO · Convocatoria: Examen Invierno (12 dic 2026 · Sinodal: Sabonim Kim)   │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│ Filtro: [Todos (28)] [Elegibles (21)] [Inscritos y pagados (16)] [Pendientes pago (5)]   │
├──────────────────────┬────────────────────┬───────────┬──────────┬───────────┬───────────┤
│ Alumno               │ Cinta actual → Sig │ Asist.    │ Mensual. │ Examen    │ Calific.  │
├──────────────────────┼────────────────────┼───────────┼──────────┼───────────┼───────────┤
│ Mateo Hernández      │ [Verde] → [V.P.Az] │ 24/24 ✓   │ Al día ✓ │ Pagado ✓  │ [Evaluar] │
│ Diego Ramírez        │ [Azul]  → [Az.P.R] │ 26/24 ✓   │ Al día ✓ │ Pendiente │ [Cobrar]  │
│ Valentina Cruz       │ [Roja]  → [R.P.N]  │ 18/28 ⚠   │ Al día ✓ │ —         │ Excepción │
└──────────────────────┴────────────────────┴───────────┴──────────┴───────────┴───────────┘
```

### 6.3 Móvil Android — Portal del Padre de Familia (`360 dp` mínimo)

Objetivos táctiles de `48×48 dp` mínimo, selector superior de hijos cuando hay hermanos, faja visual de la cinta y acceso directo a tickets de comprobante:

```
┌──────────────────────────────────┐
│ [Escudo] ACADEMIA TIGRES TKD     │
│ Hola, Laura · Familia Hernández  │
├──────────────────────────────────┤
│ Hijos: [● Mateo (11)] [○ Sofía]  │  ← pestañas táctiles 48 dp
├──────────────────────────────────┤
│ GRADO ACTUAL · MATEO             │
│ ┌──────────────────────────┬───┐ │
│ │ 6.º GEUP · CINTA VERDE   │   │ │  ← faja de cinta con costura
│ └──────────────────────────┴───┘ │
│ Próximo: 5.º Geup (Punta Azul)   │
│ Asistencias: 22 de 24 clases     │
│ [███████████████████░░] 92%      │
│ Examen Invierno: 12 dic · Pagado │
├──────────────────────────────────┤
│ ESTADO DE CUENTA                 │
│ Mensualidad Diciembre: AL DÍA ✓  │
│ Último pago: 23 nov · $2,540.00  │
│ [Recibo: Ver CAJA1-2026-00418]   │  ← ícono Lucide Receipt + QR/PDF
├──────────────────────────────────┤
│ EVENTOS Y EQUIPO                 │
│ • Peto Talla CH: Pagado (Recoger)│
│ • Torneo Copa Primavera ($600)   │
│   [Inscribir a Mateo]            │
├────────┬────────┬────────┬───────┤
│ Inicio │Tickets │Grados  │Tienda │  ← barra inferior 4 destinos
└────────┴────────┴────────┴───────┘
```

### 6.4 Móvil Android — Instructor en Tatami (Pase de lista y evaluación, `360 dp`)

Diseñado para operarse con una sola mano de pie frente al grupo, con filas táctiles de `56 dp` de alto y botones de `48×48 dp`:

```
┌──────────────────────────────────┐
│ PASE DE LISTA · Infantil 18:00 h │
│ Lun 23 nov · 18 presentes de 22  │
├──────────────────────────────────┤
│ [Escanear QR credencial] [Todos] │  ← botones de 48 dp de alto
├──────────────────────────────────┤
│ Mateo Hernández      [6.º Verde] │
│ Asist: 22/24 · Alerta: Ninguna   │
│                       [PRESENTE] │  ← bloque verde Jade 48 dp
├──────────────────────────────────┤
│ Sofía Hernández     [8.º Amar.]  │
│ Asist: 19/20 · Alerta: Ninguna   │
│                       [PRESENTE] │
├──────────────────────────────────┤
│ Diego Ramírez         [4.º Azul] │
│ [!] Alergia: Penicilina          │  ← aviso visible si tutor autorizó
│                     [ Marcar + ] │
├──────────────────────────────────┤
│ [  Guardar asistencia (18/22)  ] │
├───────────┬───────────┬──────────┤
│ Asistencia│ Exámenes  │  Grupos  │
└───────────┴───────────┴──────────┘
```

## 7. Movimiento y estados

- **Movimiento con propósito:**
  1. Al registrar un cobro en caja, el ticket se desliza verticalmente (`180 ms`, curva `easeOutCubic`) desde el cabezal de vista previa simulando la salida del papel térmico.
  2. Cuando un alumno aprueba un examen, la faja de su cinta muestra la transición del color anterior al nuevo grado (`220 ms`).
  3. Si el sistema operativo tiene activado "Reducir animaciones", todas las transiciones son instantáneas (`0 ms`).
- **Estados completos en cada vista:**
  - **Sin conexión (Offline-first):** barra superior discreta en color Ámbar Tatami: `"Sin internet · Cobrando en modo local (3 tickets listos para sincronizar al reconectar)"`. Nunca bloquea la caja.
  - **Vacío:** acciones directas (`"Aún no hay alumnos en este horario. [Dar de alta primer alumno]"`).
  - **Cargando:** esqueletos planos del color `#EAE6DD`, sin spinners parpadeantes en toda la pantalla.
  - **Error accionable:** `"La impresora térmica USB no responde. El ticket CAJA1-2026-00418 ya quedó guardado: puedes [Reintentar impresión] o [Guardar PDF para WhatsApp]"`.

## 8. Tono y formatos locales (`es-MX`)

- **Trato:** **Tú** dentro de la interfaz operativa y en la app de padres; **Usted** en los textos legales, avisos de privacidad y términos impresos en el ticket.
- **Botones con verbo concreto:** `"Cobrar e imprimir ticket"`, `"Inscribir a examen"`, `"Registrar ascenso de cinta"`, `"Entregar equipo en mostrador"`.
- **Formatos:** moneda siempre explícita (`$1,250.00 MXN`), fechas claras (`23 nov 2026`), horarios en formato 24 h o 12 h claro (`18:00 – 19:00 h`).

## 9. Clichés revisados y eliminados

- Sin morado/índigo (`#6750A4`) ni gradientes decorativos morado-azul.
- Sin tarjetas blancas flotantes con `BoxShadow` borroso en cada rincón: se usan contenedores con borde definido `#D6D1C7` de `1 dp`, inspirados en hojas de registro y recibos reales.
- Sin íconos genéricos dentro de círculos pastel.
- Sin frases de relleno ("Bienvenido a tu dashboard", "Potencia tu academia").
- Sin gráficos circulares o "donas" decorativas en la pantalla principal: la recepción necesita la cola de cobros, los adeudos reales y el buscador inmediato.

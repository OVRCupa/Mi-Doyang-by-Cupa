# Análisis Operativo · Dashboard Principal de una Academia de Taekwondo

Proyecto: **Mi Doyang by Cupa** (`gestion-academias`) · Noviembre 2026.

## 1. Contexto real del dojang en México

En la operación diaria de una academia de Taekwondo (especialmente en el horario pico de **16:30 a 20:30 h**), el sabonim, dueño o encargado de recepción no tiene tiempo de navegar cinco menús para saber cómo está su escuela. En menos de **5 segundos** al abrir el sistema necesita responder cuatro preguntas críticas:

1. **¿Quién entrena hoy, en qué cinta está y quién trae mensualidad vencida o ya cumple requisitos para examen?**
2. **¿Cuánto dinero entró realmente a caja hoy/este mes (Efectivo vs. Transferencia) y cuánto falta por cobrar?**
3. **¿Cuánto se ha ido en gastos operativos del dojang y cuál es el balance neto real (`Ingresos − Gastos`)?**
4. **¿Qué exámenes de grado Kup/Poom/Dan o torneos vienen en puerta y cuántos alumnos faltan por inscribirse?**

---

## 2. Jerarquía visual e institucional del encabezado

- **Esquina superior izquierda:** Logo corporativo oficial **`MI DOYANG / BY CUPA`** (formato `LOGOS CUPA`), funcionando además como botón directo de retorno al Dashboard desde cualquier pestaña interna.
- **Centro del encabezado:** **Nombre de la academia** (ej. *Doyang Leones TKD*) y su lema institucional, dándole identidad propia al dojang frente a padres y alumnos en recepción.
- **Esquina superior derecha:** Estado operativo (`En línea · Caja sincronizada` o `Modo local` con conteo de eventos pendientes) y acceso rápido a Ajustes.

---

## 3. Información crítica que debe visualizarse primero

### A. Los 3 pequeños módulos principales (acceso en 1 clic)
En lugar de tarjetas de bienvenida grandes que empujan la información hacia abajo, los 3 roles operativos se presentan como **módulos compactos horizontales** con métricas vivas:
1. **Recepción y Caja:** muestra cuántos cargos están pendientes de cobro y abre directo la terminal de cobro, padrón y corte.
2. **Portal de Padres:** muestra el total de familias registradas para consultar avance de cintas Kup/Poom/Dan, comprobantes QR y tienda de equipo.
3. **Instructor en Tatami:** muestra los alumnos activos para pase de lista rápido por QR y consulta de alertas médicas autorizadas.

### B. Fila de 4 KPIs ejecutivos (cifras tabulares MXN)
1. **Alumnos en academia:** activos totales, desglosando cuántos están **al día**, cuántos **con adeudo** y cuántos ya son **elegibles para examen**.
2. **Ingresos cobrados:** suma de tickets vigentes en MXN y monto **por cobrar** (cartera vencida o pendiente de mensualidades, exámenes y equipo).
3. **Gastos operativos:** suma acumulada de egresos del dojang.
4. **Balance neto en caja (`Ingresos − Gastos`):** liquidez operativa real disponible.

### C. Los 4 paneles operativos del Dashboard
1. **Alumnos en la academia:** lista viva del padrón con su faja real **`BeltWidget`** (incluyendo franja horizontal central en cintas avanzadas y división rojinegra en 1er Poom), grupo/horario, conteo de asistencias hacia su próximo grado y semáforo de pago (`Al corriente ✓` vs. `Adeudo`).
2. **Historial de ingresos:** desglose inmediato por método de pago (`Efectivo`, `Transferencia`, `Por cobrar`) y bitácora de los últimos tickets emitidos con folio verificable, concepto y monto.
3. **Sección de gastos (`GastoAcademia`):** captura rápida in-situ (`+ Registrar gasto`) clasificada en las categorías reales de un dojang (*Renta del local*, *Honorarios de instructores*, *Luz, agua e internet*, *Equipo, cintas y tablas*, *Federación y eventos*, *Limpieza y tatami*, *Otros*) e historial de egresos.
4. **Eventos próximos:** calendario accionable de **Convocatorias de Examen de Grado** (fecha, sinodal, elegibles vs. inscritos) y **Torneos de Taekwondo** (fecha del evento, cierre de registros, sede, cuota e inscritos).

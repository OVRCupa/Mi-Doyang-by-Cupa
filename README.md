# Mi Doyang by Cupa

**Qué es:** Sistema integral de administración y operación para academias (dojangs) de Taekwondo, compuesto por una **app de escritorio para Windows** (administración, recepción, caja offline-first e impresión de tickets) vinculada a una **app móvil para Android** (y futuro iOS) para **padres de familia, alumnos e instructores**.

**Para quién:** Dueños de academias de Taekwondo, recepcionistas, instructores (sabonim) y padres de familia en México y Latinoamérica.

**Plataformas:**
- **v1.0 (MVP):** Windows (escritorio: recepción/administración) + Android (móvil: padres de familia e instructores).
- **v1.2:** iOS (iPhone) desde la misma base de código Flutter.

**Estado:** Fase de descubrimiento y diseño (PRD v0.1, Arquitectura v0.1, Diseño v0.1 y Privacidad LFPDPPP 2025 listos para revisión en **Compuerta C2**).

## Módulos principales
1. **Personalización por academia:** logo, colores del dojang, datos de recibo, plan propio de cintas/grados (10.º Geup a Dan y puntas intermedias), horarios y tarifas (mensualidad, recargos, descuento familiar por hermanos).
2. **Alumnos y portal para padres de familia:** una sola cuenta de padre/tutor vinculada a todos sus hijos; consulta de cinta actual, asistencias, costos, avisos y descarga de comprobantes.
3. **Caja, cobros y tickets de comprobante de pago (Offline-first):** cobro de mensualidades, inscripciones, exámenes, equipo y torneos con emisión de ticket foliado con código QR (impresión térmica 58/80 mm en Windows, PDF/imagen para WhatsApp y consulta inmediata en la app del padre).
4. **Avance de grados y exámenes internos:** elegibilidad automática por asistencias/tiempo/pagos, registro interno a examen, evaluación con sinodal y ascenso automático de cinta.
5. **Equipo y tienda del dojang:** catálogo e inventario de doboks, petos, protecciones y cintas con tallas, control de pagos y estatus de entrega.
6. **Registros internos a torneos:** convocatorias, inscripción por modalidad (Kyorugi / Poomsae, peso, cinta), responsiva del tutor, control de cuota y registro de medallas/resultados.

## Cómo ejecutar
*(El esqueleto de código en `core/` y `app/` se genera al aprobar la Compuerta C2)*

## Documentos
- [Investigación y Precios](docs/research/competencia-precios.md) · [PRD](docs/prd.md) · [Decisiones](docs/decisiones.md) · [Arquitectura](docs/arquitectura.md) · [Diseño](docs/diseno.md) · [Privacidad](docs/privacidad.md) · [Riesgos](docs/riesgos.md) · [Bugs](docs/bugs.md)
- Legal: [Aviso de Privacidad Integral](legal/aviso-privacidad-integral.md) · [Aviso Simplificado](legal/aviso-privacidad-simplificado.md) · [Términos y Contrato de Encargo](legal/terminos.md)

-- ============================================================================
-- Mi Doyang by Cupa · Esquema Multi-Tenant PostgreSQL + Row Level Security
-- Migración: 0001_esquema_inicial.sql
-- Cumplimiento: docs/arquitectura.md (20 tablas), D-04, D-05, D-10, D-11 y LFPDPPP 2025
-- ============================================================================

create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- 1. ACADEMIAS (Tenants) Y PERFILES DE USUARIO (RBAC)
-- ----------------------------------------------------------------------------

create table if not exists public.academias (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  lema text not null default '',
  telefono text not null default '',
  direccion text not null default '',
  rfc_opcional text,
  logo_storage_path text,
  color_primario_hex text not null default '#1644AD',
  prefijo_caja text not null default 'CAJA1',
  dia_limite_pago int not null default 10 check (dia_limite_pago between 1 and 28),
  mensualidad_base_centavos int not null default 80000 check (mensualidad_base_centavos > 0),
  inscripcion_centavos int not null default 50000 check (inscripcion_centavos >= 0),
  recargo_mora_centavos int not null default 10000 check (recargo_mora_centavos >= 0),
  descuento_segundo_hermano_pct int not null default 10 check (descuento_segundo_hermano_pct between 0 and 100),
  descuento_tercer_hermano_pct int not null default 20 check (descuento_tercer_hermano_pct between 0 and 100),
  leyenda_ticket text not null default 'Gracias por entrenar con nosotros.',
  plan_suscripcion text not null default 'inicial' check (plan_suscripcion in ('inicial', 'pro', 'maestro')),
  activa boolean not null default true,
  creado_en timestamptz not null default now()
);

create table if not exists public.perfiles_usuario (
  id uuid primary key references auth.users(id) on delete cascade,
  academia_id uuid not null references public.academias(id) on delete cascade,
  rol text not null check (rol in ('dueno', 'recepcion', 'instructor', 'tutor')),
  nombre_completo text not null,
  telefono_whatsapp text not null default '',
  correo text not null default '',
  parentesco text not null default 'Tutor',
  bloqueado_arco boolean not null default false,
  creado_en timestamptz not null default now()
);

create index if not exists idx_perfiles_academia_rol
  on public.perfiles_usuario (academia_id, rol);

-- Funciones auxiliares para políticas RLS (SECURITY DEFINER con search_path fijo)
create or replace function public.mi_academia_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select academia_id from public.perfiles_usuario where id = auth.uid() limit 1;
$$;

create or replace function public.mi_rol()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select rol from public.perfiles_usuario where id = auth.uid() limit 1;
$$;

create or replace function public.es_personal_academia()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.mi_rol() in ('dueno', 'recepcion', 'instructor'), false);
$$;

create or replace function public.es_caja_o_dueno()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.mi_rol() in ('dueno', 'recepcion'), false);
$$;

-- ----------------------------------------------------------------------------
-- 2. GRADOS / CINTAS, GRUPOS, ALUMNOS, FAMILIAS Y ASISTENCIAS
-- ----------------------------------------------------------------------------

create table if not exists public.grados_cinta (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  orden int not null check (orden > 0),
  codigo text not null,
  nombre text not null,
  color_base_hex text not null,
  color_punta_hex text,
  es_poom boolean not null default false,
  meses_minimos int not null default 3 check (meses_minimos >= 0),
  asistencias_minimas int not null default 20 check (asistencias_minimas >= 0),
  costo_examen_centavos int not null default 60000 check (costo_examen_centavos >= 0),
  unique (academia_id, orden)
);

create table if not exists public.grupos_horarios (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  nombre text not null,
  dias_semana text not null,
  hora_inicio time not null,
  hora_fin time not null,
  instructor_id uuid references public.perfiles_usuario(id) on delete set null,
  activo boolean not null default true
);

create table if not exists public.alumnos (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  nombre text not null,
  apellidos text not null,
  fecha_nacimiento date not null,
  sexo_rama text not null check (sexo_rama in ('femenil', 'varonil')),
  peso_kg numeric(5,2) check (peso_kg is null or peso_kg > 0),
  grado_actual_id uuid not null references public.grados_cinta(id),
  fecha_ultimo_grado date not null default current_date,
  asistencias_en_grado_actual int not null default 0 check (asistencias_en_grado_actual >= 0),
  grupo_id uuid references public.grupos_horarios(id) on delete set null,
  foto_storage_path text,
  codigo_qr text not null,
  -- Datos médicos sensibles opcionales (solo con consentimiento expreso LFPDPPP 2025)
  tipo_sangre_opcional text,
  alergias_cuidados_opcional text,
  telefono_emergencia_opcional text,
  activo boolean not null default true,
  bloqueado_arco boolean not null default false,
  creado_en timestamptz not null default now(),
  unique (academia_id, codigo_qr)
);

create index if not exists idx_alumnos_academia on public.alumnos (academia_id, activo);

create table if not exists public.tutor_alumnos (
  academia_id uuid not null references public.academias(id) on delete cascade,
  tutor_id uuid not null references public.perfiles_usuario(id) on delete cascade,
  alumno_id uuid not null references public.alumnos(id) on delete cascade,
  parentesco text not null default 'Madre/Padre',
  creado_en timestamptz not null default now(),
  primary key (tutor_id, alumno_id)
);

create table if not exists public.asistencias (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  alumno_id uuid not null references public.alumnos(id) on delete cascade,
  fecha_dia date not null,
  registrada_en timestamptz not null default now(),
  metodo text not null check (metodo in ('qr', 'manual')),
  registrada_por_id uuid references public.perfiles_usuario(id) on delete set null,
  unique (academia_id, alumno_id, fecha_dia)
);

-- ----------------------------------------------------------------------------
-- 3. CAJA OFFLINE-FIRST, CARGOS Y TICKETS DE COMPROBANTE INMUTABLES
-- ----------------------------------------------------------------------------

create table if not exists public.conceptos_cobro (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  tipo text not null check (tipo in ('mensualidad', 'inscripcion', 'examen_grado', 'equipo', 'torneo', 'otro')),
  nombre text not null,
  monto_predeterminado_centavos int not null check (monto_predeterminado_centavos >= 0),
  activo boolean not null default true
);

create table if not exists public.cargos_estado_cuenta (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  tutor_id uuid references public.perfiles_usuario(id) on delete set null,
  alumno_id uuid references public.alumnos(id) on delete set null,
  tipo text not null check (tipo in ('mensualidad', 'inscripcion', 'examen_grado', 'equipo', 'torneo', 'otro')),
  concepto text not null,
  periodo text,
  subtotal_centavos int not null check (subtotal_centavos >= 0),
  descuento_centavos int not null default 0 check (descuento_centavos >= 0),
  recargo_centavos int not null default 0 check (recargo_centavos >= 0),
  total_centavos int not null check (total_centavos >= 0),
  pagado_centavos int not null default 0 check (pagado_centavos >= 0),
  saldo_centavos int not null check (saldo_centavos >= 0),
  fecha_vencimiento date not null,
  referencia_origen_id uuid,
  estado text not null check (estado in ('pendiente', 'abonado_parcial', 'pagado', 'cancelado')),
  creado_en timestamptz not null default now()
);

create index if not exists idx_cargos_academia_tutor
  on public.cargos_estado_cuenta (academia_id, tutor_id, estado);

create table if not exists public.pagos_tickets (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  client_mutation_id text not null,
  folio text not null,
  tutor_id uuid references public.perfiles_usuario(id) on delete set null,
  cajero_id uuid references public.perfiles_usuario(id) on delete set null,
  emitido_en timestamptz not null default now(),
  metodo_pago text not null check (metodo_pago in ('efectivo', 'transferencia', 'terminal')),
  referencia_pago text,
  total_pagado_centavos int not null check (total_pagado_centavos > 0),
  codigo_verificacion_qr text not null,
  cancelado boolean not null default false,
  motivo_cancelacion text,
  folio_reverso text,
  unique (academia_id, folio),
  unique (academia_id, client_mutation_id)
);

create table if not exists public.pagos_detalle (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  ticket_id uuid not null references public.pagos_tickets(id) on delete cascade,
  cargo_id uuid not null references public.cargos_estado_cuenta(id) on delete restrict,
  alumno_nombre_snapshot text not null,
  concepto_snapshot text not null,
  monto_abonado_centavos int not null check (monto_abonado_centavos > 0),
  saldo_restante_cargo_centavos int not null check (saldo_restante_cargo_centavos >= 0)
);

-- ----------------------------------------------------------------------------
-- 4. EXÁMENES DE GRADO, EQUIPO E INVENTARIO, Y TORNEOS
-- ----------------------------------------------------------------------------

create table if not exists public.examenes_convocatorias (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  titulo text not null,
  fecha_examen date not null,
  sinodal text not null,
  cerrada boolean not null default false,
  creado_en timestamptz not null default now()
);

create table if not exists public.examenes_inscripciones (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  convocatoria_id uuid not null references public.examenes_convocatorias(id) on delete cascade,
  alumno_id uuid not null references public.alumnos(id) on delete cascade,
  grado_actual_id uuid not null references public.grados_cinta(id),
  grado_aspirado_id uuid not null references public.grados_cinta(id),
  cargo_id uuid references public.cargos_estado_cuenta(id) on delete set null,
  excepcion_autorizada boolean not null default false,
  motivo_excepcion text,
  consentimiento_tutor_aceptado boolean not null default false,
  poomsae_calif int check (poomsae_calif is null or poomsae_calif between 0 and 100),
  kyorugi_calif int check (kyorugi_calif is null or kyorugi_calif between 0 and 100),
  rompimiento_calif int check (rompimiento_calif is null or rompimiento_calif between 0 and 100),
  teoria_calif int check (teoria_calif is null or teoria_calif between 0 and 100),
  aprobado boolean,
  observaciones text,
  evaluado_en timestamptz,
  unique (convocatoria_id, alumno_id)
);

create table if not exists public.productos_equipo (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  nombre text not null,
  categoria text not null check (categoria in ('dobok', 'peto', 'casco', 'espinilleras', 'antebraceras', 'bucal', 'cinta', 'otro')),
  activo boolean not null default true
);

create table if not exists public.variantes_equipo (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  producto_id uuid not null references public.productos_equipo(id) on delete cascade,
  talla text not null,
  precio_centavos int not null check (precio_centavos > 0),
  existencias int not null default 0 check (existencias >= 0)
);

create table if not exists public.pedidos_equipo (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  alumno_id uuid not null references public.alumnos(id) on delete cascade,
  tutor_id uuid not null references public.perfiles_usuario(id) on delete cascade,
  variante_id uuid not null references public.variantes_equipo(id) on delete restrict,
  nombre_producto_snapshot text not null,
  talla_snapshot text not null,
  cantidad int not null check (cantidad > 0),
  precio_unitario_centavos int not null check (precio_unitario_centavos > 0),
  total_centavos int not null check (total_centavos > 0),
  cargo_id uuid references public.cargos_estado_cuenta(id) on delete set null,
  estado_entrega text not null check (estado_entrega in ('pendiente_pago', 'pagado_pendiente_entrega', 'entregado', 'cancelado')),
  creado_en timestamptz not null default now(),
  entregado_en timestamptz
);

create table if not exists public.torneos (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  nombre text not null,
  sede text not null,
  fecha_evento date not null,
  fecha_limite_inscripcion date not null,
  cuota_centavos int not null check (cuota_centavos >= 0),
  abierto boolean not null default true,
  creado_en timestamptz not null default now()
);

create table if not exists public.torneos_inscripciones (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  torneo_id uuid not null references public.torneos(id) on delete cascade,
  alumno_id uuid not null references public.alumnos(id) on delete cascade,
  tutor_id uuid not null references public.perfiles_usuario(id) on delete cascade,
  modalidad text not null check (modalidad in ('kyorugi', 'poomsae', 'ambas')),
  peso_kg_registrado numeric(5,2) not null check (peso_kg_registrado > 0),
  grado_id_al_inscribir uuid not null references public.grados_cinta(id),
  categoria_division text not null,
  responsiva_tutor_aceptada boolean not null default false,
  responsiva_aceptada_en timestamptz,
  cargo_id uuid references public.cargos_estado_cuenta(id) on delete set null,
  medalla text not null default 'ninguna' check (medalla in ('ninguna', 'participacion', 'bronce', 'plata', 'oro')),
  notas_resultado text not null default '',
  unique (torneo_id, alumno_id)
);

-- ----------------------------------------------------------------------------
-- 5. CONSENTIMIENTOS LEGALES (LFPDPPP 2025) Y BITÁCORA DE AUDITORÍA INMUTABLE
-- ----------------------------------------------------------------------------

create table if not exists public.consentimientos_legales (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  tutor_id uuid not null references public.perfiles_usuario(id) on delete cascade,
  declaracion_patria_potestad boolean not null default false,
  acepto_aviso_integral boolean not null default false,
  consentimiento_salud_expreso boolean not null default false,
  consentimiento_foto_interna boolean not null default false,
  consentimiento_promociones boolean not null default false,
  version_aviso text not null,
  ip_origen text,
  registrado_en timestamptz not null default now()
);

create table if not exists public.bitacora_auditoria (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  actor_usuario_id uuid references public.perfiles_usuario(id) on delete set null,
  rol_actor text not null,
  accion text not null,
  entidad text not null,
  registro_id text not null,
  detalle text not null,
  creado_en timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 6. ROW LEVEL SECURITY (RLS) — AISLAMIENTO ESTRICTO MULTI-TENANT Y POR ROL
-- ----------------------------------------------------------------------------

alter table public.academias enable row level security;
alter table public.perfiles_usuario enable row level security;
alter table public.grados_cinta enable row level security;
alter table public.grupos_horarios enable row level security;
alter table public.alumnos enable row level security;
alter table public.tutor_alumnos enable row level security;
alter table public.asistencias enable row level security;
alter table public.conceptos_cobro enable row level security;
alter table public.cargos_estado_cuenta enable row level security;
alter table public.pagos_tickets enable row level security;
alter table public.pagos_detalle enable row level security;
alter table public.examenes_convocatorias enable row level security;
alter table public.examenes_inscripciones enable row level security;
alter table public.productos_equipo enable row level security;
alter table public.variantes_equipo enable row level security;
alter table public.pedidos_equipo enable row level security;
alter table public.torneos enable row level security;
alter table public.torneos_inscripciones enable row level security;
alter table public.consentimientos_legales enable row level security;
alter table public.bitacora_auditoria enable row level security;

-- Academias: lectura para todos los miembros de su academia; edición solo Dueño
create policy "academias_select" on public.academias
  for select using (id = public.mi_academia_id());
create policy "academias_update_dueno" on public.academias
  for update using (id = public.mi_academia_id() and public.mi_rol() = 'dueno');

-- Perfiles: personal lee perfiles de su academia; tutor solo lee el suyo
create policy "perfiles_select" on public.perfiles_usuario
  for select using (
    academia_id = public.mi_academia_id()
    and (public.es_personal_academia() or id = auth.uid())
  );

-- Alumnos: personal ve alumnos de su academia; tutor SOLO ve a sus hijos vinculados
create policy "alumnos_select" on public.alumnos
  for select using (
    academia_id = public.mi_academia_id()
    and (
      public.es_personal_academia()
      or exists (
        select 1 from public.tutor_alumnos ta
        where ta.alumno_id = alumnos.id and ta.tutor_id = auth.uid()
      )
    )
  );
create policy "alumnos_write_caja_dueno" on public.alumnos
  for all using (academia_id = public.mi_academia_id() and public.es_caja_o_dueno());

-- Vínculos tutor_alumnos
create policy "tutor_alumnos_select" on public.tutor_alumnos
  for select using (
    academia_id = public.mi_academia_id()
    and (public.es_personal_academia() or tutor_id = auth.uid())
  );

-- Cargos y Tickets: caja/dueño ven todo de su academia; tutor SOLO ve lo suyo; instructor NO ve finanzas
create policy "cargos_select" on public.cargos_estado_cuenta
  for select using (
    academia_id = public.mi_academia_id()
    and (public.es_caja_o_dueno() or tutor_id = auth.uid())
  );
create policy "cargos_write_caja_dueno" on public.cargos_estado_cuenta
  for all using (academia_id = public.mi_academia_id() and public.es_caja_o_dueno());

create policy "tickets_select" on public.pagos_tickets
  for select using (
    academia_id = public.mi_academia_id()
    and (public.es_caja_o_dueno() or tutor_id = auth.uid())
  );
create policy "tickets_insert_caja_dueno" on public.pagos_tickets
  for insert with check (academia_id = public.mi_academia_id() and public.es_caja_o_dueno());
-- Prohibido borrar tickets; solo el Dueño puede marcar cancelado = true
create policy "tickets_cancelar_solo_dueno" on public.pagos_tickets
  for update using (academia_id = public.mi_academia_id() and public.mi_rol() = 'dueno');

create policy "pagos_detalle_select" on public.pagos_detalle
  for select using (
    academia_id = public.mi_academia_id()
    and (
      public.es_caja_o_dueno()
      or exists (
        select 1 from public.pagos_tickets pt
        where pt.id = pagos_detalle.ticket_id and pt.tutor_id = auth.uid()
      )
    )
  );

-- Catálogos de academia (grados, grupos, equipo, exámenes, torneos): lectura a miembros
create policy "grados_select" on public.grados_cinta for select using (academia_id = public.mi_academia_id());
create policy "grados_write_dueno" on public.grados_cinta for all using (academia_id = public.mi_academia_id() and public.mi_rol() = 'dueno');
create policy "grupos_select" on public.grupos_horarios for select using (academia_id = public.mi_academia_id());
create policy "productos_select" on public.productos_equipo for select using (academia_id = public.mi_academia_id());
create policy "variantes_select" on public.variantes_equipo for select using (academia_id = public.mi_academia_id());
create policy "examenes_select" on public.examenes_convocatorias for select using (academia_id = public.mi_academia_id());
create policy "torneos_select" on public.torneos for select using (academia_id = public.mi_academia_id());

-- Asistencias, inscripciones y pedidos: personal o tutor de sus hijos
create policy "asistencias_select" on public.asistencias
  for select using (
    academia_id = public.mi_academia_id()
    and (
      public.es_personal_academia()
      or exists (select 1 from public.tutor_alumnos ta where ta.alumno_id = asistencias.alumno_id and ta.tutor_id = auth.uid())
    )
  );
create policy "asistencias_insert_personal" on public.asistencias
  for insert with check (academia_id = public.mi_academia_id() and public.es_personal_academia());

create policy "pedidos_select" on public.pedidos_equipo
  for select using (academia_id = public.mi_academia_id() and (public.es_personal_academia() or tutor_id = auth.uid()));
create policy "torneos_insc_select" on public.torneos_inscripciones
  for select using (academia_id = public.mi_academia_id() and (public.es_personal_academia() or tutor_id = auth.uid()));
create policy "examenes_insc_select" on public.examenes_inscripciones
  for select using (
    academia_id = public.mi_academia_id()
    and (
      public.es_personal_academia()
      or exists (select 1 from public.tutor_alumnos ta where ta.alumno_id = examenes_inscripciones.alumno_id and ta.tutor_id = auth.uid())
    )
  );

-- Consentimientos y Bitácora: solo Dueño (y el tutor lee sus propios consentimientos)
create policy "consentimientos_select" on public.consentimientos_legales
  for select using (academia_id = public.mi_academia_id() and (public.mi_rol() = 'dueno' or tutor_id = auth.uid()));
create policy "bitacora_select_dueno" on public.bitacora_auditoria
  for select using (academia_id = public.mi_academia_id() and public.mi_rol() = 'dueno');
create policy "bitacora_insert_miembros" on public.bitacora_auditoria
  for insert with check (academia_id = public.mi_academia_id());

-- ----------------------------------------------------------------------------
-- 7. RPC IDEMPOTENTE PARA SINCRONIZAR COBROS OFFLINE (`sync_outbox`)
-- ----------------------------------------------------------------------------

create or replace function public.procesar_pago_offline(
  p_client_mutation_id text,
  p_folio text,
  p_tutor_id uuid,
  p_metodo_pago text,
  p_referencia_pago text,
  p_total_pagado_centavos int,
  p_codigo_qr text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_academia_id uuid;
  v_ticket_id uuid;
begin
  v_academia_id := public.mi_academia_id();
  if not public.es_caja_o_dueno() or v_academia_id is null then
    raise exception 'Sin permiso para registrar cobros en caja.';
  end if;

  -- Idempotencia: si la mutación ya se sincronizó antes, devuelve el ticket existente
  select id into v_ticket_id
  from public.pagos_tickets
  where academia_id = v_academia_id and client_mutation_id = p_client_mutation_id;

  if v_ticket_id is not null then
    return v_ticket_id;
  end if;

  insert into public.pagos_tickets (
    academia_id, client_mutation_id, folio, tutor_id, cajero_id,
    metodo_pago, referencia_pago, total_pagado_centavos, codigo_verificacion_qr
  ) values (
    v_academia_id, p_client_mutation_id, p_folio, p_tutor_id, auth.uid(),
    p_metodo_pago, p_referencia_pago, p_total_pagado_centavos, p_codigo_qr
  )
  returning id into v_ticket_id;

  return v_ticket_id;
end;
$$;

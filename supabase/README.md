# Backend Multi-Tenant · Mi Doyang by Cupa (Supabase)

Esta carpeta contiene el esquema PostgreSQL oficial con **20 tablas** y **Row Level Security (RLS)** estricto por `academia_id` y por rol (`dueno`, `recepcion`, `instructor`, `tutor`), diseñado en [docs/arquitectura.md](../docs/arquitectura.md) y [docs/privacidad.md](../docs/privacidad.md).

## Cómo desplegar el backend en 3 pasos

1. Crea un proyecto nuevo en [Supabase](https://supabase.com/) (región recomendada: `us-east-1` o `us-west-1` por baja latencia en México).
2. Abre **SQL Editor** en tu proyecto de Supabase, pega el contenido completo de [`migrations/0001_esquema_inicial.sql`](migrations/0001_esquema_inicial.sql) y pulsa **Run**.
3. En **Storage**, crea un bucket **privado** llamado `credenciales-alumnos` (para fotos opcionales y logos con URLs firmadas temporales; nunca público).
4. Copia `.env.example` como `.env` en la raíz de `gestion-academias/` y llena `SUPABASE_URL` y `SUPABASE_ANON_KEY` (clave pública `anon` con RLS activo; nunca uses `service_role` en el cliente).

## Seguridad verificada
- **Multi-tenancy:** Ningún usuario puede consultar ni mutar registros de otra academia (`academia_id = public.mi_academia_id()`).
- **Aislamiento familiar:** Un usuario con rol `tutor` únicamente puede leer los expedientes de sus hijos vinculados en `tutor_alumnos`, sus propios cargos y sus propios tickets.
- **Inmutabilidad de tickets:** No existe política `DELETE` sobre `pagos_tickets`; solo el rol `dueno` puede marcar `cancelado = true` con motivo y folio de reverso.
- **Idempotencia Offline-First:** La función RPC `procesar_pago_offline` deduplica por `(academia_id, client_mutation_id)` al drenar la cola local `sync_outbox`.

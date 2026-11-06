# Deferred migrations

Migrations parked here are **valid and unapplied**. They are not archived history — they
are work that was written, never run, and deliberately postponed.

Files in this folder are invisible to the Supabase CLI: it globs `supabase/migrations/*.sql`,
which does not match subdirectories. Moving a file back up one level makes it pending again.

---

## `20260822060000_factory_optimizer_execution_plane.sql`

**Parked:** 2026-08-25, during the bounded-schema migration.
**Status:** never applied. Applies cleanly as-is — verified 2026-08-25.

Creates the execution plane for the bounded app-factory optimizer:

- `factory_experiment_episode` — paired baseline/candidate membership for bounded experiments
- `factory_champion` — compare-and-swap registry for the active component candidate
- `factory_rollback_execution` — verified rollback receipts
- `promote_factory_champion(...)` — the CAS promotion function
- eight columns added to `factory_canary_result`, plus a partial unique index

### Why it was parked rather than applied

1. **Nothing references it.** A repo-wide search for `factory_champion`,
   `promote_factory_champion`, `factory_experiment_episode` and `factory_rollback_execution`
   finds only this file. No code in `app_factory_agent` or anywhere else calls these tables or
   the CAS function. It is an unwired design, not a missing dependency.
2. **The factory is dormant.** Every `factory_*` row was written in a single 61-minute window on
   2026-08-22 (06:05–07:04 UTC) and nothing has touched it since. This migration is timestamped
   from that same session. `factory_canary_result` and `factory_runtime_event` are both empty.
3. **Namespace.** Applying it would add three more tables and a security-sensitive CAS function
   to `public` at exactly the point where everything else moved into bounded schemas. If the
   factory work resumes it most likely wants its own `factory` schema, so applying now buys
   unused tables in a namespace we would probably change.

### The trap this avoids

While the file sat in `supabase/migrations/`, it was **pending**: a `supabase db push` would have
applied it silently, creating three tables nobody asked for. The 2026-08-25 migration was applied
directly via `pg` rather than `db push`, so it was never triggered — but that was a property of the
method, not a safeguard.

No `supabase migration repair` was needed. The migration has no row in
`supabase_migrations.schema_migrations` because it never ran; `db push` treats a local file with no
history row as pending, so removing it from the glob is the whole fix.

### To resume

```sh
mv supabase/migrations/deferred/20260822060000_factory_optimizer_execution_plane.sql \
   supabase/migrations/
```

Before applying, decide whether these belong in `public` or in a new `factory` schema. If the
latter, rewrite the file against that schema rather than applying it here and moving tables later.

The factory tables it depends on — `factory_experiment`, `factory_experiment_arm`, `factory_task`,
`factory_environment_version`, `factory_episode`, `factory_candidate`, `factory_component_version`,
`factory_promotion_decision`, `factory_canary_result` — all still exist and were untouched by the
2026-08-25 migration.

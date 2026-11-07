# Environment (database variables)

Names only. Source: `config/env.registry.yaml`; values: `BellLabs/.secrets/aieng-db.env` (owner-held, never committed). No aliases and no fallback to the older `POSTGRES_URL*`, `MC_INSTALL_DISPOSABLE_DSN` or `MC_AI_ENGINEER_MIGRATION_DATABASE_URL` names. Non-database variables (`KS_KNOWLEDGE_SEAL_*`, `INSTALL_WIPE_*`, `INSTALL_SEAL_*`, `INSTALL_MANIFEST_DSN`, `AIDB_TEST_*`) are out of scope; the test-only DSN names stay.

Local runs: the package scripts (`install:target`, `install:disposable`, `types:*:native`, `workspace:*`) start Node with `--env-file-if-exists=.env`, so a git-ignored `.env` in this root is read; the process environment wins. Scripts started with a bare `node scripts/...` do not load it. Copy `.env.example`.

| Name | Read by | Unset means |
| --- | --- | --- |
| `AIENG_DB_ADMIN_DSN` | `scripts/install-target.mjs` (the variable named by the MC target's `database_url_env`, `--remote-reinstall` and `wipe`); `scripts/schema-workspace/lib/db.mjs` | remote reinstall/wipe refuse `TARGET_DSN_MISSING`; schema-workspace falls back to `AIENG_DB_LOCAL_DSN`, then refuses `DB_UNREACHABLE` (`validate` runs without a database) |
| `AIENG_DB_LOCAL_DSN` | `scripts/generate-types.mjs`, `generate-types-native.mjs` (native only; the sole database name its child receives); `scripts/install-ai-engineer.mjs` (disposable mode sets it for `mission-db` and the generated `mc-target.toml`); schema-workspace fallback | `types:*:native` throws; a non-loopback value is refused by schema-workspace and by the native generator |
| `AIENG_DB_PROJECT_REF` | nothing yet (declared in the shared `.env`) | no effect |

`AIENG_DB_RUNTIME_DSN`, `AIENG_DB_URL` and `AIENG_DB_SECRET_KEY` are not read by any script here and are intentionally not registered. `KDB_INSTALL_ADMIN_DSN` is the installer's in-run hand-off to the Knowledge Services CLI (set from the resolved target, never an input).

`supabase/config.toml` uses `env(SUPABASE_AUTH_*)` placeholders for the Supabase CLI's local auth providers; they are the CLI's names, not part of this contract.

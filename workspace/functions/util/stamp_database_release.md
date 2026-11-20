---
id: "fn:util.stamp_database_release(text,text,int4,text,jsonb,text)"
kind: function
schema: util
name: stamp_database_release
domain: api-surface
lens: machinery
overloads: ["fn:util.stamp_database_release(text,text,int4,text,jsonb,text)"]
security: definer
volatility: volatile
executors: []
raises: ["release % ends at migration %, but this database is at %"]
touches: { reads: [], writes: [util.database_release] }
tokens: [util, stamp_database_release, util.stamp_database_release]
defined_in: ["20261120120000_database_release_record.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# util.stamp_database_release

Domain `api-surface`, lens `machinery`.

## stamp_database_release(text, text, integer, text, jsonb, text) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Records the release this database was installed or upgraded to. Refuses a head the database is not at; adds a row only when the latest stamp differs. Owner only: the installer (scripts/install-ai-engineer.mjs) and the lab stamp command (scripts/database-release.mjs) call it.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_contract_version` | `text` | — | — |
| `p_migration_head` | `text` | — | — |
| `p_migrations` | `integer` | — | — |
| `p_migrations_sha256` | `text` | — | — |
| `p_components` | `jsonb` | — | — |
| `p_stamped_by` | `text` | — | — |

Execute: no configured role.

Raises (mechanically extracted): `release % ends at migration %, but this database is at %`.

Touches (best effort): reads —; writes [`util.database_release`](../../relations/util/database_release.md); calls —.

TypeScript: `Database["util"]["Functions"]["stamp_database_release"]`.

Defined in: `20261120120000_database_release_record.sql`.

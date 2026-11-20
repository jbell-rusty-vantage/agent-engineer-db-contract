---
id: "rel:util.database_release"
kind: table
schema: util
name: database_release
domain: api-surface
lens: machinery
aliases: []
tokens: [util, database_release, util.database_release, release_seq, contract_version, migration_head, migrations, migrations_sha256, components, stamped_at, stamped_by]
summary: "Which release this database is: one row per stamp, newest last, never edited. A release is the contract version; it names one migration chain and pins the guest components. Written only by util.stamp_database_release; read through api.database_release."
summary_basis: comment
rls: disabled
readers: []
writers: []
typescript: "Database[\"util\"][\"Tables\"][\"database_release\"][\"Row\"]"
defined_in: ["20261120120000_database_release_record.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# util.database_release

table in domain `api-surface`, lens `machinery` — Which release this database is: one row per stamp, newest last, never edited. A release is the contract version; it names one migration chain and pins the guest components. Written only by util.stamp_database_release; read through api.database_release..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `release_seq` | `bigint` | no | — | PK; identity always |
| 2 | `contract_version` | `text` | no | — | The release: the version in the contract repository's contract.version.json. |
| 3 | `migration_head` | `text` | no | — | The last migration of the release's chain, as <14 digits>_<name>. |
| 4 | `migrations` | `integer` | no | — | How many migrations the release's chain holds. |
| 5 | `migrations_sha256` | `text` | no | — | Digest of the chain's file names and contents (line endings folded), as recorded in contract.version.json. |
| 6 | `components` | `jsonb` | no | — | The guest components the release pins, by name: {"knowledge_verification": {"version", "digest"}, "mission_control": {"version", ...}}. |
| 7 | `stamped_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `stamped_by` | `text` | no | — | The tool that stamped the row (the installer, or the lab stamp command). |

## Constraints

- PK (release_seq)
- check `database_release_components_check`: `(jsonb_typeof(components) = 'object'::text)`
- check `database_release_contract_version_check`: `(contract_version ~ '^[0-9]+\.[0-9]+\.[0-9]+$'::text)`
- check `database_release_migration_head_check`: `(migration_head ~ '^[0-9]{14}_[a-z0-9_]+$'::text)`
- check `database_release_migrations_check`: `(migrations > 0)`
- check `database_release_migrations_sha256_check`: `(migrations_sha256 ~ '^sha256:[0-9a-f]{64}$'::text)`
- check `database_release_stamped_by_check`: `((length(stamped_by) >= 1) AND (length(stamped_by) <= 200))`

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

- `database_release_append_only` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Disabled.

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`util.stamp_database_release`](../../functions/util/stamp_database_release.md).

## TypeScript

insert: `Database["util"]["Tables"]["database_release"]["Insert"]`; row: `Database["util"]["Tables"]["database_release"]["Row"]`; update: `Database["util"]["Tables"]["database_release"]["Update"]`

Defined in: `20261120120000_database_release_record.sql`.

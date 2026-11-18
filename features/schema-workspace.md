# Schema workspace

The navigable, generated description of the schema that agents read instead of migrations: `workspace/` (start at
`workspace/manifest.json`, read pages by id, never enumerate the tree). The generator introspects a database into
`schema-ir.v1`, merges the curated enrichment in `workspace-enrichment/`, renders the pages and validates them; scopes in
`workspace-scopes/` materialize a mission-sized subset.

- Code: [`scripts/schema-workspace/`](../scripts/schema-workspace/README.md) (CLI `cli.mjs`, `lib/`), configuration
  [`workspace.config.json`](../workspace.config.json), enrichment [`workspace-enrichment/`](../workspace-enrichment/README.md).
- Tests: `scripts/schema-workspace/test/*.test.mjs`, run by `npm test` (offline, no database).
- Spec: [SCHEMA_WORKSPACE_MATERIALIZATION_SPEC](../docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md) (accepted).

## Drive it

| Command | Does | Needs a database |
| --- | --- | --- |
| `npm run workspace:build -- --db-url <loopback DSN>` | renders and writes `workspace/` | yes |
| `npm run workspace:check -- --db-url <loopback DSN>` | drift between the committed fingerprint and the database | yes |
| `npm run workspace:validate [-- --db-url <loopback DSN>]` | re-renders the committed IR byte for byte; runs catalog examples when a database is given | optional |
| `npm run workspace:materialize -- --scope <id>` | a scope's pages as a tree or JSON bundle | no |

CI runs `workspace:check` and `workspace:validate` with `--db-url postgresql://postgres:postgres@127.0.0.1:54322/postgres`
against the fresh install; on drift it regenerates the tree and uploads it as the `schema-workspace` artifact.

<a id="connection"></a>
## Connection: local by default (since 2026-11-18, OVE-243)

`--db-url` wins. Otherwise a loopback `AIENG_DB_LOCAL_DSN` (a remote value is refused). `AIENG_DB_ADMIN_DSN`, the remote
schema owner, is read only with `--target remote`. With none of them `build`, `check` and `introspect` refuse
`DB_UNREACHABLE` and `validate` runs without a database. Before this change a bare `npm run workspace:check` with the
shared `.env` reached `aieng-db`. Code: [`lib/db.mjs`](../scripts/schema-workspace/lib/db.mjs); test:
`test/db-env.test.mjs`.

## Gotchas

- `workspace/` is generated: edit `workspace-enrichment/` or the generator, never the tree; `workspace:validate`
  rejects any file the generator did not render.
- The workspace records one migration head and one contract version; `npm run version:check` fails when they disagree
  with `contract.version.json` ([version and release](version-and-release.md)).
- On the lab, build from a database whose head equals the migration head (one lab draft per promotion).

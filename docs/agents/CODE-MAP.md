<!-- BEGIN GENERATED: semantic-map -->
# Semantic code map

Generated from reviewed module descriptions and current selected source files. Package dependencies/exports/script names are extracted from manifests; relationships and ownership are authored. This is not a complete import graph or proof that a designed capability is implemented.

Paths below are repository-relative. Use the task routes, then search the module heading. Follow accepted architecture docs for decisions; proposed/reference/deprecated documents retain those labels.

## Task routes

- Change shared schema: [schema](#schema) → [type-generation](#type-generation) → [type-contract](#type-contract)
- Investigate reset restrictions: [reset-guard](#reset-guard)
- Change the schema workspace generator or enrichment: [schema-workspace-generator](#schema-workspace-generator) → [schema](#schema)

## Modules

| Module | Source | Responsibility | State |
|---|---|---|---|
| [type-contract](#type-contract) | src | Type-only Database/API/pre-research exports and provenance constants/helpers. | implemented |
| [schema](#schema) | supabase | Shared Supabase configuration and ordered migration authority. | implemented |
| [type-generation](#type-generation) | scripts | Supabase/native type generation and drift checking. | implemented |
| [reset-guard](#reset-guard) | scripts | Allows reset only for explicitly disposable databases. | implemented |
| [root-installer](#root-installer) | scripts | Ordered, idempotent, interrupt-safe install of an AI Engineer database: pinned knowledge_verification component (KS CLI), domain migrations, custody/grant verification, KS executor seal-key registration (KS CLI `seal-key`), Mission Control common release (mission-db), JSON receipt; plus the confirm-target remote reinstall and the manifest-bounded wipe with dry-run. | implemented |
| [schema-workspace-generator](#schema-workspace-generator) | scripts/schema-workspace | Introspects pg_catalog into schema-ir.v1, merges curated enrichment, renders the committed workspace, and checks or validates drift; owns the committed workspace/ tree (ai-engineer-schema-workspace/3), which is read by id starting at workspace/manifest.json and never enumerated. | implemented |

## type-contract

**src** · module · implemented

Type-only Database/API/pre-research exports and provenance constants/helpers.

**Enter:** [`src/index.ts`](../../src/index.ts), [`src/api.ts`](../../src/api.ts), [`src/pre-research.ts`](../../src/pre-research.ts)
**Interface:** Package exports for pinned database consumers.
**Package:** @aiengineer/database-contract ([`package.json`](../../package.json))
**Export subpaths:** ., ./api, ./pre-research, ./provenance, ./reports. Declared metadata; build outputs are not read.
**Declared internal package dependencies:** none declared
**Other runtime dependencies:** none declared
**Reviewed runtime/data relationships:** none declared
**Checks:** No specific test anchor registered. Package script names: db:migrate, db:reset, db:start, install:disposable, install:target, test, test:installer, typecheck, types:check, types:check:native, types:generate, types:generate:native, workspace:build, workspace:check, workspace:materialize, workspace:validate.
- database.generated.ts is generated output; inspect it explicitly when needed rather than including its full contents in the map.

**Architecture and detailed docs:**

- [reference] [`README.md`](../../README.md) — Schema ownership, local workflow, reset guard, generation
- [reference] [`docs/knowledge-model/SCHEMA-SUMMARY.md`](../../docs/knowledge-model/SCHEMA-SUMMARY.md) — Knowledge model and schema boundaries
- [accepted] [`docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md`](../../docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md) — Schema workspace materialization, knowledge intents, and the three-way experiment

## schema

**supabase** · module · implemented

Shared Supabase configuration and ordered migration authority.

**Enter:** [`supabase/config.toml`](../../supabase/config.toml)
**Interface:** Ordered migrations and database configuration; consumers do not own another shared migration tree.
**Package:** not a standalone package
**Export subpaths:** none declared. Declared metadata; build outputs are not read.
**Declared internal package dependencies:** none declared
**Other runtime dependencies:** none declared
**Reviewed runtime/data relationships:** none declared
**Checks:** [`supabase/tests/verification_evaluation_dataset_manifest.sql`](../../supabase/tests/verification_evaluation_dataset_manifest.sql)

**Architecture and detailed docs:**

- [reference] [`README.md`](../../README.md) — Schema ownership, local workflow, reset guard, generation
- [reference] [`docs/knowledge-model/SCHEMA-SUMMARY.md`](../../docs/knowledge-model/SCHEMA-SUMMARY.md) — Knowledge model and schema boundaries
- [reference] [`docs/knowledge-model/MIGRATION-RESULT.md`](../../docs/knowledge-model/MIGRATION-RESULT.md) — Historical migration proof and limitations
- [accepted] [`docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md`](../../docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md) — Schema workspace materialization, knowledge intents, and the three-way experiment

## type-generation

**scripts** · module · implemented

Supabase/native type generation and drift checking.

**Enter:** [`scripts/generate-types.mjs`](../../scripts/generate-types.mjs), [`scripts/generate-types-native.mjs`](../../scripts/generate-types-native.mjs)
**Interface:** Generation/check scripts with explicit database-target validation.
**Package:** not a standalone package
**Export subpaths:** none declared. Declared metadata; build outputs are not read.
**Declared internal package dependencies:** none declared
**Other runtime dependencies:** none declared
**Reviewed runtime/data relationships:** [schema](#schema), [type-contract](#type-contract)
**Checks:** No specific test anchor registered.

**Architecture and detailed docs:**

- [reference] [`README.md`](../../README.md) — Schema ownership, local workflow, reset guard, generation
- [reference] [`docs/knowledge-model/MIGRATION-RESULT.md`](../../docs/knowledge-model/MIGRATION-RESULT.md) — Historical migration proof and limitations

## reset-guard

**scripts** · module · implemented

Allows reset only for explicitly disposable databases.

**Enter:** [`scripts/reset-disposable-local.mjs`](../../scripts/reset-disposable-local.mjs)
**Interface:** Guarded local reset executable.
**Package:** not a standalone package
**Export subpaths:** none declared. Declared metadata; build outputs are not read.
**Declared internal package dependencies:** none declared
**Other runtime dependencies:** none declared
**Reviewed runtime/data relationships:** none declared
**Checks:** [`scripts/reset-disposable-local.test.mjs`](../../scripts/reset-disposable-local.test.mjs)
- Never use a map or a documentation job to bypass the shared-data reset guard.

**Architecture and detailed docs:**

- [reference] [`README.md`](../../README.md) — Schema ownership, local workflow, reset guard, generation

## root-installer

**scripts** · module · implemented

Ordered, idempotent, interrupt-safe install of an AI Engineer database: pinned knowledge_verification component (KS CLI), domain migrations, custody/grant verification, KS executor seal-key registration (KS CLI `seal-key`), Mission Control common release (mission-db), JSON receipt; plus the confirm-target remote reinstall and the manifest-bounded wipe with dry-run.

**Enter:** [`scripts/install-ai-engineer.mjs`](../../scripts/install-ai-engineer.mjs), [`scripts/install-target.mjs`](../../scripts/install-target.mjs), [`scripts/install-manifest.mjs`](../../scripts/install-manifest.mjs)
**Interface:** node scripts/install-ai-engineer.mjs --workdir <disposable> --component-installation-id <uuid> --mc-installation-id <uuid> [--skip-mission-control], node scripts/install-ai-engineer.mjs --remote-reinstall --target <target.toml> --confirm-target <project_ref>:<installation_id> --component-installation-id <uuid> [--identity-evidence <json>] [--seal-key-id <id> --seal-key-file <pem> [--seal-issuer <name>] [--retire-seal-key-ids <ids>]] [--no-seal-key], node scripts/install-ai-engineer.mjs wipe [--dry-run] --target <target.toml> --confirm-target <project_ref>:<installation_id> [--from-dry-run <receipt>] [--identity-evidence <json>] [--drop-public-extra <names>] [--keep-public-extra <names>] [--allow-extra-relations <names>] [--allow-sessions], node scripts/install-manifest.mjs --admin-dsn-env <NAME> [--check]
**Package:** not a standalone package
**Export subpaths:** none declared. Declared metadata; build outputs are not read.
**Declared internal package dependencies:** none declared
**Other runtime dependencies:** none declared
**Reviewed runtime/data relationships:** [schema](#schema)
**Checks:** [`supabase/tests/legacy_verification_withdrawal.sql`](../../supabase/tests/legacy_verification_withdrawal.sql), [`scripts/install-target.test.mjs`](../../scripts/install-target.test.mjs)
- Disposable Supabase workdirs (disposable-*/vfy-* project id, matching container labels), or an explicit MC target.toml with --remote-reinstall/wipe behind the exact project_ref:installation_id confirmation, credential-endpoint match with TLS, and identity (installation row, exact route, or fresh management-API evidence for a legacy Mission Control).
- Wipe drops only the pinned manifest public/storage objects, the allow-listed schemas (domain, knowledge, Mission Control incl. legacy capability_search) and the CLI ledger; never a database, the public schema, extension-owned objects, buckets or stored objects. install-manifest.json is regenerated from the migrations, never hand-edited.
- Verifies grants and custody owned by migrations; never re-issues component DDL or domain grants.

**Architecture and detailed docs:**

No module-specific architecture document registered. Do not infer a design decision from the folder name.

## schema-workspace-generator

**scripts/schema-workspace** · scripts · implemented

Introspects pg_catalog into schema-ir.v1, merges curated enrichment, renders the committed workspace, and checks or validates drift; owns the committed workspace/ tree (ai-engineer-schema-workspace/3), which is read by id starting at workspace/manifest.json and never enumerated.

**Enter:** [`scripts/schema-workspace/cli.mjs`](../../scripts/schema-workspace/cli.mjs), [`scripts/schema-workspace/lib/pipeline.mjs`](../../scripts/schema-workspace/lib/pipeline.mjs), [`scripts/schema-workspace/lib/ir/build-ir.mjs`](../../scripts/schema-workspace/lib/ir/build-ir.mjs), [`scripts/schema-workspace/lib/render/render-workspace.mjs`](../../scripts/schema-workspace/lib/render/render-workspace.mjs), [`scripts/schema-workspace/lib/validate.mjs`](../../scripts/schema-workspace/lib/validate.mjs), [`scripts/schema-workspace/lib/selection.mjs`](../../scripts/schema-workspace/lib/selection.mjs), [`scripts/schema-workspace/README.md`](../../scripts/schema-workspace/README.md), [`workspace.config.json`](../../workspace.config.json), [`workspace-enrichment/README.md`](../../workspace-enrichment/README.md), [`workspace-enrichment/domains.yaml`](../../workspace-enrichment/domains.yaml), [`workspace-enrichment/queries.yaml`](../../workspace-enrichment/queries.yaml), [`workspace-scopes/db-aware-research.json`](../../workspace-scopes/db-aware-research.json)
**Interface:** cli.mjs: introspect, build, check, validate, materialize, enrich. npm workspace:build, workspace:check, workspace:validate, workspace:materialize. Enrichment also has relations, terminology, tasks, ingestion-rules YAML; scopes also has full.json and ingestion-author.json.
**Package:** not a standalone package
**Export subpaths:** none declared. Declared metadata; build outputs are not read.
**Declared internal package dependencies:** none declared
**Other runtime dependencies:** none declared
**Reviewed runtime/data relationships:** [schema](#schema), [type-contract](#type-contract)
**Checks:** [`scripts/schema-workspace/test/helpers.test.mjs`](../../scripts/schema-workspace/test/helpers.test.mjs)
- workspace/ is generated by npm run workspace:build; edit workspace-enrichment/ or the generator, never the tree.
- workspace/ contains only generator output: CI fails on drift (workspace:check) or on any file the generator did not render (workspace:validate).

**Architecture and detailed docs:**

- [reference] [`README.md`](../../README.md) — Schema ownership, local workflow, reset guard, generation
- [accepted] [`docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md`](../../docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md) — Schema workspace materialization, knowledge intents, and the three-way experiment
- [reference] [`docs/schema-workspace/WORKSPACE_LAYOUT_AND_SAMPLES.md`](../../docs/schema-workspace/WORKSPACE_LAYOUT_AND_SAMPLES.md) — Workspace layout, budgets, and sample artifacts
- [reference] [`docs/schema-workspace/INTENT_AND_EXECUTOR_CONTRACTS.md`](../../docs/schema-workspace/INTENT_AND_EXECUTOR_CONTRACTS.md) — Read, snapshot, plan, receipt, and catalog contracts
- [reference] [`docs/schema-workspace/SKILLS.md`](../../docs/schema-workspace/SKILLS.md) — Draft skill procedures for schema-explore, knowledge-db, and knowledge-ingest
- [reference] [`docs/schema-workspace/EXPERIMENT_PROTOCOL.md`](../../docs/schema-workspace/EXPERIMENT_PROTOCOL.md) — Experiment 3 A/B/C protocol; executed 2026-09-12 in the retired research_ingestion_systems_agent (historical; its SUPABASE_DB_URL is that experiment database, not a contract variable)
<!-- END GENERATED: semantic-map -->

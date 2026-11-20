# Feature map

What a user of this repository (an agent, John, a consumer service) can reach, one file per capability. Each file says
what it does, where its code and tests are, how to drive it, the command that proves it, and its gotchas. Code is the
authority; these files are navigation (SPEC-03 K5, OVE-243). Start every session with `./dev status`.

| Feature | Reach it with | Proven by |
| --- | --- | --- |
| [Install a target](install-a-target.md) | `scripts/install-ai-engineer.mjs` (local disposable, remote reinstall, wipe) | `npm run test:installer`; CI fresh install + repeat |
| [Schema workspace](schema-workspace.md) | `npm run workspace:build\|check\|validate\|materialize` | `npm test` (offline); CI `workspace:check` / `workspace:validate` |
| [SQL suites](sql-suites.md) | `supabase/tests/*.sql` through `psql` on a disposable stack | CI step "SQL suites" |
| [Type generation](type-generation.md) | `npm run types:generate\|types:check` | `npm run typecheck`; CI `generate-types.mjs --check` |
| [Lab schema](lab-schema.md) | `npm run lab:schema` (the lab's current schema as readable pages and TypeScript types, written beside the lab) | `npm test` (rendering, offline) |
| [Version and release](version-and-release.md) | `contract.version.json` and `releases/` (one release number for the database, with the component pins), `npm run version:check`, `npm run pack:contract`; the database states its release (`api.database_release()`), `npm run release:show`, `npm run release:stamp`, the installer's `database-release` step and `--release` | `npm run version:check`; `npm test` (the shared startup-check cases); `supabase/tests/database_release.sql` |
| [Provenance](provenance.md) | `./dev trace show\|check\|build`, the commit-msg hook | `./dev trace check` |
| [Schema change](schema-change.md) | the procedure from draft to remote readback, as practised today | input for John's schema session, not a rule |

The fast gate for any change is `./dev check` (typecheck, `npm test`, `version:check`, the agent-docs check, the
provenance check). The slow commands need a disposable Supabase stack; `./dev slow` prints them with CI's exact command
lines and never runs them.

Database access by plane: `./dev planes list|show P|check` and `./dev db status|schema|query --plane P`, read-only by default, `--plane` always required, DDL always refused and pointed at `scripts/install-ai-engineer.mjs`; the registry is `config/planes.toml` (identities only), copied from Mission Control.

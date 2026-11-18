# Type generation

`src/database.generated.ts` is the TypeScript description of every application schema, generated from an installed
database with the pinned Supabase CLI; `src/index.ts` and `src/api.ts` are the stable type-only entry points consumers
import. Commit each migration and its regenerated types together.

- Code: [`scripts/generate-types.mjs`](../scripts/generate-types.mjs), the native fallback
  [`scripts/generate-types-native.mjs`](../scripts/generate-types-native.mjs) (pinned `@supabase/postgres-meta`).
- Tests: `npm run typecheck` (`tsc --noEmit`) on every change; drift is `--check`.

## Drive it

| Command | Reads |
| --- | --- |
| `node scripts/generate-types.mjs --local --check --workdir=<disposable workdir>` | a running `disposable-*` stack whose container labels match the workdir (what CI runs, with `.ci/disposable`) |
| `npm run types:generate` / `npm run types:check` | the local stack of `supabase/config.toml` (`--local`) |
| `npm run types:generate:native` / `types:check:native` | a loopback `AIENG_DB_LOCAL_DSN`, `postgres` on port 54322 only, read-only sessions |

## Gotchas

- `--project-id <ref>` and `--linked` generate from a cloud project; they need an explicit project identity and are never
  a default.
- `--workdir` refuses a non-disposable project (`DISPOSABLE_PROJECT_REQUIRED`) or a container whose labels name another
  workdir (`DISPOSABLE_CONTAINER_IDENTITY_MISMATCH`).
- `src/api.ts` (argument, result and error-code types of the `api` functions) is written by hand alongside a migration;
  the generator does not produce it.

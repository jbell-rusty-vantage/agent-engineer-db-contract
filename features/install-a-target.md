# Install a target

Builds an AI Engineer database from nothing, or brings one to the current head, in one ordered, idempotent,
interrupt-safe run: the pinned Knowledge Services `knowledge_verification` component, this repository's
`supabase/migrations`, the custody and grant checks (including the closed `api` surface), the KS seal key, the Mission
Control common release, and a JSON receipt (`changed: false` when nothing was applied). It is the only release and
fresh-install path; `db:start`, `db:migrate` and `scripts/apply-disposable-migration.mjs` are development tools.

- Code: [`scripts/install-ai-engineer.mjs`](../scripts/install-ai-engineer.mjs) (steps in its header),
  [`scripts/install-target.mjs`](../scripts/install-target.mjs) (remote gates),
  [`scripts/install-manifest.json`](../scripts/install-manifest.json) (what a wipe may remove).
- Tests: [`scripts/install-target.test.mjs`](../scripts/install-target.test.mjs) (`npm run test:installer`); the
  database-backed cases run only with a loopback `INSTALL_WIPE_PG_ADMIN_DSN` / `INSTALL_SEAL_PG_ADMIN_DSN`.
- Full reference: the README sections "Contract 0.5.0" and "Remote reinstall and wipe" ([README](../README.md#remote-reinstall-and-wipe-sprint-oc-wi-24)).

## Local disposable (the default)

Refuses any workdir whose `project_id` is not `disposable-*` (`DISPOSABLE_PROJECT_REQUIRED`), so the populated shared
`aiengineer` stack is never the target. What CI runs (`./dev slow` prints all of it):

```sh
npx supabase db start --workdir .ci/disposable          # a copy of supabase/config.toml with project_id = "disposable-ci-aidb"
node scripts/install-ai-engineer.mjs --workdir .ci/disposable --ks-root .ci/knowledge-services \
  --component-installation-id 0195f0a0-5b08-7000-8000-0000000c1a1d --skip-mission-control --receipt .ci/install-receipt.json
```

Run it twice: the second receipt must say `changed: false`.

## Remote reinstall (aieng-db, `wkythqbofmckbuoothhn`)

Only with `--remote-reinstall --target <Mission Control deployments/ai-engineer/target.toml> --confirm-target
<project_ref>:<installation_id>`, after `wipe --dry-run` and `wipe --from-dry-run <receipt>`. The gates, in order:

1. `--confirm-target` equals the target file's `<project_ref>:<installation_id>`;
2. the DSN in the variable the target names (`database_url_env`, i.e. `AIENG_DB_ADMIN_DSN`) addresses exactly its
   host, port, user and database, with TLS off loopback;
3. identity: the Mission Control installation rows, or `--identity-evidence` (management API, under 24 h, bound by
   `system_identifier`).

A wipe never drops a database, the `public` schema, buckets or stored objects; it is all-or-nothing against a fresh
dry-run receipt. A remote reinstall needs a seal key (`SEAL_KEY_REQUIRED`) unless `--no-seal-key`.

## Gotchas

- The remote is a separate authority: John's explicit go, resolved from the
  [data-plane registry](../../../docs/navigation/DATA-PLANES-AND-CREDENTIALS.md). About 33,000 paid transcript and
  intent objects live in the same project's Storage; a wipe keeps them, orphaned (counted per bucket in its receipt).
- These gates are unchanged by the kit. The schema workspace's own connection (local by default) is separate:
  [schema workspace](schema-workspace.md#connection).
- Mission Control's [`target.toml`](../../../platform/mission-control/deployments/ai-engineer/target.toml) still says
  `environment = "production"` and `release.lock.json` pins 1.4.2 (schema brief §3 e, m).

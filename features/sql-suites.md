# SQL suites

pgTAP and assertion suites that prove grants, row policies, governed writes, the closed `api` surface and the knowledge
chain on an installed database. Each suite runs in one transaction and rolls back.

- Code: [`supabase/tests/`](../supabase/tests/) (36 `*.sql` suites on 2026-11-18). Not a suite of the loop:
  `research_report_v2_concurrency.mjs` with its fixture module, a manual two-session proof that commits its fixtures.
- Runner: the "SQL suites" step of [`.github/workflows/contract.yml`](../.github/workflows/contract.yml), which runs every
  `*.sql` except six it names with a reason (stale fixtures: `knowledge_model_temporal`,
  `knowledge_service_capture_provenance`, `knowledge_service_governed_indexing`,
  `knowledge_service_publication_retrieval`, `source_native_packet_members`, `verification_evaluation_dataset_manifest`).

## Drive it

On a disposable stack after a fresh install ([install a target](install-a-target.md)):

```sh
docker exec -i supabase_db_disposable-ci-aidb psql -X -U postgres -d postgres -v ON_ERROR_STOP=1 -At -q < supabase/tests/<suite>.sql
```

A suite fails on a psql error, on a pgTAP `not ok`, or when it ran a different number of tests than it planned. Proven
by: CI on `d240fd0` (2026-11-18), 30 passed, 0 failed, 6 left out.

## Gotchas

- A new suite runs by default; leaving one out needs a line with its reason in the workflow.
- `knowledge_model_grants` needs an empty database (it opens a knowledge batch at head 0), so it fails on the populated
  lab and passes on a fresh install.
- Never run suites against the shared `aiengineer` stack or a remote.

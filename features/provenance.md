# Provenance

Every commit since 2026-11-18 traces to the owner's words: it ends with `Refs:` naming a record or issue, and
`Decisions:` / `Docs:` when they apply. The trace reads git, this repository's Markdown, the records held in sibling
checkouts and a cached Linear snapshot; it is derived and never edited. Chain and record formats: Mission Control
[SPEC-02](../../../platform/mission-control/docs/specs/agentic-sdlc-2026-11/SPEC-02-PROVENANCE-CHAIN.md#chain); the kit:
[SPEC-03](../../../platform/mission-control/docs/specs/agentic-sdlc-2026-11/SPEC-03-REPO-KIT.md#parts).

- Code: [`docs/tools/trace.py`](../docs/tools/trace.py) (its docstring lists how it differs from Mission Control's copy),
  hook logic [`scripts/dev/hooks/commit-msg`](../scripts/dev/hooks/commit-msg), CI job `provenance` in
  [`contract.yml`](../.github/workflows/contract.yml).

## Ids a commit may cite

| Id | Resolved from |
| --- | --- |
| `B08-S<n>` (schema session), `D-<n>` (schema decision) | the [review workspace](../../../platform/ai-engineer-research-2026-11-02/schema-units/provenance/records/REVIEW-LEDGER.md): answers `id:` frontmatter, decision tables and headings under `reviews/`. Not a git repository; absent, the id is a note |
| `AS-S<n>`, `AS-D<n>`, `ADR-NNNN` | Mission Control's answers files and `docs/adr/`; absent, a note |
| `OVE-n` | the Linear snapshot `.sdlc/trace/linear-snapshot.json` (git-ignored); without one, shape only |

## Drive it

```sh
./dev trace check                    # records, cited issues and commits since the cutover; warn-only
./dev trace show AS-S9               # the chain around any id, commit SHA or path (--json)
./dev trace build                    # .sdlc/trace/trace.json and COVERAGE.md
./dev trace linear pull              # snapshot through GraphQL; LINEAR_API_KEY from the environment only
./dev hooks install                  # the warn-only commit-msg hook
```

Proven by: `./dev trace check` reports 0 problems on `main`.

## Gotchas

- Warn-only until the owner says block (`SDLC_TRACE=block` makes the hook and the check exit 1).
- No `B08-S<n>` answers file exists yet: the schema session records its first one (brief §2 S0), so a commit citing it
  warns until then.
- Moving the review workspace into this repository (`docs/review/`) would make its records traceable on CI too; that is
  the owner's decision (brief §3 k).

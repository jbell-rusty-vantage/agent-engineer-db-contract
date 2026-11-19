# Lab schema

The current schema of the disposable lab, written beside the lab as pages a person can read and as TypeScript types.
One command reads the running lab database and rewrites the folder; nothing is typed by hand. Asked for by John on
2026-11-18 (B08-S1, D-92): "a current human readable and typescript types output of the current schema in the
disposable lab".

- Code: [`scripts/lab-schema.mjs`](../scripts/lab-schema.mjs). It reuses the schema workspace's introspection
  ([schema workspace](schema-workspace.md)) and the pinned Supabase CLI ([type generation](type-generation.md)).
- Tests: [`scripts/lab-schema.test.mjs`](../scripts/lab-schema.test.mjs), in `npm test` (offline, no database).
- Output: [`11-build04-lab/schema`](../../../platform/ai-engineer-research-2026-11-02/11-build04-lab/schema/README.md)
  in the research folder, which is not a git repository.

## Drive it

```sh
npm run lab:schema                       # the Build 04 lab (disposable-aieng-build04)
npm run lab:schema -- --keep-running     # leave the lab database up afterwards
npm run lab:schema -- --workdir <another disposable workdir> --out <dir>
```

If the lab database is stopped the command starts it (the database container only), and stops it again when it is
done. The volumes are kept.

## What it writes

| File | What it is |
| --- | --- |
| `README.md` | Where the lab schema lives in every form, a stamp (migration heads, counts), and the lab compared with the committed contract workspace |
| `schemas/<schema>.md` | One page per schema: each table and view with its columns, keys, checks, who reads and writes it, and each function with its arguments, result and callers |
| `VOCABULARIES.md` | Every vocabulary row (entity kinds, stream kinds, unit kinds and the rest); since Build 08 most of the domain lives here |
| `database.types.ts` | TypeScript types of the lab database, from `supabase gen types` |
| `STAMP.json` | The stamp and the comparison, for tools |

Proven by: `npm test` (the rendering), and a run on 2026-11-19T01:12Z against `disposable-aieng-build04`: 27 schemas, 298
tables, 52 views, 4,238 columns, 299 functions; lab head `20261116150000`, the same as the repository; the types file is
byte-identical to `src/database.generated.ts`.

## Gotchas

- This is a reading of the lab, not a new authority. A schema change is still written as a migration in this repository;
  `workspace/` and `src/database.generated.ts` are still what a promotion commits.
- A lab that is ahead of or behind the repository is reported in the front page's comparison, not refused. That is how a
  change that was tried on the lab and never promoted becomes visible.
- Only a `disposable-*` project is accepted, and the database container's labels must name that project and workdir
  (`DISPOSABLE_PROJECT_REQUIRED`, `DISPOSABLE_CONTAINER_IDENTITY_MISMATCH`).
- Descriptions on the pages come from the committed workspace enrichment; a relation that exists only on the lab shows
  its database comment, or nothing.

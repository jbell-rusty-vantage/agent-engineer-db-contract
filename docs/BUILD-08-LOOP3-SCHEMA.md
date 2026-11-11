# Build 08 loop 3: library knowledge across releases, anchored digests, talk claims, capabilities at C1

**Status: lab-proven on `disposable-aieng-build04` (2026-11-10/11), determination ADD THESE CHANGES applied in-loop and promoted as [`supabase/migrations/20261110140000_build08_loop3_libraries_talks_capabilities.sql`](../supabase/migrations/20261110140000_build08_loop3_libraries_talks_capabilities.sql). Clean replay on `disposable-aieng-b08replay` (head `20261109130000` to `20261110140000`) gave a schema dump identical to the lab except the dump tokens and the known loop-1 index on `authoring.event`. Not integrated into `ai-engineer-service` or Mission Control, not applied to remote `aieng-db`. Owner review pending (John pre-approved the run on 2026-11-10 and reviews loops 2 and 3 together).** Cycle record: Build 08 §20 in the AI Engineer review workspace (`platform/ai-engineer-research-2026-11-02/10-review-workspace/reviews/BUILD-08-KNOWLEDGE-LOOP.md`).

Units: **RV04** (primary), **RV06, RV10, RV11, RV12** (talks, claims, digests, retrieval), **RV03, RV14** (concepts, course seam), RV23 (capability direction CAP-D1 to CAP-D7, CAP-D12).

## A. What the migration does

No new schema and no new knowledge table. One column, vocabulary rows, views and functions.

| Area | Change |
| --- | --- |
| Symbols (RV04) | `api_symbol` attributes `overloads`, `overload_count`, `uses_external` (one unit per overloaded name); `content.unit_link` kind `imports`; `api.symbol_history(repository, package)` (first and last ingested release per symbol; order by release date, then tag digits); `api.symbol_docs` (symbol to docs sections in one call); `api.api_symbols` reads only the newest surface document with units per (repository, tag, package) and gains `overloads`, `uses_external`, `released_on`, `embedded` |
| Retrieval (RV12) | D-40 repaired: `retrieval.index_text_item` supersedes older active items of the same target and space; `retrieval.supersede_duplicate_items()` is the one-off repair. `retrieval.projection_target.digest_item_id` and target kind `digest_item`: one digest item is one vector item; `api.search_unified` returns it |
| Digests (RV11) | digest item kind `recommendation`; `api.digest_items` (item, anchors, timecode range, video deep link); `api.digest_item_passages(item)`; `api.release_digest(release)` |
| Talks (RV06) | `api.talk_segments` gains `deep_link` (video URL at the segment start; no video bytes); `api.talks_about(entity)` returns three levels: `document`, `summary`, `passage`; `api.unit_entities(node)`; helpers `api.document_work`, `api.timecode_link` |
| Claims (RV10) | `api.claim_surfaces`: claim candidates from talks (speaker, timecode, exact quote, always `proposed`) with the docs sections they concern (`evidence.claim_evidence_link` role `context`) and the recorded reading `appears_consistent`, `appears_inconsistent`, `not_addressed` or `not_compared`. A mismatch is a row in `evidence.claim_conflict`, never a verdict |
| Capabilities (CAP-D12) | identifier schemes `skills_sh`, `oci`, `belllabs`; entity kind `agent_plugin`; relationship kind `bundles`; `listed_in`, `compatible_with`, `backed_by_repository`, `develops`, `about` widened; attribute schema for `agent_skill`; document type `agent_plugin_manifest`; unit kinds `mcp_tool`, `mcp_prompt`, `mcp_resource`, `bundle_file`, `hook_entry`; views `api.mcp_tools`, `api.mcp_prompts`, `api.mcp_resources`, `api.bundle_files`, `api.hook_entries`, `api.capabilities` (custody level C0, C1, C2 read from the manifest document) |

## B. Rules the pipeline applies (not enforced by DDL)

- A model-written digest item is stored only if it cites units that exist in the document. A claim candidate is stored only if its quote is found verbatim in one transcript segment; that segment gives the timecode.
- A reading against the docs is stored only if it rests on a quote found verbatim in the docs section. Otherwise the claim is `not_compared`.
- Capture object paths are derived from the digest (`<tenant>/sha256/<sha>`). Identical bytes share one artifact and one capture.
- A capability at custody level C1 stores the tree manifest (git blob ids) and the entry and configuration files only; each fetched file is checked against its git blob id.
- Older releases are symbol rows without embeddings; only the latest release of each package is embedded (`api.api_symbols.embedded`).

## C. Consumers

[`src/api.ts`](../src/api.ts) gains 14 types; [`src/database.generated.ts`](../src/database.generated.ts) is regenerated; the workspace gained pages for the new views and functions. `api.talk_segments` has one more output column (`deep_link`). `knowledge-db` (Knowledge Services) is still not cut over (RV21).

## D. Scripts

[`scripts/knowledge-lab/loop3_acquire.py`](../scripts/knowledge-lab/loop3_acquire.py), [`loop3_process.py`](../scripts/knowledge-lab/loop3_process.py), [`loop3_digests.py`](../scripts/knowledge-lab/loop3_digests.py) (model: `claude-opus-5-5`), [`loop3_questions.py`](../scripts/knowledge-lab/loop3_questions.py), [`loop3_traversal.py`](../scripts/knowledge-lab/loop3_traversal.py), [`loop3_build_draft.py`](../scripts/knowledge-lab/loop3_build_draft.py). Drafts: `supabase/drafts/20261110140000..20261110140200`.

# Build 02 R1: RV18 private learning workspace — library, connectors, private search, conversations and projects

**Status: schema ACCEPTED by John, 2026-11-05 ("Those are good recommendations. I approve."), with all three recommended choices: separate workspace-scoped private index; notes/wiki/projects/documents as authored works; conversations private to their author by default. Not migrated, not runtime-tested.** Schema-only packet ("approve schema and continue"). Cycle record: [Build 02](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/reviews/BUILD-02-PRIVATE-WORKSPACE.md). Builds on the accepted [Build 01 R1](BUILD-01-R1-SCHEMA.md) and [R2](BUILD-01-R2-SCHEMA.md) schema (25 relations). No migration file, generated type, consumer, connector, index or paid embedding is created by this document.

## A. Model in one paragraph

A person's **workspace** (R1) holds everything private. Native notes, wiki pages, projects and uploaded/added documents are **authored works** with immutable revisions (R1), so citations, history, release and adaptation work the same for them as for course material. A **connection** links a workspace to an external notes system; each selected external page/file is a **connected item** mirrored as a work whose revisions record synchronized states, with one designated editing home and reviewed write-back. Private material is made searchable through a **workspace-scoped passage index** (always lexical, optionally semantic) — never through the tenant-shared content/retrieval tables. **Conversations** are product threads with immutable messages and exact context snapshots, distinct from provider/harness sessions. **Controls** (exclude, semantic indexing, retention) and **removal operations** (tracked deletion) implement the accepted disconnect/exclude/delete distinctions.

### Key reuse finding (source-inspected)

All existing `evidence.*`, `content.*` and `retrieval.*` relations are tenant-scoped with no workspace column (`content.document`, `retrieval.search_projection`, `retrieval.vector_item*`). Students sharing a tenant are therefore not isolated by them. This design keeps a hard rule: **private workspace content never becomes a row in tenant-shared `content.*` or `retrieval.*` tables.** It may appear in `evidence.source` / `source_capture` / `locator` only as custody metadata for a workspace-scoped artifact (`sensitivity='confidential'`, bytes gated by R1 `asset_scope`), as R1 already allows. KS conversion/extraction is called as a capability over those bytes; its outputs return as workspace-scoped artifacts and passages. Promotion of private material into shared knowledge stays an explicit, separate operation (RV09/RV10).

## B. Amendments to accepted Build 01 schema (pre-migration)

| # | Object | Amendment | Why |
| --- | --- | --- | --- |
| W1 | `authoring.workspace` | Add `kind` personal/shared (default shared for existing semantics). Partial UNIQUE `(tenant_id, owner_id) WHERE kind='personal'`; personal workspace is created on first use and cannot change kind or owner | One durable home per person for enrollments (R2 M3), notes and conversations |
| W2 | `authoring.work.kind` | Add `note`, `wiki`, `project`, `document` | Library resources reuse the revision mechanism |
| W3 | `authoring.revision_binding` | Add nullable `target_work_id` (floating reference to a work's current head) allowed only for relations `links_to` (page-to-page/resource links, backlinks) and `contains` (wiki/project organization). Evidence, dependency and release closure relations still require exact targets; `freeze_release` resolves floating links to the then-current head and records them in `release_item` | Wiki navigation and backlinks should not require re-sealing every page on each edit |
| W4 | `authoring.asset_scope` | Add `retention` durable/temporary (default durable) and `expires_at timestamptz?` (required iff temporary). Temporary assets referenced by any sealed revision, release item or (later) submission are rejected or promoted to durable | FC-D30 temporary run files/caches; saved and cited work stays durable |
| W5 | `authoring.work_revision` | One sanctioned transition: **purge** — body replaced by a typed tombstone, `purged_at` + `purged_by_removal_id` set, digest retained (content no longer verifiable, stated). Only `library.removal` may perform it; blocked while the revision is `include`d in a non-revoked offer or retained evidence requires it | EDU-D62 delete must actually remove platform copies; immutability otherwise unchanged |
| W6 | `authoring.event.kind` | Add `sync_conflict`, `write_back_proposed`, `write_back_applied`, `write_back_failed`, `removal_impact_acknowledged` | Connector and deletion history in the existing audit table |
| W7 | `api.course_command` / `api.course_read` | Rename to `api.product_command` / `api.product_read`; same signatures, rules and allowlist mechanism, extended with section F | The boundary now serves library, conversations and projects, not only courses |

## C. New relations

Conventions as R1: `tenant_id, workspace_id` scope with composite FKs, PK `(id)` + UNIQUE `(tenant_id, workspace_id, id)`, `util.uuidv7()`, FORCE RLS, no direct client grants, writes only through `api.product_command` (W7).

### C.1 `library` schema — connections, controls, preparation, passages, removal

| Relation / one row | Columns beyond scope and identity | Keys, checks and lifecycle |
| --- | --- | --- |
| `library.connection` / one authorized link from a workspace to an external notes/document account | `provider text, account_label text, capabilities text[], credential_handle text, status text, connected_by uuid, created_at, disconnected_at timestamptz?, last_error text?` | provider `obsidian` / `notion` / `google_drive` / `local_folder`. capabilities ⊆ read/write/watch, as actually granted by the provider. `credential_handle` names a secret in the approved secret destination; a CHECK rejects token-like values. status active/error/disconnected; disconnect is monotonic (reconnect = new row). Disconnect stops sync and write-back; mirrored works remain, marked by their items |
| `library.connected_item` / one selected external page/file mapped to a local work | `connection_id uuid, external_id text, external_kind text, external_location text, selected_via text, work_id uuid, editing_home text, remote_revision text?, synced_revision_id uuid?, sync_state text, suppressed_at timestamptz?, updated_at` | UNIQUE(scope, connection_id, external_id); UNIQUE(scope, work_id). external_kind page/document/file/folder; selected_via explicit/folder_rule. editing_home external/native (changing it is an explicit command with an event). sync_state in_sync/pending/conflict/unavailable/remote_deleted/disconnected. `synced_revision_id` must be a revision of `work_id`. `suppressed_at` set by deletion prevents a still-connected source recreating the item until explicitly re-added. Mutable current state; history is in `authoring.event` |
| `library.resource_control` / current assistant/search controls for one work | `work_id uuid, excluded_at timestamptz?, excluded_by uuid?, semantic_index boolean, updated_by uuid, updated_at` | PK(scope, work_id). Absent row = not excluded, semantic off. Exclusion is enforced by every search, context assembly, export-to-agent and harness read path, not just hidden in UI. Semantic indexing is an explicit opt-in per work or inherited from a wiki/project via command |
| `library.preparation` / readiness of one stage for one exact revision or artifact | `revision_id uuid?, artifact_id uuid?, stage text, procedure_version text, status text, attempt_count integer, failure_class text?, output_ref jsonb, origin_ref jsonb, updated_at` | Exactly one target. stage `receive` / `convert` / `extract` / `index_lexical` / `index_semantic`. status pending/running/succeeded/failed/skipped. UNIQUE(scope, target, stage, procedure_version). Receipt, conversion and search availability are reported separately; a failed index never marks the upload lost. origin_ref records the actual KS operation/MC run, never invented IDs |
| `library.passage` / one searchable passage of private or released material | `revision_id uuid?, artifact_id uuid?, message_id uuid?, passage_no integer, locator jsonb, text text, language regconfig, tsv tsvector GENERATED, content_sha256 text, procedure_version text, created_at` | Exactly one target. UNIQUE(scope, target, procedure_version, passage_no). `text` ≤ 8,000 characters. locator `aieng.locator.v1`: block id, page, section path, char span, file path, timestamp range. Regenerable projection: replaced wholesale when a new procedure version runs; deleted by removal. Access is inherited from its target at query time (membership, release item disposition, thread visibility, control exclusion). GIN index on `tsv` — the demonstrated core query |
| `library.passage_embedding_1536` / one embedding of a passage in a vector space version | `passage_id uuid, space_version_id uuid, embedding halfvec(1536), embedding_sha256 text, created_at` | PK(scope, passage_id, space_version_id); FK `(tenant_id, space_version_id)` → existing `retrieval.vector_space_version` (model/dims configuration only — no private content enters retrieval tables). HNSW cosine index, following the existing `retrieval.vector_item_embedding_1536` convention. Only for works with `semantic_index`; other dimensions get sibling tables when a model is actually selected |
| `library.removal` / one tracked deletion request and its actual progress | `requested_by uuid, targets jsonb, impact jsonb, impact_acknowledged_event_id uuid?, state text, steps jsonb, created_at, completed_at timestamptz?` | state previewed/acknowledged/in_progress/completed/partial/failed. `impact` lists affected links, conversations, offers, adaptations and separately retained evidence before execution. steps record each copy/derivative/index/byte removal with verified result (purge W5, passage/embedding delete, artifact tombstone + object delete, connected_item suppression). External originals untouched unless explicitly targeted. `completed` only when every step verified; backup purge windows are an implementation contract stated to the user |

### C.2 `conversation` schema — product threads, messages and context

| Relation / one row | Columns beyond scope and identity | Keys, checks and lifecycle |
| --- | --- | --- |
| `conversation.thread` / one durable product conversation | `owner_id uuid, visibility text, title text, purpose text, mode text, origin text, imported_from jsonb?, created_at, archived_at timestamptz?` | visibility private/workspace (default private: only the owner reads, even in a shared workspace). purpose tutor/build/research/authoring/project/general; mode coach/build_with_me (switch is a message event). origin native/import; import requires `imported_from` (provider, external thread id, export digest) and an explicit import command |
| `conversation.message` / one immutable message | `thread_id uuid, seq integer, role text, author_id uuid?, agent_identity text?, client_surface text, content jsonb, content_sha256 text, context_snapshot_id uuid?, runtime_ref jsonb, usage jsonb, created_at, redacted_at timestamptz?, redacted_by_removal_id uuid?` | UNIQUE(scope, thread_id, seq); seq contiguous per thread (serialized). role user/assistant/tool/system_note. client_surface web/harness/import. content `aieng.message.v1`: text parts, attachments by revision/artifact reference, citations to passages/locators, tool-call summaries (never secrets). runtime_ref: harness, provider/model requested and returned, provider session id, MC mission/run ids when real; unknown stays explicit. Redaction (via removal) clears content and passages but keeps seq/digest for thread integrity |
| `conversation.context_snapshot` / exact deduplicated context used for a turn | `digest text, body jsonb, created_at` | UNIQUE(scope, digest). body `aieng.context.v1`: view, course offer/release, activity occurrence, project revision, pinned and excluded items, assist mode, assessment conditions. Immutable |
| `conversation.context_item` / one referenced item inside a snapshot | `snapshot_id uuid, item_key text, reason text, revision_id uuid?, artifact_id uuid?, release_item_id uuid?, passage_id uuid?, offer_id uuid?, part_id uuid?` | UNIQUE(scope, snapshot_id, item_key); exactly one target; reason view/pinned/retrieved/attached. Reverse indexes support deletion impact and "which conversations used this". Access is rechecked whenever an old turn's items are reused or displayed |

**Totals:** 25 Build 01 relations + 11 new = **36** product relations.

### C.3 Removed or merged from older proposals

| Older proposal (`learning_space.*`) | Disposition |
| --- | --- |
| `space` | R1 `authoring.workspace` + W1 kind |
| `resource`, `resource_version` | `authoring.work` / `work_revision` with kinds note/wiki/project/document |
| `resource_representation` | R1 `representation` bindings + `library.preparation` + `library.passage` |
| `resource_link`, `concept_alignment` | R1 bindings (`links_to`/`contains` via W3; `covers` → `corpus.entity`) |
| `project_version`, `project_file` | `project` work revisions; file trees as source-bundle/manifest artifacts; files searchable as passages with path locators |
| `conversation_message` | `conversation.message` + snapshot/items |
| `agent_session`, `agent_run_binding` | Not created. Provider/harness sessions and MC runs are referenced from `message.runtime_ref` and R1 `command.origin_ref`; MC keeps its own `orchestration.agent_session` |

## D. JSON contracts (validated by write function and shared client schema)

- **`aieng.project.v1`** (project revision metadata): brief binding key; repository `{remote_url?, default_branch?, commit?}`; `local_only` paths with availability; source-bundle/manifest binding keys; setup plan (capability selections referencing `corpus.entity` bindings and R2 `runtime_requirement` rows); authority `{allowed_accounts, allowed_operations, spend_limit_usd, currency}` (EDU-D51 default authority, recorded per project; no spend implied by this schema); linked course offer/occurrence references.
- **`aieng.wiki.v1`** (wiki revision metadata): scope course/path/subject with optional offer/entity reference; navigation tree of `contains` binding keys; page templates in use; default semantic-index policy for members.
- **`aieng.note.v1`**: source format markdown/notion_markdown/gdoc_export/obsidian_markdown; unsupported-content markers and truncation warnings preserved from adapters; frontmatter/properties.
- **`aieng.document.v1`** (uploaded/added source): original artifact and capture binding keys, page count, conversion outputs as artifact binding keys; restricted/incomplete capture disclosure.
- **`aieng.locator.v1`**, **`aieng.message.v1`**, **`aieng.context.v1`** as described in C.

## E. Behavior and invariants

1. **Private by construction.** Every library/conversation row is workspace-scoped; threads default private to the owner; learning rows stay learner-only (R1). Teacher or peer access is a separate grant (RV17/RV20), never implied by a shared topic, enrollment or workspace role.
2. **Assistant search runs as the user.** `product_read(operation='search')` executes under `auth.uid()`; there is no service-role bypass path for assistant retrieval. Results are typed and labelled: `private_note`, `uploaded_source`, `course_material` (via R2 release items), `conversation`, `shared_knowledge` (existing KS retrieval under tenant/public visibility), `learner_record` (authoritative structured queries — enrollment/adoption now, attempts/progress when RV16/RV17 land). Semantic similarity never substitutes for authoritative numbers or progress rules.
3. **Hidden evaluator material** never produces passages in any index a learner can query; it lives in non-learner workspaces or `withheld` release items.
4. **Source vs index freshness.** Display both: connected-item remote revision vs `synced_revision_id`, and head revision vs the revision with `index_lexical`/`index_semantic` succeeded. Stale results are labelled, not hidden.
5. **Connector write-back.** Agent/web/harness edits to an externally homed page produce a proposed revision; on review, the adapter writes using the provider's stale-base protection where available (e.g. Google Docs `requiredRevisionId`), reads back the applied content, records `write_back_applied` with the new remote revision, or `sync_conflict`/`write_back_failed` with a revised preview. HTTP success alone is not proof of application.
6. **Disconnect / exclude / delete** stay distinct: disconnect ends sync (connection), exclude removes from search/context (resource_control), delete runs a tracked removal (purge, redaction, passage/embedding and byte deletion, suppression) after impact acknowledgement.
7. **Content is data, not instructions.** Passages and connected pages entering agent context are marked untrusted content; tools never treat retrieved text as authority to act, share or write back.
8. **Projects** carry their authority/budget; actions beyond it require the user. Secrets are handles only. A project revision is fixed; later local edits create new revisions (submissions in RV17 will pin one).
9. **No automatic promotion or mutation of sealed inputs.** Updates to sources, notes or projects never rewrite a sealed revision, a past context snapshot, an MC mission input or a released closure.

## F. API additions

Commands: `ensure_personal_workspace`, `create_connection`, `disconnect`, `select_external_items`, `record_sync` (adapter worker), `set_editing_home`, `propose_write_back`, `apply_write_back` (adapter worker after review), `set_control` (exclude/include, semantic on/off), `register_upload` (R1 asset flow + document work), `record_preparation` (worker), `create_thread`, `append_message`, `import_thread`, `preview_removal`, `confirm_removal`, `record_removal_step` (worker). Reads: `search` (scopes, filters, semantic flag, limit ≤ 50 with cursor), `get_thread`, `list_threads`, `library_tree` (wiki/project navigation with backlinks), `freshness`, `removal_status`, `usage_of` (what references this item). Worker operations require the server worker credential, as R1's asset finalization does.

Limits for the first implementation cycle: 25 MiB/object and 250 MiB/workspace (R1); ≤ 2,000 connected items per connection; ≤ 8,000 characters/passage; search page ≤ 50; message content ≤ 256 KiB. Exceeding a limit is explicit.

## G. Keeping current

| Subject | Trigger and change identity | Affected | User sees |
| --- | --- | --- | --- |
| Connected notes/docs | Provider change feed/webhook/poll (Drive page tokens, aggregated Notion webhooks, Obsidian file watch); identity `(connected_item, remote_revision)`; deletion/permission loss distinct from edit | Mirror work → new revision or conflict; passages re-prepared | Sync state, conflicts with preview, "source changed since indexed" |
| Shared sources cited by private notes/projects | R1 `change_detected` on bound captures/claims (correction, retraction, access loss) | Note/project revisions via bindings | Proposed revision; old revision intact |
| Project runtime pins | R2 `runtime_requirement` watch | Project revisions | Same change view as course runtime pins |
| Embedding model / procedure | New `vector_space_version` or passage procedure version | Opted-in passages | Re-index offered; old index serves until replaced; no automatic paid re-embedding |
| Context reuse | Access/removal changes after a conversation selected an item | `context_item` | Item shown as no longer available; never silently re-included |

Manual refresh first; dedupe as R1; existing orchestration owns schedules and notification delivery. No watch, connector or webhook is started by this schema.

## H. Scope boundaries and staged residuals

Complete in design here: personal/shared workspaces, notes/wiki/project/document resources, connector mirror/sync/write-back state for all four named systems, private lexical and optional semantic search, typed multi-scope search results, conversations with context snapshots and native import, project authority/setup records, controls, tracked deletion, temporary retention.

Staged, with seams: portable workspace export/import format and identity reconciliation (RV19; everything above is workspace-enumerable and excludes secrets); youth/parent scope and retention windows (RV20); teacher/peer grants on learner evidence (RV17/RV20); learner goals/progress records in search (RV16/RV17); promotion of private material into shared knowledge (RV09/RV10); live E2E viewer and runner sessions (RV17/RV23–25); MC-executed assistant turns beyond reference recording (RV22–RV24).

## I. Migration plan effect

Add one file after Build 01's three: `…010300_private_workspace_library.sql` (W1–W6, eleven relations, indexes including GIN `tsv` and HNSW, artifact type codes `uploaded_document`, `converted_document`, `project_bundle`), with operations added to the API-security migration. Reverse indexes on every binding/context target, `connected_item(work_id)`, `preparation(target, stage)`, `message(thread_id, seq)`, `thread(owner_id, created_at)`. Generated types, `src/course.ts` → `src/product.ts` exports and workspace enrichment follow R1's plan.

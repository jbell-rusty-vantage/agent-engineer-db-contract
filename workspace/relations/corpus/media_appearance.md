---
id: "rel:corpus.media_appearance"
kind: table
schema: corpus
name: media_appearance
domain: relationships
aliases: []
tokens: [corpus, media_appearance, corpus.media_appearance, id, tenant_id, media_work_id, entity_id, role, start_ms, end_ms, locator_id, method, confidence, primary_claim_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"media_appearance\"][\"Row\"]"
defined_in: ["20260912010300_km_03_relationship.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.media_appearance

table in domain `relationships`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `media_work_id` | `uuid` | no | — | FK → [`corpus.media_work`](media_work.md).id |
| 4 | `entity_id` | `uuid` | no | — | FK → [`corpus.entity`](entity.md).id |
| 5 | `role` | `text` | no | — | — |
| 6 | `start_ms` | `integer` | yes | — | — |
| 7 | `end_ms` | `integer` | yes | — | — |
| 8 | `locator_id` | `uuid` | yes | — | FK → [`evidence.locator`](../evidence/locator.md).id |
| 9 | `method` | `text` | no | — | — |
| 10 | `confidence` | `numeric(5,4)` | yes | — | — |
| 11 | `primary_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `media_appearance_check`: `((end_ms IS NULL) OR ((start_ms IS NOT NULL) AND (end_ms >= start_ms)))`
- check `media_appearance_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`
- check `media_appearance_method_check`: `(method = ANY (ARRAY['platform_metadata'::text, 'speaker_diarization'::text, 'asr_ner'::text, 'vision_model'::text, 'ocr'::text, 'manual'::…`
- check `media_appearance_role_check`: `(role = ANY (ARRAY['speaker'::text, 'host'::text, 'guest'::text, 'interviewee'::text, 'panelist'::text, 'subject'::text, 'demonstrated'::te…`

## Relationships

Outbound: `entity_id` → [`corpus.entity`](entity.md)`.id` (+tenant); `locator_id` → [`evidence.locator`](../evidence/locator.md)`.id` (+tenant); `media_work_id` → [`corpus.media_work`](media_work.md)`.id` (+tenant); `primary_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant).
Inbound: none.

## Indexes

`media_appearance_tenant_id_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["corpus"]["Tables"]["media_appearance"]["Insert"]`; row: `Database["corpus"]["Tables"]["media_appearance"]["Row"]`; update: `Database["corpus"]["Tables"]["media_appearance"]["Update"]`

Defined in: `20260912010300_km_03_relationship.sql`.

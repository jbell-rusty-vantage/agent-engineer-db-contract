---
id: "fn:api.search_knowledge(text,halfvec,text[],int2[],text[],text[],text[],uuid[],timestamptz,text[],text[],int4,int4,int4,float8,bool)"
kind: function
schema: api
name: search_knowledge
domain: api-surface
lens: corpus
overloads: ["fn:api.search_knowledge(text,halfvec,text[],int2[],text[],text[],text[],uuid[],timestamptz,text[],text[],int4,int4,int4,float8,bool)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [search_knowledge reads the corpus and evidence lenses only]
touches: { reads: [], writes: [] }
tokens: [api, search_knowledge, api.search_knowledge]
defined_in: ["20261115130000_build08_d82_signed_in_knowledge_reads.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# api.search_knowledge

Domain `api-surface`, lens `corpus`.

## search_knowledge(text, halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamp with time zone, text[], text[], integer, integer, integer, double precision, boolean) → TABLE(vector_item_id uuid, lens text, source_tier smallint, content_kind text, document_type_code text, unit_kind text, entity_id uuid, document_id uuid, document_version_id uuid, target_kind text, target_id uuid, workspace_id uuid, snippet text, start_ms integer, end_ms integer, observed_at timestamp with time zone, valid_during tstzrange, space_slug text, fused_score double precision, channel_scores jsonb)

function, stable, security definer, language plpgsql, config `search_path=""`. Search of the shared industry knowledge for a signed-in session (D-82): api.search_unified restricted to the corpus and evidence lenses, with no workspace parameter; any other lens is refused. Private notes and released course material are read through api.product_read('search'), which derives the scope from the caller's identity.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_query` | `text` | — | — |
| `p_query_embedding` | `halfvec` | `NULL::halfvec` | — |
| `p_lenses` | `text[]` | `ARRAY['corpus'::text, 'evidence'::text]` | — |
| `p_tiers` | `smallint[]` | `NULL::smallint[]` | — |
| `p_space_slugs` | `text[]` | `NULL::text[]` | — |
| `p_document_types` | `text[]` | `NULL::text[]` | — |
| `p_unit_kinds` | `text[]` | `NULL::text[]` | — |
| `p_entity_ids` | `uuid[]` | `NULL::uuid[]` | — |
| `p_as_of` | `timestamp with time zone` | `NULL::timestamp with time zone` | — |
| `p_source_roles` | `text[]` | `NULL::text[]` | — |
| `p_content_kinds` | `text[]` | `NULL::text[]` | — |
| `p_limit` | `integer` | `20` | — |
| `p_candidate_limit` | `integer` | `100` | — |
| `p_rrf_k` | `integer` | `60` | — |
| `p_evidence_weight` | `double precision` | `0.15` | — |
| `p_collapse` | `boolean` | `true` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `search_knowledge reads the corpus and evidence lenses only`.

Touches (best effort): reads —; writes —; calls [`api.search_unified`](search_unified.md).

TypeScript: `Database["api"]["Functions"]["search_knowledge"]`.

Defined in: `20261115130000_build08_d82_signed_in_knowledge_reads.sql`.

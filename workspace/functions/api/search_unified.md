---
id: "fn:api.search_unified(text,halfvec,text[],int2[],text[],text[],text[],uuid[],timestamptz,uuid[],text[],text[],int4,int4,int4,float8)"
kind: function
schema: api
name: search_unified
domain: api-surface
lens: corpus
overloads: ["fn:api.search_unified(text,halfvec,text[],int2[],text[],text[],text[],uuid[],timestamptz,uuid[],text[],text[],int4,int4,int4,float8)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [evidence weight must be between 0 and 1, query text length must be between 1 and 4096, result/candidate bounds are invalid]
touches: { reads: [retrieval.projection_target, retrieval.vector_item, retrieval.vector_item_embedding_1536, retrieval.vector_space, retrieval.vector_space_version], writes: [] }
tokens: [api, search_unified, api.search_unified]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", "20261108120100_build08_r2_fixups.sql", "20261110140000_build08_loop3_libraries_talks_capabilities.sql", "20261113160000_build08_loop5_followups.sql", "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql", part3_retrieval.sql]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# api.search_unified

Domain `api-surface`, lens `corpus`.

## search_unified(text, halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamp with time zone, uuid[], text[], text[], integer, integer, integer, double precision) → TABLE(vector_item_id uuid, lens text, source_tier smallint, content_kind text, document_type_code text, unit_kind text, entity_id uuid, document_id uuid, document_version_id uuid, target_kind text, target_id uuid, workspace_id uuid, snippet text, start_ms integer, end_ms integer, observed_at timestamp with time zone, valid_during tstzrange, space_slug text, fused_score double precision, channel_scores jsonb)

function, stable, security definer, language plpgsql, config `search_path=""`. One search stack: RRF over FTS + trigram + ANN within lens/tier/space/facet filters, a small source-tier boost, and (loop 5, D-62) an evidence factor 1 + weight x signal from retrieval.evidence_signal, reported as channel_scores.evidence (signal, verdict, status, weight, factor). Weight 0 reproduces the loop-4 order. Rank, authority and verdict stay separate fields.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_query` | `text` | — | — |
| `p_query_embedding` | `halfvec` | `NULL::halfvec` | — |
| `p_lenses` | `text[]` | `ARRAY['corpus'::text, 'ours'::text]` | — |
| `p_tiers` | `smallint[]` | `NULL::smallint[]` | — |
| `p_space_slugs` | `text[]` | `NULL::text[]` | — |
| `p_document_types` | `text[]` | `NULL::text[]` | — |
| `p_unit_kinds` | `text[]` | `NULL::text[]` | — |
| `p_entity_ids` | `uuid[]` | `NULL::uuid[]` | — |
| `p_as_of` | `timestamp with time zone` | `NULL::timestamp with time zone` | — |
| `p_workspace_ids` | `uuid[]` | `NULL::uuid[]` | — |
| `p_source_roles` | `text[]` | `NULL::text[]` | — |
| `p_content_kinds` | `text[]` | `NULL::text[]` | — |
| `p_limit` | `integer` | `20` | — |
| `p_candidate_limit` | `integer` | `100` | — |
| `p_rrf_k` | `integer` | `60` | — |
| `p_evidence_weight` | `double precision` | `0.15` | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `evidence weight must be between 0 and 1`; `query text length must be between 1 and 4096`; `result/candidate bounds are invalid`.

Touches (best effort): reads [`retrieval.projection_target`](../../relations/retrieval/projection_target.md), [`retrieval.vector_item`](../../relations/retrieval/vector_item.md), [`retrieval.vector_item_embedding_1536`](../../relations/retrieval/vector_item_embedding_1536.md), [`retrieval.vector_space`](../../relations/retrieval/vector_space.md), [`retrieval.vector_space_version`](../../relations/retrieval/vector_space_version.md); writes —; calls [`retrieval.evidence_signal`](../retrieval/evidence_signal.md), [`util.default_tenant_id`](../util/default_tenant_id.md).

Named queries: `q:retrieval.search_unified`.

TypeScript: `Database["api"]["Functions"]["search_unified"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `20261108120100_build08_r2_fixups.sql`, `20261110140000_build08_loop3_libraries_talks_capabilities.sql`, `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`, `part3_retrieval.sql`.

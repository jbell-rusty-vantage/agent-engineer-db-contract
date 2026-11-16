---
id: "fn:api.fact_locators(uuid,text,text)"
kind: function
schema: api
name: fact_locators
domain: api-surface
lens: corpus
overloads: ["fn:api.fact_locators(uuid,text,text)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [content.document_node, evidence.claim, evidence.extraction_record, evidence.locator, evidence.segment_support, evidence.source, evidence.source_capture, temporal.segment, temporal.stream], writes: [] }
tokens: [api, fact_locators, api.fact_locators]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.fact_locators

Domain `api-surface`, lens `corpus`.

## fact_locators(uuid, text, text) → TABLE(segment_id uuid, scope_key text, amount numeric, currency text, unit text, status text, payload jsonb, valid_during tstzrange, claim_id uuid, claim_statement text, locator_id uuid, selector_kind text, selector jsonb, normalized_value text, capture_id uuid, captured_at timestamp with time zone, request_url text, source_url text, document_node_id uuid, unit_kind text, logical_key text)

function, stable, security definer, language sql, config `search_path=""`. L1->evidence: a current fact with its claim, exact locator (selector + normalized value), the capture (URL, time) and the typed unit it was read from.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |
| `p_stream_kind` | `text` | — | — |
| `p_scope_key` | `text` | `NULL::text` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`content.document_node`](../../relations/content/document_node.md), [`evidence.claim`](../../relations/evidence/claim.md), [`evidence.extraction_record`](../../relations/evidence/extraction_record.md), [`evidence.locator`](../../relations/evidence/locator.md), [`evidence.segment_support`](../../relations/evidence/segment_support.md), [`evidence.source`](../../relations/evidence/source.md), [`evidence.source_capture`](../../relations/evidence/source_capture.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:facts.locators`.

TypeScript: `Database["api"]["Functions"]["fact_locators"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.

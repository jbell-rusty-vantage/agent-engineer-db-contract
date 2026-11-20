---
id: "rel:api.benchmark_scores#details"
kind: details
schema: api
name: benchmark_scores
of: "rel:api.benchmark_scores"
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.benchmark_scores — details

Spill-over from [the main page](benchmark_scores.md).

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## View definition

```sql
SELECT s.id AS segment_id,
    st.subject_entity_id AS subject_id,
    sub.display_name AS subject,
    sub.kind AS subject_kind,
    s.ref_entity_id AS benchmark_version_id,
    b.display_name AS benchmark_version,
    COALESCE(bb.id,
        CASE
            WHEN b.kind = 'benchmark'::text THEN b.id
            ELSE NULL::uuid
        END) AS benchmark_id,
    COALESCE(bb.display_name,
        CASE
            WHEN b.kind = 'benchmark'::text THEN b.display_name
            ELSE NULL::text
        END) AS benchmark,
    s.amount AS score,
    s.unit,
    s.payload ->> 'harness'::text AS harness,
    s.payload ->> 'setting'::text AS setting,
    s.payload ->> 'reported_by'::text AS reported_by,
    s.payload ->> 'source_kind'::text AS source_kind,
    (s.payload ->> 'cost_usd'::text)::numeric AS cost_usd,
    s.payload ->> 'run_date'::text AS run_date,
    (s.payload ->> 'n_tasks'::text)::integer AS n_tasks,
    s.payload ->> 'reasoning_effort'::text AS reasoning_effort,
    s.payload AS conditions,
    lower(s.valid_during) AS valid_from,
    s.k_from AS learned_k,
    s.created_at AS observed_at,
    s.primary_claim_id AS claim_id,
    s.belief,
    st.scope_key
   FROM temporal.segment s
     JOIN temporal.stream st ON st.id = s.stream_id
     JOIN catalog.entity sub ON sub.id = st.subject_entity_id
     LEFT JOIN catalog.entity b ON b.id = s.ref_entity_id
     LEFT JOIN catalog.relationship vr ON vr.from_entity_id = b.id AND vr.kind = 'version_of'::text AND vr.k_to IS NULL
     LEFT JOIN catalog.entity bb ON bb.id = vr.to_entity_id AND bb.kind = 'benchmark'::text
  WHERE s.tenant_id = util.current_tenant_id() AND st.kind = 'benchmark_score'::text AND s.k_to IS NULL;
```

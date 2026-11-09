---
id: "rel:api.benchmark_scores#details"
kind: details
schema: api
name: benchmark_scores
of: "rel:api.benchmark_scores"
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
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
    s.ref_entity_id AS benchmark_id,
    b.display_name AS benchmark,
    s.amount AS score,
    s.unit,
    s.payload ->> 'setting'::text AS setting,
    s.payload ->> 'source_kind'::text AS source_kind,
    lower(s.valid_during) AS valid_from,
    s.k_from AS learned_k,
    s.created_at AS observed_at,
    s.primary_claim_id AS claim_id,
    s.belief
   FROM temporal.segment s
     JOIN temporal.stream st ON st.id = s.stream_id
     JOIN catalog.entity sub ON sub.id = st.subject_entity_id
     LEFT JOIN catalog.entity b ON b.id = s.ref_entity_id
  WHERE s.tenant_id = util.current_tenant_id() AND st.kind = 'benchmark_score'::text AND s.k_to IS NULL;
```

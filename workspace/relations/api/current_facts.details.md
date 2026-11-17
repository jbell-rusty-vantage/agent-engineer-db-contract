---
id: "rel:api.current_facts#details"
kind: details
schema: api
name: current_facts
of: "rel:api.current_facts"
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.current_facts — details

Spill-over from [the main page](current_facts.md).

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
SELECT id,
    tenant_id,
    stream_id,
    valid_during,
    belief,
    temporal_basis,
    status,
    amount,
    currency,
    unit,
    ref_entity_id,
    payload,
    extent_id,
    caused_by_event_id,
    replaces_segment_id,
    primary_claim_id,
    k_from,
    k_to,
    created_at,
    stream_kind,
    subject_entity_id,
    subject_relationship_id,
    scope_key
   FROM api.current_fact_rows() current_fact_rows(id, tenant_id, stream_id, valid_during, belief, temporal_basis, status, amount, currency, unit, ref_entity_id, payload, extent_id, caused_by_event_id, replaces_segment_id, primary_claim_id, k_from, k_to, created_at, stream_kind, subject_entity_id, subject_relationship_id, scope_key);
```

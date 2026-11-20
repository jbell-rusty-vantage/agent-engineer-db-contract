---
id: "rel:api.current_facts#details"
kind: details
schema: api
name: current_facts
of: "rel:api.current_facts"
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
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
    scope_key,
    revision_kind,
    correction_reason
   FROM api.current_fact_rows() current_fact_rows(id, tenant_id, stream_id, valid_during, belief, temporal_basis, status, amount, currency, unit, ref_entity_id, payload, extent_id, caused_by_event_id, replaces_segment_id, primary_claim_id, k_from, k_to, created_at, stream_kind, subject_entity_id, subject_relationship_id, scope_key, revision_kind, correction_reason);
```

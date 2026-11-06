---
id: "rel:api.current_facts#details"
kind: details
schema: api
name: current_facts
of: "rel:api.current_facts"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
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
    specification_id,
    stream_kind,
    subject_entity_id,
    subject_relationship_id,
    scope_key
   FROM api.current_fact_rows() current_fact_rows(id, tenant_id, stream_id, valid_during, belief, temporal_basis, status, amount, currency, unit, ref_entity_id, payload, extent_id, caused_by_event_id, replaces_segment_id, primary_claim_id, k_from, k_to, created_at, specification_id, stream_kind, subject_entity_id, subject_relationship_id, scope_key);
```

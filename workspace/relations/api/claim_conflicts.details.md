---
id: "rel:api.claim_conflicts#details"
kind: details
schema: api
name: claim_conflicts
of: "rel:api.claim_conflicts"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.claim_conflicts — details

Spill-over from [the main page](claim_conflicts.md).

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
SELECT x.id AS conflict_id,
    x.conflict_kind,
    x.detected_by,
    x.detected_at,
    a.id AS first_party_claim_id,
    a.statement AS first_party_statement,
    a.status::text AS first_party_status,
    b.id AS other_claim_id,
    b.statement AS other_statement,
    b.status::text AS other_status,
    b.structured ->> 'source_role'::text AS other_source_role,
    b.structured ->> 'provenance'::text AS other_provenance,
    ( SELECT r.outcome
           FROM evidence.conflict_reconciliation r
          WHERE r.conflict_id = x.id
          ORDER BY r.decided_at DESC
         LIMIT 1) AS reconciliation
   FROM evidence.claim_conflict x
     JOIN evidence.claim a ON a.id = x.claim_a_id
     JOIN evidence.claim b ON b.id = x.claim_b_id
  WHERE a.tenant_id = util.current_tenant_id();
```

---
id: "rel:api.claim_triage#details"
kind: details
schema: api
name: claim_triage
of: "rel:api.claim_triage"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.claim_triage — details

Spill-over from [the main page](claim_triage.md).

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
SELECT t.claim_id,
    c.statement,
    c.claim_type,
    c.status::text AS status,
    t.disposition,
    t.checkability,
    t.priority,
    t.components,
    t.rationale,
    p.slug AS probe,
    t.duplicate_of_claim_id,
    t.decided_by,
    t.review_state,
    t.decided_at,
    ( SELECT v.verdict::text AS verdict
           FROM verification.probe_verdict v
          WHERE v.claim_id = t.claim_id
          ORDER BY v.decided_at DESC
         LIMIT 1) AS verdict
   FROM verification.claim_triage t
     JOIN evidence.claim c ON c.id = t.claim_id
     LEFT JOIN verification.probe p ON p.id = t.probe_id
  WHERE t.tenant_id = util.current_tenant_id() AND NOT (EXISTS ( SELECT 1
           FROM verification.claim_triage w
          WHERE w.supersedes_id = t.id));
```

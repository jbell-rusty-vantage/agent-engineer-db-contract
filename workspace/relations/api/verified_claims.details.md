---
id: "rel:api.verified_claims#details"
kind: details
schema: api
name: verified_claims
of: "rel:api.verified_claims"
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.verified_claims — details

Spill-over from [the main page](verified_claims.md).

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
SELECT c.id AS claim_id,
    c.statement,
    c.claim_type,
    r.id AS receipt_id,
    r.use_decision_id,
    r.bound_effect_digest,
    r.applied_at AS verified_at,
    r.executor_version,
    i.payload AS effect,
    ( SELECT jsonb_agg(jsonb_build_object('probe', p.slug, 'verdict', v.verdict, 'review_state', v.review_state) ORDER BY p.slug) AS jsonb_agg
           FROM verification.probe_verdict v
             JOIN verification.probe p ON p.id = v.probe_id
          WHERE v.claim_id = c.id AND NOT (EXISTS ( SELECT 1
                   FROM verification.probe_verdict w
                  WHERE w.supersedes_id = v.id))) AS verdicts
   FROM evidence.claim c
     JOIN orchestration.operation_receipt_target t ON t.claim_id = c.id AND t.action = 'verified'::text
     JOIN orchestration.operation_receipt r ON r.id = t.receipt_id
     JOIN orchestration.operation_intent i ON i.id = r.intent_id
  WHERE c.tenant_id = util.current_tenant_id() AND c.status::text = 'verified'::text;
```

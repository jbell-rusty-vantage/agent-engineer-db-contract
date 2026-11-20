---
id: "rel:api.claim_restatements#details"
kind: details
schema: api
name: claim_restatements
of: "rel:api.claim_restatements"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.claim_restatements — details

Spill-over from [the main page](claim_restatements.md).

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
SELECT r.id AS claim_id,
    r.statement,
    r.status::text AS status,
    (r.structured ->> 'qualified'::text)::boolean AS qualified,
    r.structured ->> 'dropped'::text AS dropped,
    r.structured ->> 'probe'::text AS probe,
    o.id AS original_claim_id,
    o.statement AS original_statement,
    o.status::text AS original_status,
    r.created_at
   FROM evidence.claim r
     JOIN evidence.claim o ON o.id = r.atomized_from_id
  WHERE (r.structured ->> 'path'::text) = 'restatement'::text;
```

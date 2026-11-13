---
id: "rel:api.claim_verdicts#details"
kind: details
schema: api
name: claim_verdicts
of: "rel:api.claim_verdicts"
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# api.claim_verdicts — details

Spill-over from [the main page](claim_verdicts.md).

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
    c.status::text AS status,
    c.structured ->> 'stated_at'::text AS stated_at,
    c.structured ->> 'quote'::text AS quote,
    ( SELECT string_agg(DISTINCT x.display_name, '; '::text) AS string_agg
           FROM evidence.attribution a
             JOIN catalog.entity x ON x.id = a.entity_id
          WHERE a.claim_id = c.id) AS stated_by,
    ( SELECT string_agg(DISTINCT ch.display_name, '; '::text) AS string_agg
           FROM evidence.attribution a
             JOIN evidence.source s ON s.id = a.source_id
             JOIN catalog.entity ch ON ch.id = s.channel_entity_id
          WHERE a.claim_id = c.id) AS channel,
    v.verdict::text AS verdict,
    p.slug AS probe,
    v.review_state,
    v.decided_by,
    v.decided_at,
    v.cells,
    v.rationale
   FROM evidence.claim c
     JOIN LATERAL ( SELECT v_1.id,
            v_1.tenant_id,
            v_1.claim_id,
            v_1.probe_id,
            v_1.verdict,
            v_1.cells,
            v_1.rationale,
            v_1.decided_by,
            v_1.review_state,
            v_1.decided_at,
            v_1.supersedes_id
           FROM verification.probe_verdict v_1
          WHERE v_1.claim_id = c.id
          ORDER BY v_1.decided_at DESC
         LIMIT 1) v ON true
     JOIN verification.probe p ON p.id = v.probe_id;
```

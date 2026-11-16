---
id: "rel:api.source_track_record#details"
kind: details
schema: api
name: source_track_record
of: "rel:api.source_track_record"
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# api.source_track_record — details

Spill-over from [the main page](source_track_record.md).

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
SELECT a.entity_id AS source_entity_id,
    x.display_name AS source,
    x.kind AS source_kind,
    c.id AS claim_id,
    c.statement,
    c.status::text AS status,
    c.structured ->> 'stated_at'::text AS stated_at,
    c.structured ->> 'first_party_at'::text AS first_party_at,
    v.verdict::text AS verdict,
    p.slug AS probe
   FROM evidence.attribution a
     JOIN catalog.entity x ON x.id = a.entity_id
     JOIN evidence.claim c ON c.id = a.claim_id
     LEFT JOIN LATERAL ( SELECT v_1.id,
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
     LEFT JOIN verification.probe p ON p.id = v.probe_id;
```

---
id: "rel:api.community_claims#details"
kind: details
schema: api
name: community_claims
of: "rel:api.community_claims"
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# api.community_claims — details

Spill-over from [the main page](community_claims.md).

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
    c.structured ->> 'quote'::text AS quote,
    c.structured ->> 'stated_at'::text AS stated_at,
    ch.slug AS channel_slug,
    ch.display_name AS channel,
    x.display_name AS stated_by,
    x.kind AS stated_by_kind,
    so.canonical_url AS thread_url,
    d.canonical_title AS thread,
    d.attributes ->> 'thread_state'::text AS thread_state,
    ( SELECT array_agg(e.slug) AS array_agg
           FROM evidence.claim_subject cs
             JOIN catalog.entity e ON e.id = cs.entity_id
          WHERE cs.claim_id = c.id) AS subjects,
    c.structured ->> 'producer'::text AS extracted_by,
    ( SELECT v.verdict::text AS verdict
           FROM verification.probe_verdict v
          WHERE v.claim_id = c.id
          ORDER BY v.decided_at DESC
         LIMIT 1) AS verdict
   FROM evidence.claim c
     JOIN evidence.attribution a ON a.claim_id = c.id AND a.role = 'stated_by'::text
     JOIN evidence.source so ON so.id = a.source_id
     JOIN catalog.entity ch ON ch.id = so.channel_entity_id
     LEFT JOIN catalog.entity x ON x.id = a.entity_id
     LEFT JOIN content.document d ON d.canonical_source_id = so.id
  WHERE (c.structured ->> 'path'::text) = ANY (ARRAY['community_thread'::text, 'comparison_article'::text]);
```

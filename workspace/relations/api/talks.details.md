---
id: "rel:api.talks#details"
kind: details
schema: api
name: talks
of: "rel:api.talks"
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.talks — details

Spill-over from [the main page](talks.md).

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
SELECT w.id AS talk_id,
    w.title,
    e.slug,
    w.attributes ->> 'talk_kind'::text AS talk_kind,
    w.attributes ->> 'track'::text AS track,
    w.attributes ->> 'level'::text AS level,
    ev.display_name AS event,
    ev.id AS event_id,
    ev.attributes ->> 'starts_on'::text AS event_starts_on,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(w.id, 'presented_by'::text, 'outgoing'::text) x(x))) AS speakers,
    ( SELECT array_agg(DISTINCT org.display_name) AS array_agg
           FROM api.related(w.id, 'presented_by'::text, 'outgoing'::text) sp(sp)
             JOIN catalog.relationship r ON r.from_entity_id = sp.sp AND r.kind = 'employed_by'::text AND r.k_to IS NULL
             JOIN catalog.entity org ON org.id = r.to_entity_id) AS speaker_affiliations,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(w.id, 'about'::text, 'outgoing'::text) x(x))) AS topics,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(w.id, 'has_code'::text, 'outgoing'::text) x(x))) AS repositories,
    w.published_at AS recorded_at,
    w.duration_ms,
    w.canonical_url,
    w.attributes ->> 'video_url'::text AS video_url,
    w.attributes ->> 'slides_url'::text AS slides_url,
    w.attributes ->> 'session_id'::text AS session_id,
    ( SELECT count(*) AS count
           FROM content.document d
          WHERE d.work_entity_id = w.id OR (EXISTS ( SELECT 1
                   FROM content.document_about_entity a
                  WHERE a.document_id = d.id AND a.entity_id = w.id AND a.role = 'primary'::text))) AS document_count,
    e.summary
   FROM catalog.work w
     JOIN catalog.entity e ON e.id = w.id
     LEFT JOIN LATERAL ( SELECT x.id,
            x.tenant_id,
            x.kind,
            x.display_name,
            x.slug,
            x.summary,
            x.lifecycle,
            x.merged_into_id,
            x.projection_knowledge_seq,
            x.created_by_receipt_id,
            x.created_at,
            x.updated_at,
            x.attributes
           FROM catalog.entity x
          WHERE (x.id IN ( SELECT api.related(w.id, 'presented_at'::text, 'outgoing'::text) AS related))
         LIMIT 1) ev ON true
  WHERE w.tenant_id = util.current_tenant_id() AND w.kind = 'talk'::text AND e.lifecycle = 'active'::text;
```

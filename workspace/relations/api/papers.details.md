---
id: "rel:api.papers#details"
kind: details
schema: api
name: papers
of: "rel:api.papers"
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# api.papers — details

Spill-over from [the main page](papers.md).

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
SELECT w.id AS paper_id,
    w.title,
    w.attributes ->> 'arxiv_id'::text AS arxiv_id,
    w.attributes ->> 'doi'::text AS doi,
    w.published_at,
    w.canonical_url,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(w.id, 'authored_by'::text, 'outgoing'::text) x(x))) AS authors,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(w.id, 'published_by'::text, 'outgoing'::text) x(x))) AS publishers,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(w.id, 'has_code'::text, 'outgoing'::text) x(x))) AS repositories,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(w.id, 'introduces_technique'::text, 'outgoing'::text) x(x))) AS techniques,
    ( SELECT count(*) AS count
           FROM catalog.relationship r
             JOIN catalog.entity t ON t.id = r.from_entity_id
          WHERE r.to_entity_id = w.id AND r.kind = 'about'::text AND t.kind = 'talk'::text AND r.k_to IS NULL) AS talks_about,
    api.fact_amount(w.id, 'paper_citations'::text) AS citations,
    w.abstract
   FROM catalog.work w
     JOIN catalog.entity e ON e.id = w.id
  WHERE w.tenant_id = util.current_tenant_id() AND w.kind = 'paper'::text AND e.lifecycle = 'active'::text;
```

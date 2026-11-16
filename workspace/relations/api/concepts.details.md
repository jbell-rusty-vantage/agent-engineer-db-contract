---
id: "rel:api.concepts#details"
kind: details
schema: api
name: concepts
of: "rel:api.concepts"
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.concepts — details

Spill-over from [the main page](concepts.md).

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
SELECT id AS concept_id,
    kind,
    display_name AS concept,
    slug,
    attributes ->> 'component'::text AS component,
    attributes ->> 'level'::text AS level,
    COALESCE(attributes ->> 'description'::text, summary) AS description,
    ( SELECT count(*) AS count
           FROM api.related(e.id, 'about'::text, 'incoming'::text) related(related)) AS works_about,
    ( SELECT count(*) AS count
           FROM api.related(e.id, 'instance_of_concept'::text, 'incoming'::text) related(related)) AS instances,
    ( SELECT count(*) AS count
           FROM api.related(e.id, 'implements_technique'::text, 'incoming'::text) related(related)) AS implementations,
    ( SELECT count(*) AS count
           FROM guidance.item_subject s
          WHERE s.entity_id = e.id) AS guidance_items,
    ( SELECT count(DISTINCT b.revision_id) AS count
           FROM authoring.revision_binding b
          WHERE b.entity_id = e.id AND b.relation = 'covers'::text) AS modules_covering
   FROM catalog.entity e
  WHERE tenant_id = util.current_tenant_id() AND (kind = ANY (ARRAY['concept'::text, 'technique'::text])) AND lifecycle = 'active'::text;
```

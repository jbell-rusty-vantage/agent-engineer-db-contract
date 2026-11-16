---
id: "rel:api.people#details"
kind: details
schema: api
name: people
of: "rel:api.people"
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.people — details

Spill-over from [the main page](people.md).

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
SELECT id AS person_id,
    display_name AS person,
    slug,
    attributes ->> 'title'::text AS title,
    attributes ->> 'profile_url'::text AS profile_url,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(e.id, 'employed_by'::text, 'outgoing'::text) x(x))) AS affiliations,
    ( SELECT count(*) AS count
           FROM api.related(e.id, 'presented_by'::text, 'incoming'::text) related(related)) AS talk_count,
    ( SELECT count(*) AS count
           FROM api.related(e.id, 'authored_by'::text, 'incoming'::text) related(related)) AS work_count
   FROM catalog.entity e
  WHERE tenant_id = util.current_tenant_id() AND kind = 'person'::text AND lifecycle = 'active'::text;
```

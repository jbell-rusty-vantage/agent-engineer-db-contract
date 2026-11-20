---
id: "rel:api.people#details"
kind: details
schema: api
name: people
of: "rel:api.people"
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
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

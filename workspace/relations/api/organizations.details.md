---
id: "rel:api.organizations#details"
kind: details
schema: api
name: organizations
of: "rel:api.organizations"
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# api.organizations — details

Spill-over from [the main page](organizations.md).

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
SELECT id AS organization_id,
    display_name AS organization,
    slug,
    attributes ->> 'org_kind'::text AS org_kind,
    attributes ->> 'website_url'::text AS website_url,
    attributes ->> 'country_code'::text AS country_code,
    attributes ->> 'founded_on'::text AS founded_on,
    summary,
    ( SELECT count(*) AS count
           FROM api.related(e.id, 'develops'::text, 'outgoing'::text) related(related)) AS developed_count,
    ( SELECT count(*) AS count
           FROM api.related(e.id, 'offered_by'::text, 'incoming'::text) related(related)) AS offering_count,
    ( SELECT count(*) AS count
           FROM api.related(e.id, 'employed_by'::text, 'incoming'::text) related(related)) AS people_count,
    api.fact_amount(id, 'organization_headcount'::text) AS headcount
   FROM catalog.entity e
  WHERE tenant_id = util.current_tenant_id() AND kind = 'organization'::text AND lifecycle = 'active'::text;
```

---
id: "rel:api.events#details"
kind: details
schema: api
name: events
of: "rel:api.events"
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# api.events — details

Spill-over from [the main page](events.md).

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
SELECT id AS event_id,
    display_name AS event,
    slug,
    attributes ->> 'edition_label'::text AS edition_label,
    attributes ->> 'starts_on'::text AS starts_on,
    attributes ->> 'ends_on'::text AS ends_on,
    attributes ->> 'city'::text AS city,
    attributes ->> 'country'::text AS country,
    attributes ->> 'website_url'::text AS website_url,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(e.id, 'edition_of'::text, 'outgoing'::text) x(x))) AS series,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(e.id, 'organized_by'::text, 'outgoing'::text) x(x))) AS organizers,
    ( SELECT count(*) AS count
           FROM api.related(e.id, 'presented_at'::text, 'incoming'::text) related(related)) AS talk_count,
    COALESCE(( SELECT array_agg(x.value) AS array_agg
           FROM jsonb_array_elements_text(COALESCE(e.attributes -> 'tracks'::text, '[]'::jsonb)) x(value)), '{}'::text[]) AS tracks
   FROM catalog.entity e
  WHERE tenant_id = util.current_tenant_id() AND kind = 'industry_event'::text AND lifecycle = 'active'::text;
```

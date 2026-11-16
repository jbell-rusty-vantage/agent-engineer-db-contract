---
id: "rel:api.software_releases#details"
kind: details
schema: api
name: software_releases
of: "rel:api.software_releases"
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# api.software_releases — details

Spill-over from [the main page](software_releases.md).

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
SELECT r.id AS release_id,
    r.display_name AS release,
    s.id AS software_id,
    s.display_name AS software,
    s.kind AS software_kind,
    r.attributes ->> 'version_label'::text AS version_label,
    COALESCE(( SELECT lower(o.occurred_during) AS lower
           FROM temporal.event e
             JOIN temporal.event_occurrence o ON o.event_id = e.id
          WHERE e.subject_entity_id = r.id AND e.kind = 'release_published'::text AND o.k_to IS NULL
          ORDER BY (lower(o.occurred_during))
         LIMIT 1), (r.attributes ->> 'released_on'::text)::timestamp with time zone) AS released_at,
    COALESCE((r.attributes ->> 'breaking'::text)::boolean, false) AS breaking,
    COALESCE(( SELECT array_agg(x.value) AS array_agg
           FROM jsonb_array_elements_text(COALESCE(r.attributes -> 'highlights'::text, '[]'::jsonb)) x(value)), '{}'::text[]) AS highlights,
    r.attributes ->> 'release_url'::text AS release_url,
    ( SELECT o.k_from
           FROM temporal.event e
             JOIN temporal.event_occurrence o ON o.event_id = e.id
          WHERE e.subject_entity_id = r.id AND e.kind = 'release_published'::text AND o.k_to IS NULL
         LIMIT 1) AS learned_k,
    r.created_at AS observed_at
   FROM catalog.entity r
     JOIN catalog.relationship rel ON rel.from_entity_id = r.id AND rel.kind = 'version_of'::text AND rel.k_to IS NULL
     JOIN catalog.entity s ON s.id = rel.to_entity_id
  WHERE r.tenant_id = util.current_tenant_id() AND r.kind = 'library_release'::text AND r.lifecycle = 'active'::text;
```

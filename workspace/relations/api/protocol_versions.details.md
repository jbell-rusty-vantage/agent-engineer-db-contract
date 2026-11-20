---
id: "rel:api.protocol_versions#details"
kind: details
schema: api
name: protocol_versions
of: "rel:api.protocol_versions"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.protocol_versions — details

Spill-over from [the main page](protocol_versions.md).

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
SELECT v.id AS version_id,
    v.display_name AS version,
    p.display_name AS protocol,
    v.attributes ->> 'version_label'::text AS version_label,
    v.attributes ->> 'released_on'::text AS released_on,
    v.attributes ->> 'status'::text AS status,
    v.attributes ->> 'changelog_url'::text AS changelog_url,
    v.attributes ->> 'schema_url'::text AS schema_url,
    v.attributes -> 'deprecates'::text AS deprecates,
    v.attributes -> 'highlights'::text AS highlights,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(v.id, 'implements_protocol'::text, 'incoming'::text) x(x))) AS implemented_by
   FROM catalog.entity v
     JOIN catalog.relationship r ON r.from_entity_id = v.id AND r.kind = 'version_of'::text AND r.k_to IS NULL
     JOIN catalog.entity p ON p.id = r.to_entity_id AND p.kind = 'ai_protocol'::text
  WHERE v.tenant_id = util.current_tenant_id() AND v.kind = 'ai_protocol_version'::text AND v.lifecycle = 'active'::text;
```

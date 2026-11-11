---
id: "rel:api.advisories#details"
kind: details
schema: api
name: advisories
of: "rel:api.advisories"
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# api.advisories — details

Spill-over from [the main page](advisories.md).

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
SELECT a.id AS advisory_id,
    a.display_name AS advisory,
    a.attributes ->> 'ghsa_id'::text AS ghsa_id,
    a.attributes ->> 'cve_id'::text AS cve_id,
    a.attributes ->> 'severity'::text AS severity,
    a.attributes ->> 'summary'::text AS summary,
    a.attributes ->> 'url'::text AS url,
    a.attributes ->> 'published_at'::text AS published_at,
    r.from_entity_id AS software_id,
    s.display_name AS software,
    s.kind AS software_kind,
    r.properties ->> 'affected_range'::text AS affected_range,
    r.properties ->> 'fixed_version'::text AS fixed_version,
    r.primary_claim_id AS claim_id,
    r.k_from AS learned_k
   FROM catalog.entity a
     LEFT JOIN catalog.relationship r ON r.to_entity_id = a.id AND r.kind = 'affected_by_advisory'::text AND r.k_to IS NULL
     LEFT JOIN catalog.entity s ON s.id = r.from_entity_id
  WHERE a.tenant_id = util.current_tenant_id() AND a.kind = 'security_advisory'::text AND a.lifecycle = 'active'::text;
```

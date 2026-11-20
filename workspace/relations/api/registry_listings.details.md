---
id: "rel:api.registry_listings#details"
kind: details
schema: api
name: registry_listings
of: "rel:api.registry_listings"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.registry_listings — details

Spill-over from [the main page](registry_listings.md).

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
SELECT r.id AS relationship_id,
    s.id AS server_id,
    s.display_name AS server,
    s.attributes ->> 'namespace'::text AS namespace,
    (s.attributes ->> 'first_party_inferred'::text)::boolean AS first_party_inferred,
    s.attributes -> 'transport'::text AS transports,
    s.attributes ->> 'latest_version'::text AS latest_version,
    s.attributes ->> 'repository_url'::text AS repository_url,
    s.attributes ->> 'registry_status'::text AS registry_status,
    g.display_name AS registry,
    r.properties,
    r.k_from AS learned_k,
    ( SELECT seg.status
           FROM temporal.stream st
             JOIN temporal.segment seg ON seg.stream_id = st.id
          WHERE st.subject_relationship_id = r.id AND st.kind = 'registry_listing_status'::text AND seg.k_to IS NULL
          ORDER BY (lower(seg.valid_during)) DESC
         LIMIT 1) AS current_status
   FROM catalog.relationship r
     JOIN catalog.entity s ON s.id = r.from_entity_id
     JOIN catalog.entity g ON g.id = r.to_entity_id
  WHERE r.tenant_id = util.current_tenant_id() AND r.kind = 'listed_in'::text AND r.k_to IS NULL AND g.kind = 'registry'::text;
```

---
id: "rel:api.endpoints#details"
kind: details
schema: api
name: endpoints
of: "rel:api.endpoints"
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.endpoints — details

Spill-over from [the main page](endpoints.md).

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
SELECT n.id AS node_id,
    d.id AS document_id,
    d.canonical_title AS api_document,
    v.version_label,
    v.published_at,
    n.attributes ->> 'method'::text AS method,
    n.attributes ->> 'path'::text AS path,
    n.attributes ->> 'operation_id'::text AS operation_id,
    n.attributes ->> 'summary'::text AS summary,
    n.attributes -> 'tags'::text AS tags,
    (n.attributes ->> 'deprecated'::text)::boolean AS deprecated,
    (n.attributes ->> 'parameter_count'::text)::integer AS parameter_count,
    n.attributes ->> 'family'::text AS family,
    n.logical_key,
    ( SELECT r_1.entity_id
           FROM content.unit_entity_role r_1
          WHERE r_1.node_id = n.id AND r_1.role = 'api'::text
         LIMIT 1) AS api_entity_id
   FROM content.document d
     JOIN content.document_version v ON v.document_id = d.id
     JOIN content.document_representation r ON r.document_version_id = v.id
     JOIN content.document_node n ON n.representation_id = r.id
  WHERE d.tenant_id = util.current_tenant_id() AND (d.document_type_code = ANY (ARRAY['openapi_spec'::text, 'api_reference'::text])) AND n.unit_kind = 'endpoint'::text;
```

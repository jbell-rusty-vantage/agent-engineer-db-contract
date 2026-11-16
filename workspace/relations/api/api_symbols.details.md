---
id: "rel:api.api_symbols#details"
kind: details
schema: api
name: api_symbols
of: "rel:api.api_symbols"
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# api.api_symbols — details

Spill-over from [the main page](api_symbols.md).

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
    d.attributes ->> 'repository'::text AS repository,
    d.attributes ->> 'release_tag'::text AS release_tag,
    d.attributes ->> 'package'::text AS package,
    n.attributes ->> 'qualified_name'::text AS qualified_name,
    n.attributes ->> 'kind'::text AS symbol_kind,
    n.attributes ->> 'signature'::text AS signature,
    n.attributes ->> 'module'::text AS module,
    (n.attributes ->> 'is_public'::text)::boolean AS is_public,
    (n.attributes ->> 'deprecated'::text)::boolean AS deprecated,
    n.attributes ->> 'docstring_head'::text AS docstring_head,
    n.attributes ->> 'path'::text AS path,
    (n.attributes ->> 'lineno'::text)::integer AS lineno,
    ( SELECT r_1.entity_id
           FROM content.unit_entity_role r_1
          WHERE r_1.node_id = n.id AND r_1.role = 'release'::text
         LIMIT 1) AS release_id,
    ( SELECT count(*) AS count
           FROM content.unit_link l
          WHERE l.to_node_id = n.id AND l.kind = 'documents'::text) AS docs_links,
    n.attributes -> 'overloads'::text AS overloads,
    n.attributes -> 'uses_external'::text AS uses_external,
    d.attributes ->> 'released_on'::text AS released_on,
    (EXISTS ( SELECT 1
           FROM retrieval.projection_target pt
             JOIN retrieval.vector_item vi ON vi.projection_target_id = pt.id
          WHERE pt.document_node_id = n.id AND vi.lifecycle = 'active'::text)) AS embedded
   FROM content.document d
     JOIN content.document_version v ON v.document_id = d.id
     JOIN content.document_representation r ON r.document_version_id = v.id
     JOIN content.document_node n ON n.representation_id = r.id
  WHERE d.tenant_id = util.current_tenant_id() AND d.document_type_code = 'api_surface'::text AND n.unit_kind = 'api_symbol'::text AND NOT (EXISTS ( SELECT 1
           FROM content.document d2
          WHERE d2.tenant_id = d.tenant_id AND d2.document_type_code = 'api_surface'::text AND d2.id <> d.id AND d2.created_at > d.created_at AND (d2.attributes ->> 'repository'::text) = (d.attributes ->> 'repository'::text) AND (d2.attributes ->> 'release_tag'::text) = (d.attributes ->> 'release_tag'::text) AND COALESCE(d2.attributes ->> 'package'::text, ''::text) = COALESCE(d.attributes ->> 'package'::text, ''::text) AND (EXISTS ( SELECT 1
                   FROM content.document_version v2
                     JOIN content.document_representation r2 ON r2.document_version_id = v2.id
                     JOIN content.document_node n2 ON n2.representation_id = r2.id
                  WHERE v2.document_id = d2.id))));
```

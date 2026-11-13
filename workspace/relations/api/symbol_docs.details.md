---
id: "rel:api.symbol_docs#details"
kind: details
schema: api
name: symbol_docs
of: "rel:api.symbol_docs"
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.symbol_docs — details

Spill-over from [the main page](symbol_docs.md).

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
SELECT s.id AS symbol_node_id,
    sd.attributes ->> 'repository'::text AS repository,
    sd.attributes ->> 'release_tag'::text AS release_tag,
    sd.attributes ->> 'package'::text AS package,
    s.attributes ->> 'qualified_name'::text AS qualified_name,
    s.attributes ->> 'kind'::text AS symbol_kind,
    l.kind AS link_kind,
    l.method AS link_method,
    l.confidence,
    n.id AS docs_node_id,
    n.unit_kind AS docs_unit_kind,
    n.attributes ->> 'heading'::text AS heading,
    n.attributes ->> 'path'::text AS section_path,
    "left"(n.inline_text, 400) AS excerpt,
    d.id AS document_id,
    d.canonical_title AS document_title,
    d.document_type_code,
    src.canonical_url AS url,
    v.version_label,
    n.attributes ->> 'version_note'::text AS version_note
   FROM content.unit_link l
     JOIN content.document_node s ON s.id = l.to_node_id AND s.unit_kind = 'api_symbol'::text
     JOIN content.document_representation sr ON sr.id = s.representation_id
     JOIN content.document_version sv ON sv.id = sr.document_version_id
     JOIN content.document sd ON sd.id = sv.document_id
     JOIN content.document_node n ON n.id = l.from_node_id
     JOIN content.document_representation r ON r.id = n.representation_id
     JOIN content.document_version v ON v.id = r.document_version_id
     JOIN content.document d ON d.id = v.document_id
     LEFT JOIN evidence.source src ON src.id = d.canonical_source_id
  WHERE l.tenant_id = util.current_tenant_id() AND (l.kind = ANY (ARRAY['documents'::text, 'mentions'::text]));
```
